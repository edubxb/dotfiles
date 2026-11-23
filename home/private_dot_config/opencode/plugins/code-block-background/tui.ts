// Draws a rounded border and a line-number gutter around fenced code blocks
// so they stand out in the transcript (the TUI draws them with syntax colors
// only, no fill or frame).
import { BoxRenderable, LineNumberRenderable } from "@opentui/core"
import { Plugin } from "@opencode/plugin/tui"

// OpenCode maps the aliases sh, shell and zsh to bash, so listing them again
// would throw "already registered".
const LANGUAGES = ["bash", "console", "diff"]
// Framed, but without the line-number gutter.
const NO_LINE_NUMBERS = new Set(["diff"])

export default Plugin.define({
  id: "local.code-block-background",
  setup(context) {
    // One wrapper per default code renderable, so streaming updates reuse it
    // instead of rebuilding the box on every token.
    const boxes = new WeakMap<object, { box: BoxRenderable; numbers?: LineNumberRenderable }>()

    const renderer = (numbered: boolean) => (_token: unknown, ctx: { defaultRender: () => any }) => {
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
          paddingLeft: numbered ? 0 : 1, // the gutter has its own left padding
          paddingRight: 1,
        })
        let numbers: LineNumberRenderable | undefined
        if (numbered) {
          // Grow into the row next to the gutter so long lines wrap.
          code.flexGrow = 1
          code.flexShrink = 1
          // The gutter paints numbers outside the text buffer, so selecting
          // and copying the block only picks up the code itself.
          numbers = new LineNumberRenderable(context.renderer, {
            target: code,
            paddingRight: 2, // gap between numbers and code
          })
          box.add(numbers)
        } else {
          box.add(code)
        }
        entry = { box, numbers }
        boxes.set(code, entry)
      }
      // Follow theme switches.
      entry.box.borderColor = context.theme.border.base
      if (entry.numbers) {
        entry.numbers.bg = context.theme.background.base
        entry.numbers.fg = context.theme.text.muted
      }
      return entry.box
    }

    const unregister = LANGUAGES.map((language) =>
      context.markdown.registerCodeBlockRenderer(language, renderer(!NO_LINE_NUMBERS.has(language))),
    )
    return () => unregister.forEach((stop) => stop())
  },
})
