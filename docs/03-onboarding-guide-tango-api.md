# Getting Started with the Tango API in 5 Minutes

**Type:** SaaS Onboarding Guide
**Target API:** Tango Card Rewards-as-a-Service API (public, documented for reference/demonstration purposes)

Tango Card's API lets you send digital gift cards and rewards programmatically. This guide takes you from zero to your first order.

## 1. Authenticate

Every request is authenticated with HTTP Basic Auth using your **Platform Name** and **Platform Key**, issued when your account is provisioned.

curl https://integration-api.tangocard.com/raas/v2/available \
  -u "your_platform_name:your_platform_key"

A successful response returns `200 OK`. If you get `401`, double-check you're using the **integration** (sandbox) credentials, not production — they are issued separately.

> **Common mistake:** Using production credentials against the sandbox host, or vice versa. Tango's sandbox and production environments use different base URLs *and* different credentials — matching one but not the other fails silently with a generic auth error.

## 2. Set up your account

Confirm your platform is funded and active before placing orders:

curl https://integration-api.tangocard.com/raas/v2/accounts/your_account_identifier \
  -u "your_platform_name:your_platform_key"

Check the `currentBalance` field in the response. Sandbox accounts start with a test balance — no real funding is needed to complete this guide.

## 3. Browse the catalog

Before placing an order, fetch the list of available reward items (gift cards, prepaid cards, etc.) so you can select a valid `utid` (Universal Type ID):

import requests
from requests.auth import HTTPBasicAuth

response = requests.get(
    "https://integration-api.tangocard.com/raas/v2/catalogs/your_catalog",
    auth=HTTPBasicAuth("your_platform_name", "your_platform_key"),
)

rewards = response.json()["rewards"]
for reward in rewards[:5]:
    print(reward["utid"], reward["description"])

> **Common mistake:** Hardcoding a `utid` from documentation examples instead of pulling it from the live catalog. Reward availability varies by account and region — always resolve `utid` values dynamically.

## 4. Place your first order

curl -X POST https://integration-api.tangocard.com/raas/v2/orders \
  -u "your_platform_name:your_platform_key" \
  -H "Content-Type: application/json" \
  -d '{"accountIdentifier": "your_account_identifier", "amount": 10.00, "utid": "U123456", "recipient": {"email": "test-recipient@example.com", "firstName": "Ada", "lastName": "Lovelace"}, "sendEmail": true}'

A successful order returns `200 OK` with a `referenceOrderID` you should store for reconciliation.

> **Common mistake:** Omitting `sendEmail` or misreading its default — some integrators expect the recipient to be notified automatically and are surprised when no email arrives because this flag was left `false` (or omitted, depending on account configuration).

## 5. Verify delivery

curl https://integration-api.tangocard.com/raas/v2/orders/your_reference_order_id \
  -u "your_platform_name:your_platform_key"

Check `status` — sandbox orders resolve near-instantly; production orders may take longer depending on the reward type.

## Troubleshooting checklist

| Symptom | Likely cause |
|---|---|
| `401 Unauthorized` on every call | Sandbox/production credential mismatch |
| Order succeeds but recipient never gets an email | `sendEmail` not explicitly set to `true` |
| `utid` rejected as invalid | Catalog not queried live; stale or region-mismatched `utid` used |
| Balance errors on a funded account | Checking `currentBalance` on the wrong `accountIdentifier` |

---
*This guide was authored independently as a portfolio sample against Tango Card's publicly documented API. It is not official Tango Card documentation.*
