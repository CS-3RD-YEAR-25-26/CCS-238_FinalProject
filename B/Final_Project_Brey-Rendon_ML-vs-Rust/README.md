# ML (1973) vs Rust (2015): ML's Influence on a Systems Language

CCS 238 — Programming Languages, Final Project (comparative term paper)
West Visayas State University, College of Information and Communications Technology

**Line of inquiry:** ML's influence on a systems language: enums, matching, inference

**Group members:** Justin Jones Brey, Jethro Rendon

## Repository layout

| Folder | Contents |
|---|---|
| `ml/` | Companion programs in 1973 ML, run on HOL88 Classic ML |
| `ml/tests/` | Small feature tests used to check the language before writing the programs |
| `rust/` | Companion programs in Rust (one Cargo project, one binary per program) |
| `rust/examples/` | Small feature checks matching the ML tests (some fail to compile on purpose) |
| `screenshots/` | Program output used in the paper's appendices |

## Companion programs

Each problem is solved in both languages.

| # | Problem | 1973 ML | Rust |
|---|---|---|---|
| P1 | Expression evaluator | `ml/p1_expr.ml` | `rust/src/bin/p1_expr.rs` |
| P2 | Parse and average | `ml/p2_parse.ml` | `rust/src/bin/p2_parse.rs` |
| P3 | Generic binary search tree | `ml/p3_bst.ml` | `rust/src/bin/p3_bst.rs` |

## Running the 1973 ML programs

The original 1973 ML (the metalanguage of the Edinburgh LCF theorem prover) has no maintained
implementation. Its closest runnable descendant is Classic ML inside the HOL88 system.

**Toolchain:** HOL88 Version 2.02 (GCL), Ubuntu package `hol88` 2.02.19940316dfsg-5build3, on Ubuntu 24.04 (WSL)

Install (Ubuntu):

```
sudo apt install hol88
```

Run a program (example: P1):

```
cd ml
hol88
loadt `p1_expr`;;
quit();;
```

`loadt` runs every line of the file and shows each result; `loadf` runs it quietly.

**Every `.ml` file must end with a line break.** HOL88 silently skips the last line of a file that doesn't end with one.

## Running the Rust programs

**Toolchain:** rustc 1.100.0 (0ef1bc386 2026-11-09), cargo 1.100.0 (3acc79c0c 2026-11-05), edition 2021, installed with rustup on Ubuntu 24.04 (WSL)

```
cd rust
cargo run --bin p1_expr
```

Run a feature check (example: check 1a):

```
cd rust
cargo run --example check1a
```

Each file can also be pasted into the [Rust Playground](https://play.rust-lang.org) and run there.
