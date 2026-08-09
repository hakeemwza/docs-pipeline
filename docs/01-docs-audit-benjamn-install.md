# Documentation Audit & Rewrite: `benjamn/install`

**Type:** Docs Audit & Rewrite
**Target:** [`benjamn/install`](https://github.com/benjamn/install) — a low-level CommonJS module loader used internally by Meteor and Apollo.
**Scope:** README + inline usage docs only (no source code changes).

## Why this repo

`install` is a small, widely-depended-on utility with almost no prose documentation — the kind of gap that creates disproportionate support burden relative to the size of the library. It's a realistic stand-in for the audits a docs consultant is actually hired to do: not "write docs from nothing," but "fix docs that technically exist and technically explain nothing."

## Audit method

1. Read the README as a first-time integrator would — no prior context, no source diving.
2. Attempt each documented usage step literally, exactly as written.
3. Log every point where a reasonable reader would stall, guess, or need to open the source to proceed.
4. Classify each issue: **Missing Context**, **Buried Step**, **No Error Handling**, or **Ambiguous API Surface**.

## Findings (10 issues)

| # | Category | Issue |
|---|---|---|
| 1 | Missing Context | No explanation of *why* you'd reach for this over Node's native `require` — install exists to shim CommonJS semantics in bundled/browser contexts, but that motivation is never stated. |
| 2 | Buried Step | The registration call (`install(modules, options)`) is shown before the module map format it expects is defined. |
| 3 | Ambiguous API Surface | `options.extensions` accepts an array, but no default value or example array is given. |
| 4 | No Error Handling | No documented behavior for a missing module ID — the reader has to trigger the failure to learn it throws vs. returns `undefined`. |
| 5 | Missing Context | Interop with native ESM (`import`) is undocumented, despite being the most common integration question for a CJS shim in 2026. |
| 6 | Buried Step | Circular dependency handling is mentioned once, in a code comment, not in prose. |
| 7 | Ambiguous API Surface | `alias` vs `map` option difference is not explained — both affect resolution but do different things. |
| 8 | No Error Handling | No guidance on debugging a resolution failure (no equivalent of Node's `MODULE_NOT_FOUND` trace). |
| 9 | Missing Context | No minimal runnable example — every snippet is a fragment, none can be copy-pasted and executed as-is. |
| 10 | Buried Step | Browser bundler setup (webpack/Rollup) is referenced in an issue thread, not in the docs. |

## Rewrite approach

- Added a "Why use this" section (2 sentences, stated up front).
- Reordered content: concept → module map format → registration call → resolution behavior → error cases.
- Added one minimal, runnable example at the top, before any API reference detail.
- Added an explicit **Errors** section documenting the two failure modes (missing module, circular dependency) with the actual thrown error shape.
- Added a short **Bundler Setup** section consolidating the webpack/Rollup guidance that was previously scattered across GitHub issues.

## Decision log

| Change | Reasoning |
|---|---|
| Moved "Why use this" to the top | Readers decide relevance before they decide correctness — putting it first reduces bounce. |
| One runnable example before API reference | A working example anchors every subsequent reference detail to something the reader has already seen work. |
| Explicit Errors section | Undocumented failure modes are the #1 source of support tickets for infra-adjacent libraries; this section trades 90 seconds of read time for tickets that never get filed. |
| Consolidated bundler setup from issues into docs | Institutional knowledge trapped in issue threads doesn't scale — it should live where new users actually look. |

---
*This audit was produced as a portfolio sample. It reflects real documentation gaps observed in the public repository and a rewrite approach, but was not commissioned by or submitted to the `benjamn/install` maintainers.*
