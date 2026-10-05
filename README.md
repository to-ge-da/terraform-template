# terraform-template

Public **Template** for new Terraform repos in [to-ge-da](https://github.com/to-ge-da).

Org defaults (tooling, CI, GitHub templates) **without** product HCL — no `versions.tf`, modules, or remote backend yet.

## How to use

1. Click **Use this template** → **Create a new repository**.
2. Clone, then `mise install`.
3. Run `just --list` for tasks. Terraform recipes and CI soft-skip until you add `*.tf`.

## Included files

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Notes for coding agents |
| `justfile` | fmt/validate/init/plan/apply/destroy/cleanup, CI scan/pin, mise helpers |
| `mise.toml` | Terraform + `jq`, `zizmor`, `pinact` |
| `.gitignore` | Terraform / local / env ignores |
| `.github/workflows/ci.yml` | Light CI (hygiene; Terraform soft-skip) |
| `.github/dependabot.yml` | Weekly GitHub Actions updates |
| `.github/pull_request_template.md` | PR checklist |
| `.github/ISSUE_TEMPLATE/` | Bug and feature templates |

## Quick commands

```bash
just --list
just fmt
just plan
just ci-scan
just mise-tools
```

After you add HCL, the same recipes run for real (`just init`, `just plan`, `just apply`, …). `just destroy` and `just cleanup` prompt for confirmation.
