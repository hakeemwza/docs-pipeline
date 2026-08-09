#!/usr/bin/env bash
# Validate that cURL examples in the Stripe PaymentIntents reference doc are
# structurally correct by running them against a local mock server generated
# from Stripe's public OpenAPI spec (via Prism). This does NOT hit the real
# Stripe API and requires no secret keys -- it only proves the request shape
# (method, path, required params) matches the current published spec.
#
# Usage: ./validate_curl_against_mock.sh
set -euo pipefail

DOC_FILE="docs/02-api-reference-stripe-paymentintents.md"
STRIPE_SPEC_URL="https://raw.githubusercontent.com/stripe/openapi/master/openapi/spec3.json"
MOCK_PORT=4010
MOCK_HOST="http://127.0.0.1:${MOCK_PORT}"

echo "==> Starting Prism mock server from Stripe's public OpenAPI spec..."
npx --yes @stoplight/prism-cli mock "$STRIPE_SPEC_URL" --port "$MOCK_PORT" --dynamic &
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
python3 scripts/extract_code_blocks.py --lang bash --out /tmp/curl_blocks "$DOC_FILE"

FAIL=0
for block in /tmp/curl_blocks/*.sh; do
  [ -e "$block" ] || { echo "No bash blocks found in $DOC_FILE"; exit 1; }

  echo "==> Validating $block against mock..."
  REWRITTEN=$(sed \
    -e "s#https://api.stripe.com#${MOCK_HOST}#g" \
    -e "s#sk_test_51ABC...#sk_test_mock#g" \
    "$block")

  STATUS=$(bash -c "$REWRITTEN" -o /tmp/curl_response.json -w '%{http_code}' -s -o /dev/null || echo "000")

  if [[ "$STATUS" =~ ^2 ]]; then
    echo "    -> HTTP $STATUS (OK)"
  else
    echo "    -> HTTP $STATUS (FAIL) -- request shape no longer matches the published spec"
    FAIL=1
  fi
done

if [ "$FAIL" -ne 0 ]; then
  echo "One or more cURL examples failed validation against the live spec."
  exit 1
fi

echo "All cURL examples validated successfully against Stripe's current public spec."
