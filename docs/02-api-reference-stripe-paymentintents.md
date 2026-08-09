# API Reference: Create a PaymentIntent

**Type:** API Reference Doc
**Endpoint:** `POST /v1/payment_intents`
**Target API:** Stripe PaymentIntents API (public, documented for reference/demonstration purposes)

## Overview

A `PaymentIntent` tracks the lifecycle of a customer payment through every state — from creation, through any required authentication, to a terminal `succeeded`, `canceled`, or failed status. Creating one is the first step in almost every Stripe integration.

## Request

POST https://api.stripe.com/v1/payment_intents

### Headers

| Header | Value |
|---|---|
| `Authorization` | `Bearer sk_test_...` (your secret key) |
| `Content-Type` | `application/x-www-form-urlencoded` |

### Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `amount` | integer | Yes | Amount in the smallest currency unit (e.g., cents for USD). Must be a positive integer. |
| `currency` | string | Yes | Three-letter ISO currency code, lowercase (e.g., `usd`). |
| `automatic_payment_methods[enabled]` | boolean | No | If `true`, Stripe selects payment methods automatically based on the currency and location. Recommended default. |
| `payment_method_types[]` | array of strings | No | Explicit list of payment method types, if not using automatic selection. |
| `customer` | string | No | ID of an existing Customer this PaymentIntent belongs to. |
| `description` | string | No | Arbitrary string attached to the PaymentIntent, shown in the Stripe Dashboard. |
| `metadata` | map | No | Up to 50 key-value pairs for storing structured, queryable information. |

## Example request

### cURL

curl https://api.stripe.com/v1/payment_intents \
  -u sk_test_51ABC...: \
  -d amount=2000 \
  -d currency=usd \
  -d "automatic_payment_methods[enabled]"=true \
  -d description="Portfolio sample charge"

### Python

import stripe

stripe.api_key = "sk_test_51ABC..."

intent = stripe.PaymentIntent.create(
    amount=2000,
    currency="usd",
    automatic_payment_methods={"enabled": True},
    description="Portfolio sample charge",
)

print(intent.id, intent.status)

## Response

A successful request returns `200 OK` with a `payment_intent` object.

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

### Key response fields

| Field | Description |
|---|---|
| `id` | Unique identifier, prefixed `pi_`. Use this to retrieve or update the PaymentIntent later. |
| `status` | Current lifecycle state. Starts at `requires_payment_method` immediately after creation. |
| `client_secret` | Passed to your client-side integration to complete the payment. Treat as sensitive — do not log or expose beyond the intended client. |

## Errors

| HTTP Status | Error Code | Meaning | Fix |
|---|---|---|---|
| `400` | `parameter_missing` | `amount` or `currency` omitted | Include both required parameters. |
| `400` | `parameter_invalid_integer` | `amount` is not a positive integer | Convert to the smallest currency unit as an integer (e.g., `$20.00` → `2000`). |
| `401` | `api_key_expired` / invalid key | Bad or revoked secret key | Regenerate the key in the Stripe Dashboard and update your environment variable. |
| `402` | `card_declined` | Underlying payment method was declined at confirmation time (not at creation) | Surface the `decline_code` to the customer; do not retry the same payment method automatically. |
| `429` | `rate_limit` | Too many requests in a short window | Implement exponential backoff; Stripe's official SDKs do this by default. |

## Notes

- Creating a PaymentIntent does not move money. It only happens on confirmation, once a payment method is attached.
- `amount` is always an integer in the smallest currency unit — this is the single most common integration bug in first-time implementations.

---
*This reference was authored independently as a portfolio sample against Stripe's publicly documented API. It is not official Stripe documentation.*
