// Draws a rounded border, a language label and a line-number gutter around
// fenced code blocks so they stand out in the transcript (the TUI draws them
// with syntax colors only, no fill or frame).
// Copy (<leader>k) and paste-to-shell (<leader>o) rules live in last-code-block,
// not here: framing a language does not make it copyable or runnable.
import { BoxRenderable, LineNumberRenderable, TextRenderable, fg, t } from "@opentui/core"
import { Plugin } from "@opencode/plugin/tui"

// OpenCode matches renderers by exact language name after resolving aliases
// (sh/shell/zsh -> bash, and so on), with no catch-all. So only blocks tagged
// with one of these languages get a frame; untagged blocks keep the default look.
// Aliases are listed too: if OpenCode maps one to a language already here,
// registering it throws "already registered" and it is skipped.
const LANGUAGES = [
  "bash", "sh", "shell", "zsh", "console", "diff",
  "hcl", "terraform", "tf", "yaml", "yml", "json", "jsonc", "toml", "ini",
  "python", "py", "typescript", "ts", "tsx", "javascript", "js", "jsx",
  "go", "rust", "lua", "sql", "dockerfile", "make", "makefile",
  "markdown", "md", "html", "css", "xml", "text", "txt",
]
// Framed, but without the line-number gutter (diffs, and plain text such as
// sketches or output, where numbers are noise).
const NO_LINE_NUMBERS = new Set(["diff", "text", "txt"])

export default Plugin.define({
  id: "local.code-block-decoration",
  setup(context) {
    // One wrapper per default code renderable, so streaming updates reuse it
    // instead of rebuilding the box on every token.
    const boxes = new WeakMap<
      object,
      {
        box: BoxRenderable
        title: TextRenderable
        label?: string
        labelBorder?: unknown
        labelDim?: unknown
        numbers?: LineNumberRenderable
        foot?: TextRenderable
        signLines?: number
        signColor?: unknown
      }
    >()

    const renderer = (numbered: boolean) => (token: { lang?: string; text?: string }, ctx: { defaultRender: () => any }) => {
      const code = ctx.defaultRender()
      if (!code) return undefined

      let entry = boxes.get(code)
      if (!entry || entry.box.isDestroyed) {
        // A gutter from a previous plugin load refuses remove(); detach via clearTarget.
        if (code.parent instanceof LineNumberRenderable) code.parent.clearTarget()
        else code.parent?.remove(code)
        const box = new BoxRenderable(context.renderer, {
          flexShrink: 0,
          border: true,
          borderStyle: "rounded",
          // No padding: the code and the line numbers touch the border.
        })
        // The language label, drawn over the top border. The native box title
        // always starts right after the corner, with no offset option. This
        // text starts 1 cell further right, so the border keeps a "─" in its
        // own color before the label: "╭─ sh ───".
        // Absolute offsets start inside the border: top -1 is the border row,
        // left 1 is the second cell after the corner. Numbered blocks move it
        // further right, so the word sits above the code (see the gutter below).
        const title = new TextRenderable(context.renderer, {
          position: "absolute",
          top: -1,
          left: 1,
          wrapMode: "none",
        })
        box.add(title)
        let numbers: LineNumberRenderable | undefined
        let foot: TextRenderable | undefined
        if (numbered) {
          // Grow into the row next to the gutter so long lines wrap.
          code.flexGrow = 1
          code.flexShrink = 1
          // The gutter paints numbers outside the text buffer, so selecting
          // and copying the block only picks up the code itself.
          numbers = new LineNumberRenderable(context.renderer, { target: code })
          // The gutter defaults to a 1-cell left padding and a 3-cell minimum
          // width. Drop both so the numbers touch the border and the separator
          // follows the widest number: "1│ code", "10│ code".
          numbers.setGutterLayout({
            minWidth: 0,
            paddingLeft: 0,
            paddingRight: 1, // gap between the separator and the code
            minDigits: 0,
            minAfterWidth: 0,
          })
          box.add(numbers)
          // A "┴" in the bottom border below the separator, the mirror of the
          // "┬" in the label. bottom -1 is the border row; left follows the
          // digits, like the label (set with the separator below).
          foot = new TextRenderable(context.renderer, {
            content: "┴",
            position: "absolute",
            bottom: -1,
            left: 1,
            wrapMode: "none",
          })
          box.add(foot)
        } else {
          // OpenCode builds the code with width "100%", which ignores the box
          // padding. "auto" lets the box column stretch it to its inner width.
          code.width = "auto"
          box.add(code)
        }
        entry = { box, title, numbers, foot }
        boxes.set(code, entry)
      }
      // Follow theme switches. Label and numbers use the dimmest text color;
      // not every theme defines "faint", so fall back to "muted".
      const dim = context.theme.text.faint ?? context.theme.text.muted
      const border = context.theme.border.base
      entry.box.borderColor = border
      // The language as written in the fence (first word of the info string),
      // with non-breaking spaces around it: a plain space on a transparent
      // background may let the border line show through. In numbered blocks
      // the first cell sits above the "│" separator, so it is a "┬" in the
      // border color that joins the separator to the top border, then a "─"
      // so a line separates the "┬" from the label.
      // Rebuilt only when the word or the theme changes (streaming).
      const word = (token.lang ?? "").trim().split(/\s+/)[0].toLowerCase()
      if (entry.label !== word || entry.labelBorder !== border || entry.labelDim !== dim) {
        const lead = entry.numbers ? "┬─" : "\u00a0"
        entry.title.content = word ? t`${fg(border)(lead)}${fg(dim)(`\u00a0${word}\u00a0`)}` : ""
        entry.label = word
        entry.labelBorder = border
        entry.labelDim = dim
      }
      if (entry.numbers) {
        entry.numbers.bg = context.theme.background.base
        entry.numbers.fg = dim
        // Vertical separator after the numbers, as an "after" sign on every
        // line. The gutter draws signs only on the first row of each line, so
        // wrapped rows and the padding rows show no separator.
        // Rebuilt only when the line count or the theme changes (streaming).
        const lines = (token.text ?? "").split("\n").length
        const color = context.theme.border.base
        if (entry.signLines !== lines || entry.signColor !== color) {
          const sign = { after: "│", afterColor: color }
          entry.numbers.setLineSigns(new Map(Array.from({ length: lines }, (_, line) => [line, sign])))
          // Start the label's "┬" above the "│" separator, which sits right
          // after the digits. The gutter counts wrapped rows too, so a block
          // that only reaches 10 rows by wrapping leaves the label 1 cell short.
          entry.title.left = String(lines).length
          if (entry.foot) {
            entry.foot.left = String(lines).length
            entry.foot.fg = color
          }
          entry.signLines = lines
          entry.signColor = color
        }
      }
      return entry.box
    }

    const unregister: (() => void)[] = []
    for (const language of LANGUAGES) {
      try {
        unregister.push(context.markdown.registerCodeBlockRenderer(language, renderer(!NO_LINE_NUMBERS.has(language))))
      } catch (error) {
        // An alias of a language registered above; anything else is a real error.
        if (!(error instanceof Error && error.message.includes("already registered"))) throw error
      }
    }
    return () => unregister.forEach((stop) => stop())
  },
})
