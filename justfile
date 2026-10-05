# Soft-skip Terraform recipes when no *.tf exists yet (empty template stays green).

# Format Terraform files in place
@fmt:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping fmt."; else terraform fmt -write=true -recursive; fi

# Validate Terraform configuration
@validate:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping validate."; else terraform validate; fi

# Initialize Terraform (providers / modules / backend)
@init *ARGS:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping init."; else terraform init {{ ARGS }}; fi

# Create a plan and save it to ./plan
@plan *ARGS:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping plan."; else terraform plan -out plan {{ ARGS }}; fi

# Apply the saved ./plan file
@apply *ARGS:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping apply."; else terraform apply plan {{ ARGS }}; fi

# Plan a destroy, then confirm before applying it
@destroy *ARGS:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping destroy."; else terraform plan -destroy -out destroy {{ ARGS }} && just _destroy-apply; fi

[confirm("Destroy all Terraform-managed resources? This cannot be undone.")]
@_destroy-apply:
    terraform apply destroy

# Remove local Terraform artifacts (does not destroy cloud resources)
@cleanup:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping cleanup."; else just _cleanup-local; fi

[confirm("Remove local .terraform / plan / state artifacts? Cloud resources are not destroyed.")]
@_cleanup-local:
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
