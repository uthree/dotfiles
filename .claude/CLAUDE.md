## Coding instructions

- Keep README.md to the minimum: an overview of the project, how to install it,
  and little else. Write detailed information in separate files (for example
  `doc/*.md`).
- Write comments and documentation in English unless instructed otherwise.
- Features that were removed, or that were deliberately not implemented, do not
  need to be written in the documentation.

## Python

- As a rule, use a `uv` virtual environment when working with Python.
- Write tests using `pytest` and check code quality using `ruff` before commiting.

## Rust

- If you find yourself needing to debug the macro itself, please consider alternatives to using a macro.
- Verify the code quality using `cargo test` and `cargo clippy` before committing.
- Before running Cargo, set `RUSTC_WRAPPER=sccache` in the command environment
  when `sccache` is available and `RUSTC_WRAPPER` is unset. Do not rely on an
  interactive shell profile to set it.
