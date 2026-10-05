# Format Terraform files in place
@fmt:
    terraform fmt -write=true -recursive

# Validate Terraform configuration
@validate:
    terraform validate

# Initialize Terraform (providers / modules / backend)
@init *ARGS:
    terraform init {{ ARGS }}

# Create a plan and save it to ./plan
@plan *ARGS:
    terraform plan -out plan {{ ARGS }}

# Apply the saved ./plan file
@apply *ARGS:
    terraform apply plan {{ ARGS }}

# Plan a destroy, then confirm before applying it
@destroy *ARGS:
    terraform plan -destroy -out destroy {{ ARGS }}
    just _destroy-apply

[confirm("Destroy all Terraform-managed resources? This cannot be undone.")]
@_destroy-apply:
    terraform apply destroy

# Remove local Terraform artifacts (does not destroy cloud resources)
[confirm("Remove local .terraform / plan / state artifacts? Cloud resources are not destroyed.")]
@cleanup:
    rm -rf .terraform
    rm -f plan destroy crash.log crash.*.log *.tfstate *.tfstate.*
    echo "Local Terraform artifacts removed."

# CI workflow hygiene (zizmor + pinact verify)
[working-directory('.github')]
@ci-scan:
    zizmor dependabot.yml ./workflows/*.yml --no-exit-codes
    pinact run --verify ./workflows/*.yml

# Pin GitHub Actions to immutable SHAs
[working-directory('.github')]
@ci-pin:
    pinact run ./workflows/*.yml

# List mise tools installed for this directory
@mise-tools:
    mise ls --json | jq -r --arg pwd "$(pwd)" 'to_entries[] | select(.value[].source.path != null and (.value[].source.path | contains($pwd))) | .key'

alias t := mise-tools

# Preview local mise.toml tool upgrades (no changes)
@mise-upgrade-dry:
    mise upgrade --local --dry-run

# Apply tool upgrades from local mise.toml only
@mise-upgrade:
    mise upgrade --local
