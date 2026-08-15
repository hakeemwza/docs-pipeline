# API Reference: Create a PaymentIntent

**Type:** API Reference Doc
**Endpoint:** `POST /v1/payment_intents`
**Target API:** Stripe PaymentIntents API (public, documented for reference/demonstration
purposes)

## Overview

A `PaymentIntent` tracks the lifecycle of a customer payment through every state — from
creation, through any required authentication, to a terminal `succeeded`, `canceled`, or
failed status. Cre[...]

## Request

[POST https://api.stripe.com/v1/payment_intents](https://api.stripe.com/v1/payment_intents)

### Headers

| Header | Value |
|---|---|
| `Authorization` | `Bearer sk_test_...` (your secret key) |
| `Content-Type` | `application/x-www-form-urlencoded` |

### Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `amount` | integer | Yes | Amount in smallest currency unit (cents for USD). |
| `currency` | string | Yes | Three-letter ISO currency code, lowercase (e.g., `usd`). |
| `automatic_payment_methods[enabled]` | boolean | No | If `true`, Stripe selects payment methods. |
| `payment_method_types[]` | array | No | Explicit list of payment method types if not using automatic. |
| `customer` | string | No | ID of an existing Customer this PaymentIntent belongs to. |
| `description` | string | No | Arbitrary string attached to the PaymentIntent. |
| `metadata` | map | No | Up to 50 key-value pairs for storing structured information. |

## Example request

### cURL

```
curl [https://api.stripe.com/v1/payment_intents](https://api.stripe.com/v1/payment_intents) \
  -u sk_test_51ABC...: \
  -d amount=2000 \
  -d currency=usd \
  -d "automatic_payment_methods[enabled]"=true \
  -d description="Portfolio sample charge"
```

### Python

```python
import stripe

stripe.api_key = "sk_test_51ABC..."

intent = stripe.PaymentIntent.create(
    amount=2000,
    currency="usd",
    automatic_payment_methods={"enabled": True},
    description="Portfolio sample charge",
)

print(intent.id, intent.status)
```

## Response

A successful request returns `200 OK` with a `payment_intent` object.

```json
{
  "id": "pi_3ABC123XYZ",
  "object": "payment_intent",
  "amount": 2000,
  "currency": "usd",
  "status": "requires_payment_method",
  "client_secret": "pi_3ABC123XYZ_secret_abc123",
  "description": "Portfolio sample charge",
  "created": 1751000000,
  "livemode": false
}
```

### Key response fields

| Field | Description |
|---|---|
| `id` | Unique identifier prefixed `pi_`. Use to retrieve or update later. |
| `status` | Current lifecycle state. Starts at `requires_payment_method`. |
| `client_secret` | Passed to client-side integration to complete payment. Treat as  |
| | sensitive — do not log or expose beyond the intended client. |

## Errors

| HTTP Status | Error Code | Meaning | Fix |
|---|---|---|---|
| `400` | `parameter_missing` | `amount` or `currency` omitted | Include both required parameters. |
| `400` | `parameter_invalid_integer` | `amount` is not a positive integer | Convert to smallest unit (e.g., `$20.00` → `2000`). |
| `401` | `api_key_expired` | Bad or revoked secret key | Regenerate the key in the Stripe Dashboard. |
| `402` | `card_declined` | Payment declined at confirmation time | Surface `decline_code` to customer. |
| `429` | `rate_limit` | Too many requests in short window | Implement exponential backoff. |

## Notes

- Creating a PaymentIntent does not move money. It only happens on confirmation, once a
  payment method is attached.
- `amount` is always an integer in the smallest currency unit — this is the single most
  common integration bug in first-time implementations.

---

*This reference was authored independently as a portfolio sample against Stripe's publicly
documented API. It is not official Stripe documentation.*
