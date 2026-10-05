# AGENTS.md

**Template mode:** this is an initial scaffold only. Replace or rewrite this file for each real project created from the template.

`to-ge-da` org Terraform template — tooling and GitHub defaults, no product HCL yet. Use `mise install`, `just --list`, and CI in `.github/workflows/ci.yml`. Prefer ready-for-review PRs. Do not invent infrastructure scope. Run Terraform just recipes after root-module HCL exists; CI soft-skips Terraform checks until root `*.tf` / `*.tf.json` is present.
