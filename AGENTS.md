## Coding instructions

- Keep README.md to the minimum: an overview of the project, how to install it,
  and little else. Write detailed information in separate files (for example
  `doc/*.md`).
- Write comments and documentation in English unless instructed otherwise.
  However, the user is a Japanese speaker, so write documents intended only for
  the user (such as implementation plans and reports on experiment results) in
  Japanese unless instructed otherwise.
- Features that were removed, or that were deliberately not implemented, do not
  need to be written in the documentation.
- If you find an available update for an installed, user-level development tool
  such as Blaze, mold, or sccache, verify it with the official release notes or
  package manager and suggest updating it to the user. Exclude project-managed
  runtimes, tools, and dependencies whose versions vary by project, such as
  Python interpreters, virtual environments, and packages.

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
