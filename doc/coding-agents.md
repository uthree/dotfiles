# Coding agents and scripts

## Codex configuration

`~/.codex/config.toml` is managed by hand and is not installed from this
repository. The Codex app rewrites that file as it runs, keeping the model,
plugins, marketplaces, MCP servers, trusted projects and the computer-use
allowlist in it, so a copy installed from here would overwrite all of that on
every run of the installer.

Settings worth applying by hand on a new machine:

```toml
sandbox_mode = "danger-full-access"   # Windows; disables the command sandbox
approval_policy = "on-request"
approvals_reviewer = "auto_review"

[agents]
default_subagent_reasoning_effort = "medium"
```

Explicit spawn overrides take precedence over the subagent default. Select
**Custom (config.toml)** in the desktop app's permissions menu to use these
settings; **Approve for me** selects the workspace-write sandbox regardless of
the configured sandbox default.

## Shared instructions

The repository keeps identical coding instructions in both
`.claude/CLAUDE.md` and the root `AGENTS.md`. On Windows, `install.ps1` writes
a `~/.claude/CLAUDE.md` that imports the former with `@path`, so Claude Code
reads it in every project; `install.sh` symlinks it. Agents that support
the `AGENTS.md` convention, including Codex, read the repository-root file
after cloning this dotfiles repository.

zsh reads `.zshrc` only for interactive shells, but PowerShell runs `$PROFILE`
for `-Command` / `-File` runs as well — which is exactly how coding agents,
scripts and CI invoke it.

Left alone they would get `rm` as "send to the recycle bin", `ls` as eza text instead
of objects (so `ls | Measure-Object` counts 0), `mkdir` returning nothing, `cd`
as zoxide (a missing path stops being an error), plus the loading banner on
stdout.

## PowerShell

`profile.ps1` decides once whether the session is interactive
(`Test-DotfilesInteractiveSession`), and `profile.d/10-*` .. `80-*` bail out when
it is not — the equivalent of `[[ -o interactive ]] || return`.

A session counts as non-interactive when

- `CLAUDECODE`, `AI_AGENT` or `CI` is set, or
- the command line has `-Command` / `-File` / `-EncodedCommand` /
  `-NonInteractive`, or
- the process is not user-interactive.

`00-options.ps1` (PATH, UTF-8, XDG, `$EDITOR`) still loads, since it changes no
command's meaning.

## zsh

- `.zshrc` returns early when `CLAUDECODE`, `AI_AGENT` or `CI` is set. Claude
  Code already runs `unalias -a` over its shell snapshot, but other agents use
  `zsh -ic`.
- `.zprofile` initialises zoxide only for interactive shells, so `zsh -lc 'cd
  ...'` keeps the real `cd`.

Agents that call the shell as `sh -c` / `bash -c` / `zsh -c` were never affected:
zsh reads only `.zshenv` there, and this repository ships none.
