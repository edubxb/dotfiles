// Two shortcuts for the last framed code block of the latest assistant reply:
// - <leader>k copies it to the clipboard with `wl-copy` (bash, console or diff blocks).
// - <leader>o pastes it, without pressing Enter, into a shell in the same Kitty tab (shell blocks
//   only): the oc-run window, else an idle shell next to OpenCode, else a new oc-run split below.
// `messages.copy` (<leader>y) copies the whole message; these work on the code only.
import { spawn } from "node:child_process"
import { Plugin } from "@opencode/plugin/tui"

const COPY_ID = "local.copy-last-code-block"
const SEND_ID = "local.send-last-code-block"

// A fenced block: an opening fence of 3+ backticks or tildes with an optional
// language, the body, and a closing fence of the same characters.
const FENCE = /^ {0,3}(`{3,}|~{3,})([^\n]*)\n([\s\S]*?)\n? {0,3}\1[ \t]*$/gm

// Blocks that <leader>k copies. code-block-decoration frames more languages
// than these; this list is on purpose, not a mirror of that plugin.
const COPYABLE = new Set(["bash", "sh", "shell", "zsh", "console", "diff"])
// Blocks that are safe to paste into a shell (not console output, not diffs).
const SHELL_LANGUAGES = new Set(["bash", "sh", "shell", "zsh"])

// Kitty user variable that marks the runner window.
const RUNNER_VAR = "oc_run"

export function lastCodeBlock(text: string, languages: Set<string> = COPYABLE): string | undefined {
  let last: string | undefined
  for (const match of text.matchAll(FENCE)) {
    const language = match[2].trim().split(/\s+/)[0].toLowerCase()
    if (languages.has(language)) last = match[3]
  }
  return last
}

function copyToClipboard(text: string): Promise<void> {
  return new Promise((resolve, reject) => {
    // wl-copy forks to keep serving the clipboard, so wait for "exit", not "close".
    const child = spawn("wl-copy", [], { stdio: ["pipe", "ignore", "ignore"] })
    child.on("error", reject)
    child.on("exit", (code) => (code === 0 ? resolve() : reject(new Error(`wl-copy exited with ${code}`))))
    child.stdin.end(text)
  })
}

// Runs `kitten @ <args>` and returns stdout.
function kitten(args: string[], input = ""): Promise<string> {
  return new Promise((resolve, reject) => {
    const child = spawn("kitten", ["@", ...args], { stdio: ["pipe", "pipe", "pipe"] })
    let out = ""
    let err = ""
    child.stdout.on("data", (chunk) => (out += chunk))
    child.stderr.on("data", (chunk) => (err += chunk))
    child.on("error", reject)
    child.on("close", (code) =>
      code === 0 ? resolve(out) : reject(new Error(err.trim() || `kitten @ ${args[0]} exited with ${code}`)),
    )
    child.stdin.end(input)
  })
}

type KittyWindow = {
  id: number
  at_prompt: boolean
  user_vars?: Record<string, string>
  foreground_processes?: { cmdline: string[] }[]
  // Directions map to window-group IDs, not window IDs.
  neighbors?: Record<string, number[]>
}
type KittyTab = { windows: KittyWindow[]; groups: { id: number; windows: number[] }[] }

async function ownTab(selfID: string): Promise<KittyTab> {
  const osWindows = JSON.parse(await kitten(["ls"])) as { tabs: KittyTab[] }[]
  const tab = osWindows.flatMap((os) => os.tabs).find((t) => t.windows.some((w) => String(w.id) === selfID))
  if (!tab) throw new Error("OpenCode window not found in Kitty")
  return tab
}

const SHELLS = new Set(["zsh", "bash"])
const isIdleShell = (w: KittyWindow) =>
  w.at_prompt && SHELLS.has((w.foreground_processes?.[0]?.cmdline[0] ?? "").split("/").pop()!.replace(/^-/, ""))

// An idle shell window touching OpenCode, right side first.
function neighborShell(tab: KittyTab, selfID: string): KittyWindow | undefined {
  const self = tab.windows.find((w) => String(w.id) === selfID)
  for (const direction of ["right", "bottom", "left", "top"]) {
    for (const groupID of self?.neighbors?.[direction] ?? []) {
      const windowIDs = tab.groups.find((g) => g.id === groupID)?.windows ?? []
      const shell = tab.windows.find((w) => windowIDs.includes(w.id) && isIdleShell(w))
      if (shell) return shell
    }
  }
  return undefined
}

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms))

// Returns the window to paste into: the oc-run window if it exists, else an idle
// shell next to OpenCode, else a new oc-run split below OpenCode.
async function runner(selfID: string, cwd: string): Promise<number> {
  const tab = await ownTab(selfID)
  const existing = tab.windows.find((w) => w.user_vars?.[RUNNER_VAR] === "1")
  if (existing) {
    if (!existing.at_prompt) throw new Error("the oc-run window is busy")
    return existing.id
  }
  const neighbor = neighborShell(tab, selfID)
  if (neighbor) return neighbor.id

  const id = Number(
    (
      await kitten([
        "launch",
        "--match", `id:${selfID}`,
        "--next-to", `id:${selfID}`,
        "--location=hsplit",
        "--cwd", cwd,
        "--var", `${RUNNER_VAR}=1`,
        "--title", "oc-run",
      ])
    ).trim(),
  )
  // Wait for the new shell's first prompt, so the paste is not lost (max 10 s;
  // zsh with zinit took about 3.5 s in testing).
  for (let i = 0; i < 50; i++) {
    if ((await ownTab(selfID)).windows.find((w) => w.id === id)?.at_prompt) return id
    await sleep(200)
  }
  throw new Error("the new oc-run shell did not reach its prompt")
}

export default Plugin.define({
  id: "local.last-code-block",
  setup(context) {
    const toast = (message: string, variant: "success" | "warning" | "error") =>
      context.ui.toast.show({ message, variant })

    // Last block in `languages` from the newest assistant reply that has one.
    const findLast = async (languages: Set<string>) => {
      const route = context.ui.router.current()
      if (route.type !== "session") {
        toast("Open a session first", "warning")
        return undefined
      }
      await context.data.session.message.sync(route.sessionID)
      const messages = context.data.session.message.list(route.sessionID)
      for (let i = messages.length - 1; i >= 0; i--) {
        const message = messages[i]
        if (message.type !== "assistant") continue
        const text = message.content
          .flatMap((part) => (part.type === "text" ? [part.text] : []))
          .join("\n")
        const code = lastCodeBlock(text, languages)
        if (code !== undefined) return code
      }
      toast(languages === SHELL_LANGUAGES ? "No sh code block found" : "No bash, console or diff block found", "warning")
      return undefined
    }

    const copyLast = async () => {
      try {
        const code = await findLast(COPYABLE)
        if (code === undefined) return
        await copyToClipboard(code)
        const lines = code.split("\n").length
        toast(`Copied ${lines} line${lines === 1 ? "" : "s"}`, "success")
      } catch (error) {
        toast(`Copy failed: ${error instanceof Error ? error.message : String(error)}`, "error")
      }
    }

    const sendLast = async () => {
      const selfID = process.env.KITTY_WINDOW_ID
      if (!selfID) {
        toast("OpenCode is not running inside Kitty", "warning")
        return
      }
      try {
        const code = await findLast(SHELL_LANGUAGES)
        if (code === undefined) return
        const cwd = (context.location ?? context.data.location.default()).directory
        const id = await runner(selfID, cwd)
        // Bracketed paste keeps multi-line commands in the prompt instead of running them.
        await kitten(["send-text", "--match", `id:${id}`, "--bracketed-paste=auto", "--stdin"], code)
        await kitten(["focus-window", "--match", `id:${id}`])
        toast("Pasted; press Enter to run it", "success")
      } catch (error) {
        toast(`Send failed: ${error instanceof Error ? error.message : String(error)}`, "error")
      }
    }

    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        { id: COPY_ID, title: "Copy last code block", bind: "<leader>k", palette: true, run: () => void copyLast() },
        { id: SEND_ID, title: "Paste last command in shell", bind: "<leader>o", palette: true, run: () => void sendLast() },
      ],
      bindings: [COPY_ID, SEND_ID],
    }))
  },
})
