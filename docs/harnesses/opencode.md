# OpenCode

How this repo's skills run in [OpenCode](https://opencode.ai), from the same source tree as the Claude Code
plugin ([ADR 15](../decisions/0015-opencode-support.md)). Checked on OpenCode 1.19.3.

## Install

Clone the repo, then point OpenCode at its `skills/` folder in `opencode.json`, either globally
(`~/.config/opencode/opencode.json`) or per project:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": { "paths": ["/path/to/skills/skills"] }
}
```

OpenCode finds every nested `SKILL.md`, so all the `skills/factory/` and `skills/generic/` skills load. To update,
`git pull` in the clone.

Check: `opencode debug skill` lists `ship`, `intake`, `tier` and the rest, each with its `location` under the
clone.

## Layers

Nothing extra. OpenCode also reads `.claude/skills/` in the project and `~/.claude/skills/`, so a repo's
`<prefix>-<step>` variants and your user-level ones are found as they are. The `factory layers:` and
`factory personal layers:` lines are read from `AGENTS.md`, `CLAUDE.md`, `~/.claude/CLAUDE.md` and
`CLAUDE.local.md` by the skills themselves, whatever the harness loads.

## Claude Code features and their OpenCode equivalents

| The skills say | In OpenCode |
|---|---|
| invoke `anmarkoulis:<skill>` with the Skill tool | the `skill` tool with `<skill>` (no `anmarkoulis:` prefix) |
| structured question (AskUserQuestion) | the `question` tool |
| dispatch a subagent (the Agent tool) | the `task` tool with a generic agent (`general`) |
| the plugin agents in `agents/` (`task-reviewer`, `bug-diagnoser`, `qa-runner`, `manual-tester`, `vuln-probe`) | not loaded; `delegate` falls back to a generic worker or inline, as it does without them in Claude Code |
| one background agent, wait for its notification | none; run the same brief as one `task` worker in the foreground, or inline |
| plugin root: three directories above the skill's base directory | the same: OpenCode's `skill` tool prints `Base directory for this skill: <dir>` |
| a settings hook in `.claude/settings.json` (`retro`) | a pre-commit hook or a CI job, `retro`'s own fallback |
| the built-in `simplify` and `code-review` skills | the inline pass each step describes without them |
| Claude in Chrome (`manual-test`) | Playwright, else the guided script for the user |
| `claude plugin validate`, `claude plugin eval`, `claude --plugin-dir` | Claude Code only; no OpenCode equivalent is used |

## Limits

- Skills are looked up by name. A skill with the same name elsewhere (for example a `retro` in
  `~/.agents/skills/`) is shadowed without a warning: `opencode debug skill` shows which `location` won.
- OpenCode's current docs describe a newer tool set (`shell` for `bash`, `subagent` for `task`, background
  subagents). Map by role if your version shows those names.
- Not yet proven: a full `ship` run inside OpenCode from intake to retro (#26).
