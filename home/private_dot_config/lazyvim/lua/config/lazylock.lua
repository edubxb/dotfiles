-- After lazy.nvim rewrites lazy-lock.json: re-add it to chezmoi, then commit
-- and push the chezmoi repo. Only the lock file is committed, so other
-- uncommitted dotfile changes are left alone.
-- lazy.nvim writes the lock in place after sync, update, restore and clean.
-- `:Lazy update` fires no User event, so watch the config folder instead.
local M = {}

local configdir = vim.fn.stdpath("config")
local lockfile = configdir .. "/lazy-lock.json"
local statedir = vim.fn.stdpath("state")
local marker = statedir .. "/lazy-lock-commit.lock"

-- Only one Neovim window runs the commit at a time. A marker older than
-- 5 minutes is left over from a crash, so it is ignored.
local function acquire()
  vim.fn.mkdir(statedir, "p")
  local fd = vim.uv.fs_open(marker, "wx", 420)
  if not fd then
    local st = vim.uv.fs_stat(marker)
    if st and os.time() - st.mtime.sec < 300 then
      return false
    end
    vim.uv.fs_unlink(marker)
    fd = vim.uv.fs_open(marker, "wx", 420)
    if not fd then
      return false
    end
  end
  vim.uv.fs_close(fd)
  return true
end

-- Never prompt (git would read the terminal Neovim owns) and never hang:
-- a command that needs input fails, a stuck one is killed after 30s.
local run_opts = {
  text = true,
  timeout = 30000,
  env = { GIT_TERMINAL_PROMPT = "0", GIT_SSH_COMMAND = "ssh -o BatchMode=yes" },
}

local function run(cmd, cb)
  vim.system(cmd, run_opts, function(res)
    vim.schedule(function()
      cb(res)
    end)
  end)
end

local function sync_lockfile()
  if not acquire() then
    return
  end
  local function finish()
    vim.uv.fs_unlink(marker)
  end
  local function fail(msg, res)
    finish()
    local out = res.stderr ~= "" and res.stderr or res.stdout or ""
    vim.notify(("%s (exit %d): %s"):format(msg, res.code, vim.trim(out)), vim.log.levels.ERROR)
  end
  local function skip(msg)
    finish()
    vim.notify("chezmoi: " .. msg, vim.log.levels.WARN)
  end
  run({ "chezmoi", "re-add", lockfile }, function(res)
    if res.code ~= 0 then
      return fail("chezmoi re-add failed", res)
    end
    run({ "chezmoi", "source-path", lockfile }, function(sp)
      if sp.code ~= 0 then
        return fail("chezmoi source-path failed", sp)
      end
      local src = vim.trim(sp.stdout)
      local repo = vim.fn.fnamemodify(src, ":h")
      -- exit 0: lock unchanged vs HEAD, nothing to commit; exit 1: changed
      run({ "git", "-C", repo, "diff", "--quiet", "HEAD", "--", src }, function(d)
        if d.code == 0 then
          return finish()
        end
        if d.code ~= 1 then
          return fail("git diff failed", d)
        end
        run({ "git", "-C", repo, "symbolic-ref", "--short", "HEAD" }, function(b)
          local branch = vim.trim(b.stdout or "")
          if b.code ~= 0 or branch ~= "main" then
            return skip("dotfiles repo is not on main, lazy lock file not committed")
          end
          run({ "git", "-C", repo, "commit", "-m", "neovim: update lazy lock file", "--", src }, function(c)
            if c.code ~= 0 then
              return fail("git commit failed", c)
            end
            -- Push only when the lock commit is the only unpushed one, so
            -- local-only commits are never published by accident.
            run({ "git", "-C", repo, "rev-list", "--count", "@{u}..HEAD" }, function(r)
              if r.code ~= 0 then
                return fail("git rev-list failed", r)
              end
              local ahead = vim.trim(r.stdout)
              if ahead ~= "1" then
                return skip(("lazy lock file committed, not pushed: %s unpushed commits"):format(ahead))
              end
              run({ "git", "-C", repo, "push" }, function(p)
                if p.code ~= 0 then
                  return fail("git push failed", p)
                end
                finish()
                vim.notify("chezmoi: lazy lock file committed and pushed", vim.log.levels.INFO)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

function M.setup()
  local timer = vim.uv.new_timer()
  local watcher = vim.uv.new_fs_event()
  -- Watch the folder, not the file: a replaced file (rename) and a file that
  -- does not exist yet at startup are both handled.
  watcher:start(configdir, {}, function(err, name)
    if err or name ~= "lazy-lock.json" then
      return
    end
    -- lazy.nvim writes the file in several chunks; wait for it to settle
    timer:stop()
    timer:start(500, 0, vim.schedule_wrap(sync_lockfile))
  end)
end

return M
