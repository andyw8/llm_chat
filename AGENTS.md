<!-- poetry:agents:begin -->
## Building UI with poetry (88 components + 8 blocks)

- FIRST MOVE on any UI brief: call the poetry MCP `compose` tool with the
  task text, before writing any ERB. It routes to the matching vetted
  block (source included, adapt in place - the winning path for screens)
  or to the right components. No MCP? `bin/rails g poetry:block --list`
  and start from the closest block. Composing a screen from scratch when
  a block matched is the known losing path.
- Compose with the `poetry_*` helpers (and the app's own components through
  the helpers they declare with `helper :name`); never hand-write `cn-*`
  classes, raw hex/oklch colors, or off-scale arbitrary values - tokens and
  variants carry the design.
- An app component written on the DSL declares `helper :name`; that makes it
  first-class on check, llms.txt and the skill. `bin/rails poetry:registry`
  (commit the file) exposes it to the MCP server too; `poetry:verify` fails
  when that file is stale. The app's own Stimulus controllers join the same
  way: `bin/rails poetry:stimulus:manifest` (commit the file) makes them
  validate like poetry's - `use_stimulus` by Symbol, template wiring in
  check, their API in the registry; generate the manifest BEFORE declaring
  a controller by Symbol (a Symbol not in the manifest fails at class load).
  A controller the reader cannot describe is named in the task output; an
  entry written by hand in the same file is kept across regenerations.
- Machine catalog: `/poetry/llms.txt` (index + blocks) and `/poetry/llms-full.txt`
  (full contracts + Stimulus wiring: targets / values / actions / events).
- Check comes LAST: `bin/rails poetry:check` as the FINAL action, after
  the last edit (unknown components/slots/variants/wiring, icon names,
  enum values, typed-slot props, helper + setter arity, yield-less
  blocks, setter keywords, required content blocks, required slots,
  component templates Herb will not compile, did-you-mean,
  `POETRY_CHECK_JSON=1` for JSON; `poetry:install` adds the `herb` gem it
  parses with, unless Rails brings it). An edit
  made after your last check is unverified markup - re-run it. Mailer
  templates (`*_mailer/`, the mailer layout) keep their inline colors:
  email has no tokens, so the raw-color rule is quiet there. Values that
  arrive from data meet a runtime tier: an off-list variant or a missing
  required option raises at construction in development and test.
- Faster: the `poetry` MCP server (`.mcp.json`: command `bundle`, args
  `["exec", "poetry-agent"]`, the poetry-agent gem) serves ten tools from the live registry
  with no app boot - `compose`, `build_page`, `list_components`,
  `describe_component`, `check`, `list_blocks`, `describe_block`,
  `list_recipes`, `get_skill`, and `guidance`. Prefer `compose` (or `build_page` for a
  whole screen) to start, and its `check` tool when iterating. Wire it
  into every editor at once with `bin/rails g poetry:editor` (MCP
  configs for VS Code / Cursor / Claude Code / Zed / RubyMine plus
  registry-driven snippets).
- Browser agents (WebMCP): opt a rendered component into the user's own
  agent with `webmcp: "name"` on the helper call - Combobox, Dialog, Sheet,
  Drawer, and Tabs declare tools (`describe_component` at `full` lists them);
  declare a form as a tool with `poetry_webmcp_form(tool: { name:,
  description: })` (autosubmit is GET-only). Needs the poetry-agent gem and
  `registerPoetryAgent(application)`; `poetry:check` gates the opt-ins.
- One visual theme per app (chosen at install with `--theme`); components
  read tokens, never restate them.
- Component identity: pass `key:` (a record, or a literal string) on any
  poetry component inside a collection loop, a fragment-cache block, or
  a broadcast partial - keyed ids follow the record across Turbo morph
  reorders and stay stable inside cached fragments, where random ids
  force replacement. `key: record` derives via dom_id (a host `to_key`
  override propagates); explicit `id:` wins outright; repeated NEW
  records need explicit keys. `poetry:check` warns on unkeyed
  components in cache blocks and loops. Full story: the Stable IDs guide on the poetry docs site.
- Upgrading poetry gems: after `bundle update`, re-run
  `bin/rails g poetry:install` - the vendored token/theme/safelist
  files refresh (the installed theme sticks; `--theme` switches;
  never `--force`: the four host-owned seed files are left alone),
  new wiring appends, this section and the skills regenerate. Then
  rebuild CSS and run the suite. `bin/rails g poetry:diff` reports
  where copied-in components drift from the installed gems.
- `bin/rails g poetry:scaffold_templates` retargets the STANDARD
  `rails g scaffold` to emit poetry-composed views (DataTable index
  with URL state, forms on the poetry form builder - one `f.input`
  per attribute) plus a matching controller - prefer scaffolding
  over hand-writing CRUD views.
- Claude Code skills: `poetry` (component contracts by family),
  `poetry-design` (theme / compose / audit / study / figma / paper -
  the taste layer), and `poetry-component` (anatomy / documentation /
  audit - the authoring layer) live under `.claude/skills/` - load
  `poetry` whenever writing ERB, `poetry-design` whenever composing a
  page or screen, BEFORE building (any page task is a design task,
  not only ones that mention design), and `poetry-component` whenever
  authoring or reviewing an app-owned component. Install/refresh:
  `bin/rails g poetry:skill`.
- Design interop: `bin/rails poetry:design:export` writes this app's
  DESIGN.md (tokens + treatment) for external design skills.
- Overriding the theme: token-level restyling goes through
  `poetry:design:import` (design-overrides.css) - which also ingests a
  Figma variables export (`bin/rails poetry:figma:import[export.json]`)
  or a Paper "Copy theme" (`bin/rails poetry:paper:import[theme.css]`),
  dropping any swatch that fails WCAG AA. Host CSS that targets
  theme-owned `cn-*` classes is allowed ONLY as a declared
  override - a dated, reasoned entry under `overrides:` in
  config/poetry_components.yml (`bin/rails poetry:design:overrides`
  reports drift and prints the paste-ready declaration). Declare
  only after the user confirms intent; never declare to skip a fix. A
  kit's own `cn-*` classes are the app's, not overrides - prefix them
  (`cn-acme-*`) and never declare them.
<!-- poetry:agents:end -->

## Local verification

Use https://llm_chat.test to verify changes locally - it is
served by puma-dev.
