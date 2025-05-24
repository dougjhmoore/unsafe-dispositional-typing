# unsafe-dispositional-typing
Dispositional Typing is a prototype compiler pass that replaces ad-hoc `unsafe` blocks in C, C++ and Rust with a provably safe, four-symbol algebra (ε i j η).
Each SSA data-flow edge is tagged with one of four **dispositional roles**—boundary ε, ascending i, descending j, identity η. A single backward pass checks that every cycle of tags *commutes*; if so, alias- and lifetime-safety are guaranteed, and the surrounding `unsafe` annotation can be dropped automatically.
The repository contains:

* Clang 17 and Rustc plug-ins implementing the tag inference
* driver scripts for LLVM test-suite, SPEC, SQLite, Redis, and Rust libstd
* post-processing tools that generate CSV reports and the Word tables used in the paper
* a Dockerfile for one-command reproducibility.

On the supplied benchmark corpus the pass removes \~78 % of legacy `unsafe` casts with no new run-time faults.
