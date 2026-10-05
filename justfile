# ============================================================================
# Primary aliases
# ============================================================================
alias t := mise-tools

# Simple aliases for Terraform recipes (shown in `just --list`)
alias plan := tf-plan
alias apply := tf-apply
alias destroy := tf-destroy
alias fmt := tf-fmt
alias validate := tf-validate
alias init := tf-init
alias cleanup := tf-cleanup

# ============================================================================
# Terraform recipes
# ============================================================================

# Format Terraform files (write changes in place)
@tf-fmt:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping fmt."; else terraform fmt -write=true -recursive; fi

# Validate Terraform configuration
@tf-validate:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping validate."; else terraform validate; fi

# Initialize Terraform (providers/modules/backend)
@tf-init *var:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping init."; else terraform init {{ var }}; fi

# Create a plan and save it to a file
@tf-plan *var:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping plan."; else terraform plan -out plan {{ var }}; fi

# Apply the saved plan
@tf-apply *var:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping apply."; else terraform apply plan {{ var }}; fi

# Create a destroy plan, then confirm before applying it
@tf-destroy *var:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping destroy."; else terraform plan -destroy -out destroy {{ var }} && just _tf-destroy; fi

# Confirmation prompt for destroy
[confirm("Are you sure you want to destroy all Terraform resources? This action cannot be undone.")]
@_tf-destroy:
    terraform apply destroy

# Remove local Terraform artifacts (.terraform, plan files, crash logs, local state)
@tf-cleanup:
    if ! find . -name '*.tf' -not -path './.terraform/*' -print -quit | grep -q .; then echo "No *.tf yet — skipping cleanup."; else just _tf-cleanup; fi

# Confirmation prompt for cleanup
[confirm("Remove local Terraform artifacts (.terraform, plan/destroy files, crash logs, local state)? This does not destroy cloud resources.")]
@_tf-cleanup:
    rm -rf .terraform
    rm -f plan destroy crash.log crash.*.log *.tfstate *.tfstate.*
    echo "Local Terraform artifacts removed."

# ============================================================================
# CI / mise helpers
# ============================================================================

# CI security audit (zizmor + pinact verify)
[working-directory('.github')]
@ci-scan:
    zizmor dependabot.yml ./workflows/*.yml --no-exit-codes
    pinact run --verify ./workflows/*.yml

# Pin GitHub Actions to immutable SHAs
[working-directory('.github')]
@ci-pin:
    pinact run ./workflows/*.yml

# List mise tools installed in current directory
@mise-tools:
    mise ls --json | jq -r --arg pwd "$(pwd)" 'to_entries[] | select(.value[].source.path != null and (.value[].source.path | contains($pwd))) | .key'

# Preview local mise.toml tool upgrades (no changes)
@mise-upgrade-dry:
    mise upgrade --local --dry-run

# Apply tool upgrades from local mise.toml only
@mise-upgrade:
    mise upgrade --local

# List GitHub Actions workflows
@workflows:
    gh workflow list --json name --jq "to_entries[] | .value.name"
