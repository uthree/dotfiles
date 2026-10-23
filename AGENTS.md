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

## Python

- As a rule, use a `uv` virtual environment when working with Python.
- Write tests using `pytest` and check code quality using `ruff` before commiting.

## Rust

- If you find yourself needing to debug the macro itself, please consider alternatives to using a macro.
- Verify the code quality using `cargo test` and `cargo clippy` before committing.
- When compiling Rust from Codex, run outside the sandbox and set
  `CARGO_INCREMENTAL=0` in the command environment.
- Before running Cargo, when `sccache` is available, set
  `RUSTC_WRAPPER=sccache` and `SCCACHE_CACHE_SIZE=30G` in the command environment
  if they are unset. Do not rely on an interactive shell profile to set them.
