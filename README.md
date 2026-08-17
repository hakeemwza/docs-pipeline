# docs-pipeline

CI-validated technical documentation. Docs treated as code, not static files.

## What this repo demonstrates

A docs-as-code workflow with four automated checks, run on every push and
pull request that touches `docs/` or `scripts/`:

| Check | Tool | Applies to |
|---|---|---|
| Prose style / linting | markdownlint | All docs |
| Broken link detection | lychee | All docs |
| Python sample syntax validation | `py_compile` | All docs with fenced `python` blocks |
| cURL sample validation against a live OpenAPI spec | Prism mock server | Docs with a published spec (see below) |

## Docs in this repo

- **`01-docs-audit-benjamn-install.md`** — documentation audit and rewrite
  proposal for the `benjamn/install` npm package. Prose only, no code
  samples to execute.
- **`02-api-reference-stripe-paymentintents.md`** — API reference for
  Stripe's PaymentIntents endpoint. cURL and Python examples are validated
  against a Prism mock server generated from Stripe's public OpenAPI spec.
- **`03-onboarding-guide-tango-api.md`** — onboarding guide for Tango
  Card's Rewards-as-a-Service API. Python examples are syntax-checked.
  **cURL examples are not validated against a live spec** — Tango does not
  publish a machine-readable OpenAPI spec, so there is nothing authoritative
  to validate against. This is a known, deliberate scope limit, not an
  oversight.

## Why the scope limit is stated explicitly

A docs pipeline that silently validates less than it implies is worse than
one that states its limits plainly. If Tango (or another target API)
publishes an OpenAPI spec in the future, adding it to the validation job is
a one-line change to `DOC_SPEC_MAP` in
`scripts/validate-curl-against-mock.sh` — the script was written to support
multiple docs from the start, not just the one it currently validates.

## Running locally

This pipeline is designed to run in GitHub Actions. If you want to run
individual checks locally, each script in `scripts/` can be run directly;
see the usage comment at the top of each file.

