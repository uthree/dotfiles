## Coding instructions

- Keep README.md to the minimum: an overview of the project, how to install it,
  and little else. Write detailed information in separate files (for example
  `doc/*.md`).
- Features that were removed, or that were deliberately not implemented, do not
  need to be written in the documentation.
- If you find an available update for an installed, user-level development tool
  such as Blaze, mold, or sccache, verify it with the official release notes or
  package manager and suggest updating it to the user. Exclude project-managed
  runtimes, tools, and dependencies whose versions vary by project, such as
  Python interpreters, virtual environments, and packages.

## Work records (miloa)

- Keep a record in miloa (through its MCP tools) of investigations, changes, and
  experiments. Decide for yourself when a record is worth writing, and write it
  without waiting for the user's approval. If the miloa MCP server is not
  connected in the current environment, skip this and carry on.
- Before starting a non-trivial investigation, search miloa for earlier records
  on the topic so the same ground is not covered twice.
- Write entries in Japanese, one entry per topic (one question, or one change),
  never one per session.
- Write the Japanese in an entry through the `yomiyasu` skill where it is
  available: draft the text, then let the skill refine it, so a record reads
  naturally instead of reading like machine output. Treat this as the skill
  being asked for by name.
- Record what failed as well as what worked. Approaches that did not work, and
  why, are the most valuable part of a record: they are left in neither the code
  nor the git history.
- Tag entries `作業記録`. Required fields are `日付`, `種別` (調査 / 実験 / 変更 /
  環境構築, each carrying its own fields) and `記録者` (which agent wrote the
  entry, with the model name and version, for example `Claude Code` + `Opus 5`).
  Set `リポジトリ` to the matching `リポジトリ` entry, creating that entry when
  it does not exist yet, and set `状態` to 完了 / 未解決 / 保留.
- Entry bodies cannot be searched through MCP; only titles, tags, and fields can.
  Title an entry so that it can be found later (`[リポジトリ] 何をしたか`), and
  put the words worth searching for into `キーワード`.
- Structure the body as 背景 / 分かったこと / 試して駄目だったこと / 次にやるなら.
- Do not record what the code or `git log` already says, or work that a single
  command settled.

## Python

- As a rule, use a `uv` virtual environment when working with Python.
- Write tests using `pytest` and check code quality using `ruff` before commiting.

## Rust

- If you find yourself needing to debug the macro itself, please consider alternatives to using a macro.
- On supported macOS and Linux hosts, use [Blaze](https://github.com/indexable-inc/blaze)
  for iterative Rust builds, runs, checks, and tests when it is installed (for
  example, `blaze build` instead of `cargo build`). If a Blaze build fails or
  behaves unexpectedly, retry the equivalent command with ordinary Cargo.
- On supported targets where [mold](https://github.com/rui314/mold) is installed,
  use it for Rust linking when compatible with the project's linker configuration.
  If a build fails or behaves unexpectedly with mold, retry with the default
  linker. When both Blaze and mold are involved, use Cargo with the default
  linker to check whether the problem remains.
- If Blaze, mold, or sccache is supported by the current environment but is not
  installed, suggest that the user install the missing tool. Continue with the
  available build tools in the meantime.
- Verify the code quality using `cargo test` and `cargo clippy` before committing.
- When compiling Rust from Codex, run outside the sandbox and set
  `CARGO_INCREMENTAL=0` in the command environment.
- Before running Cargo, when `sccache` is available, set
  `RUSTC_WRAPPER=sccache` and `SCCACHE_CACHE_SIZE=30G` in the command environment
  if they are unset. Do not rely on an interactive shell profile to set them.
