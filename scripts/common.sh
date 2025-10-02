#!/usr/bin/env bash
set -euo pipefail

# Install required tools
install_tools() {
  echo "==> Installing node & sfdx & sgd"
  npm install -g @salesforce/cli
  echo "y" | sf plugins install sfdx-git-delta
  echo "y" | sf plugins install @salesforce/sfdx-scanner || true
}

# Authenticate to an org using secrets set by the workflow
# Expects CLIENT_ID and SF_USERNAME and JWT_BASE64 env variables in environment
auth_org() {
  local alias="$1"
  mkdir -p assets
  echo "${JWT_KEY}" | base64 --decode > assets/server.key
  sf org login jwt \
    --client-id "${CLIENT_ID}" \
    --jwt-key-file assets/server.key \
    --username "${SF_USERNAME}" \
    --instance-url "${SF_INSTANCE_URL:-https://login.salesforce.com}" \
    --alias "${alias}"
}

# Generate delta package comparing $FROM_REF vs $TO_REF
# Outputs to ./delta
generate_delta() {
  local from_ref="$1"
  local to_ref="$2"
  mkdir -p delta
  echo "Generating delta from ${from_ref} to ${to_ref}"
  # If sgd fails with no changes it may still create no package; handle that later
  sf sgd source delta --to "${to_ref}" --from "${from_ref}" --output "./delta" -i .sgdignore || true
  if [ -f delta/package/package.xml ] && [ -s delta/package/package.xml ]; then
    echo "Delta package generated:"
    cat delta/package/package.xml
  else
    echo "No delta package generated"
  fi
}

# Deploy manifest if exists, otherwise deploy full source (fallback)
deploy_delta_or_full() {
  local target_alias="$1"
  local test_level="${2:-RunLocalTests}"
  if [ -f delta/package/package.xml ] && [ -s delta/package/package.xml ]; then
    echo "Deploying delta manifest to ${target_alias}"
    sf project deploy start --manifest delta/package/package.xml --target-org "${target_alias}" --test-level "${test_level}" --wait 60 --verbose
  else
    echo "No delta package found, deploying full source to ${target_alias}"
    sf project deploy start --source-dir force-app --target-org "${target_alias}" --test-level "${test_level}" --wait 60 --verbose
  fi
}

# Run static scans: SFDX scanner + PMD (pmd-github-action used in GH) + SonarCloud invoked externally
run_scanners() {
  mkdir -p reports
  echo "Running SFDX scanner..."
  sf scanner run -f html -t "force-app" -e "eslint,pmd,cpd" -c "Design,Best Practices,Code Style,Performance,Security" --outfile reports/scan-reports.html || true
  echo "SFDX scanner complete. Report: reports/scan-reports.html"
}

# Exit with non-zero if PMD violations found (the pmd action also prints outputs)
fail_on_pmd_violations() {
  local violations="$1"
  echo "PMD violations: ${violations}"
  if [ "${violations}" != "0" ]; then
    echo "❌ PMD violations detected, failing pipeline"
    exit 1
  fi
}
