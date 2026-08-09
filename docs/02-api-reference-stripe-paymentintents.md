# API Reference: Create a PaymentIntent

**Type:** API Reference Doc
**Endpoint:** `POST /v1/payment_intents`
**Target API:** Stripe PaymentIntents API (public, documented for reference/demonstration purposes)

## Overview

A `PaymentIntent` tracks the lifecycle of a customer payment through every state — from creation, through any required authentication, to a terminal `succeeded`, `canceled`, or failed status. Creating one is the first step in almost every Stripe integration.

## Request

https://api.stripe.com/v1/payment_intents


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

```bash
curl https://api.stripe.com/v1/payment_intents \
  -u sk_test_51ABC...: \
  -d amount=2000 \
  -d currency=usd \
  -d "automatic_payment_methods[enabled]"=true \
  -d description="Portfolio sample charge"
import stripe

stripe.api_key = "sk_test_51ABC..."

intent = stripe.PaymentIntent.create(
    amount=2000,
    currency="usd",
    automatic_payment_methods={"enabled": True},
    description="Portfolio sample charge",
)

print(intent.id, intent.status)
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
