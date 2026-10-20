---
name: thoth-troubleshoot
description: "Diagnose unexpected Thoth decisions and errors in governed agents: tell a policy refusal (BLOCK or STEP_UP) apart from an authentication, rate-limit or transport failure, read the recorded explanation of a decision, fix 401/403 key problems, and recover a quarantined agent. Use when a governed tool is refused or held unexpectedly, ThothPolicyViolation or PolicyViolationError appears, the SDK can't reach Thoth, or a user asks why Thoth made a decision."
license: Apache-2.0
metadata:
  author: Aten Security
  docs: https://docs.atensecurity.com/docs/getting-started/troubleshooting
---

# Troubleshoot Thoth decisions and errors

Start by separating two very different things. SDKs fail closed, so a
refusal exception can mean either:

- **A policy decision**: the server evaluated the action and returned
  `BLOCK` or `STEP_UP`. It has a reason and a correlation ID in decision
  history.
- **A failure to get a decision**: bad key, wrong endpoint, rate limit,
  network or service error. No policy blocked the tool.

Never "fix" either by calling the raw tool or enabling fail-open. Reference:
https://docs.atensecurity.com/docs/getting-started/troubleshooting.md

## Read the decision

- The SDK refusal carries a reason (`refusal.reason` / message). Find the
  same decision in decision history by agent, session and time, with its
  correlation ID.
- Get the recorded explanation from the explain API
  (https://docs.atensecurity.com/docs/api-reference/explain.md) or, from an AI
  client connected to the configuration MCP server, the `explain_decision`
  tool. Quote the server's explanation; don't reconstruct one.

## Common causes

| Symptom | Check |
| --- | --- |
| Import or package not found | Python package `atensec-thoth` (import `thoth`) in the active virtualenv; TypeScript `@atensec/thoth` on Node.js 22+; Go `github.com/atensecurity/thoth-go` |
| Missing tenant, endpoint or key | `THOTH_TENANT_ID`, `THOTH_API_URL`, `THOTH_API_KEY` set in the same shell; base URL without `/v1/enforce`; not the GovAPI admin URL |
| 401 or 403 | Key expired, bound to another tenant, or missing execute permission. Providers need a separate organization read/write key. Keys show once; rotate through an administrator |
| 429, timeouts, 5xx | Honour retry guidance, avoid tight retry loops, keep fail-open off. A refusal here is not a policy block |
| Unexpected `STEP_UP` | Tool unconfirmed (`unknown` class) or a class `safe-default` reviews (execute, delete, export, external call, bulk, credentials). See `thoth-policies` |
| Unexpected `BLOCK` | Hard constraints (blocklist, quarantine, quota), a profile's named rule, or sensitive data leaving |
| Everything refused after a `BLOCK` | The agent may be quarantined. An administrator restores it (trial demo: **Agents → trial-demo → Restore Agent**) |
| Changed `approved_scope`, decision unchanged | Expected. Scope is context; it doesn't install policy |
| Activation progress moved but result looks wrong | Progress records the first finalized decision, including refusals. Check decision history |

## Asking for help

Collect the SDK and version, timestamp, agent ID, the sanitized error and the
correlation ID, plus the expected and observed decision. Remove keys, hold
tokens, personal data and private tool arguments before sharing. Trial users
contact their support channel or support@atensecurity.com.
