#!/usr/bin/env bash
# Validate that cURL examples in API reference docs are structurally correct
# by running them against a local mock server generated from the target
# API's public OpenAPI spec (via Prism). This does NOT hit any real API and
# requires no secret keys -- it only proves the request shape (method, path,
# required params) matches the current published spec.
#
# SCOPE: only docs listed in DOC_SPEC_MAP below are validated this way.
# A doc is only added here once a machine-readable OpenAPI spec exists for
# its target API. (Tango Card's Rewards-as-a-Service API has no published
# OpenAPI spec as of this writing, so 03-onboarding-guide-tango-api.md is
# NOT in this list -- its code samples are still caught by the Python
# syntax check, but its curl examples are not verified against a live spec.
# Don't add it here until a real spec exists; a fake/hand-written spec would
# validate against itself, not against Tango's actual API shape.)
#
# Usage: ./scripts/validate-curl-against-mock.sh
set -euo pipefail

MOCK_PORT=4010
MOCK_HOST="http://127.0.0.1:${MOCK_PORT}"

# doc_file|spec_url|real_host_to_replace
DOC_SPEC_MAP=(
  "docs/02-api-reference-stripe-paymentintents.md|https://raw.githubusercontent.com/stripe/openapi/master/openapi/spec3.json|https://api.stripe.com"
)

OVERALL_FAIL=0

for entry in "${DOC_SPEC_MAP[@]}"; do
  IFS='|' read -r DOC_FILE SPEC_URL REAL_HOST <<< "$entry"

  echo "=================================================="
  echo "==> Validating ${DOC_FILE}"
  echo "=================================================="

  echo "==> Starting Prism mock server from ${SPEC_URL}..."
  npx --yes @stoplight/prism-cli mock "$SPEC_URL" --port "$MOCK_PORT" --dynamic &
  MOCK_PID=$!

  cleanup() {
    echo "==> Stopping mock server (pid $MOCK_PID)"
    kill "$MOCK_PID" 2>/dev/null || true
  }
  trap cleanup EXIT

  echo "==> Waiting for mock server to become healthy..."
  for i in $(seq 1 30); do
    if curl -s -o /dev/null "$MOCK_HOST"; then
      echo "Mock server is up."
      break
    fi
    if [ "$i" -eq 30 ]; then
      echo "Mock server did not start in time." >&2
      exit 1
    fi
    sleep 1
  done

  echo "==> Extracting cURL example from ${DOC_FILE}..."
  python3 scripts/extract-code-blocks.py --lang bash --out /tmp/curl_blocks "$DOC_FILE"

  for block in /tmp/curl_blocks/*.sh; do
    [ -e "$block" ] || { echo "No bash blocks found in $DOC_FILE"; exit 1; }

    echo "==> Validating $block against mock..."
    REWRITTEN=$(sed \
      -e "s#${REAL_HOST}#${MOCK_HOST}#g" \
      -e "s#sk_test_51ABC...#sk_test_mock#g" \
      "$block")

    STATUS=$(eval "$REWRITTEN" -sS -o /tmp/curl_response.json -w '%{http_code}' 2>/dev/null || echo "000")

    if [[ "$STATUS" =~ ^2 ]]; then
      echo "    -> HTTP $STATUS (OK)"
    else
      echo "    -> HTTP $STATUS (FAIL) -- request shape no longer matches the published spec"
      OVERALL_FAIL=1
    fi
  done

  cleanup
  trap - EXIT
  rm -rf /tmp/curl_blocks
done

if [ "$OVERALL_FAIL" -ne 0 ]; then
  echo "One or more cURL examples failed validation against their published spec."
  exit 1
fi

echo "All cURL examples validated successfully against their current public specs."
