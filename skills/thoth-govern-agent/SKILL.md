---
name: thoth-govern-agent
description: Put an AI agent's tool calls behind Thoth runtime enforcement with the Python (atensec-thoth), TypeScript (@atensec/thoth) or Go (thoth-go) SDK, so every action is checked before it runs and returns ALLOW, STEP_UP or BLOCK. Use when adding Thoth to an agent, wrapping tools or a tool-dispatch loop, connecting with THOTH_TENANT_ID, THOTH_API_URL and THOTH_API_KEY, or verifying a first governed decision.
license: Apache-2.0
metadata:
  author: Aten Security
  docs: https://docs.atensecurity.com/docs/getting-started/your-agent
---

# Govern an agent's tool calls with Thoth

Thoth evaluates each proposed action before it executes and returns `ALLOW`,
`STEP_UP` (pause for an approver) or `BLOCK`. Your job is to make sure every
tool the agent can run goes through the SDK's governed wrapper, with no other
route to the original callback.

## Before you write code

1. Read the current guide for the user's language. Package versions and APIs
   change; take them from the page, not from memory:
   - Python: https://docs.atensecurity.com/docs/sdks/python.md
   - TypeScript: https://docs.atensecurity.com/docs/sdks/typescript.md
   - Go: https://docs.atensecurity.com/docs/sdks/go.md
   - LangGraph: https://docs.atensecurity.com/docs/sdks/langgraph-integration.md
   - Instrumenting an existing agent: https://docs.atensecurity.com/docs/getting-started/your-agent.md
2. Find how the agent actually executes tools: a `.tools` list, a function
   map, a model tool loop, framework dispatch (LangGraph `ToolNode`), or an
   external MCP server. Wrap that execution path. Wrapping only the model
   client is not enough.
3. Confirm with the user which agent ID and exact tool names to use, and that
   their administrator has (or will) configure policy for them.

## Connection settings

The SDK needs three values from the user's tenant, read from the environment:

```bash
export THOTH_TENANT_ID="<tenant-id>"
export THOTH_API_URL="<unified tenant API base URL>"   # not .../v1/enforce, not the GovAPI admin URL
export THOTH_API_KEY="<runtime execute key>"            # load from a secret manager or private file
export THOTH_FAIL_OPEN=false
```

- Never write keys into source, config files, examples or logs. Reference
  environment variables or the user's secret manager.
- The agent process gets a runtime **execute** key only. Organization
  read/write keys belong to configuration workflows (Terraform, Pulumi,
  `thothctl`), never to the agent.
- Do not guess hostnames. If a value is missing, ask the user for it.

## Rules that must hold in the code you write

- **Fail closed.** Keep fail-open disabled (`THOTH_FAIL_OPEN=false`,
  `failOpen: false`, `FailOpen: false`). Fail-open can let actions run when no
  decision was obtained.
- **No bypass.** Never catch a refusal (`ThothPolicyViolation` in Python and
  TypeScript, `*thoth.PolicyViolationError` in Go) and call the raw tool as a
  fallback. Never keep an alternate import or code path to the original
  callback.
- **Reject unknown tools** before dispatch. The model may choose a name and
  arguments; your code dispatches only through the governed map.
- **`approved_scope` is context, not permission.** Listing a tool there does
  not create server policy and does not grant anything.
- **Identity comes from the application.** Set `user_id` / `userId` /
  `UserID` from the identity your application authenticated, never from
  model output. Use a distinct session ID per request or job; don't share one
  process-wide session across users.
- **`STEP_UP` pauses.** Let the SDK's approval flow resolve. Do not run the
  callback while a hold is pending, or after denial, expiry or an error.
- **Observe mode does not enforce.** Python observe mode bypasses the
  enforcer; use an enforcing mode to verify behaviour.
- Keep secrets and unnecessary personal data out of tool arguments, results
  and metadata.

## Workflow

1. Start with one read-only tool and a distinct agent ID.
2. Install the SDK version given in the language guide and wrap the
   execution path using the adapter the guide recommends for the framework.
3. Handle the outcomes:
   - `ALLOW`: run the governed callback and return its result.
   - `STEP_UP`: keep the action paused until the approval flow resolves.
   - `BLOCK`: return a clear, safe refusal or escalate through the approved
     workflow.
   - Authentication, rate-limit or transport error: surface it and fix it. A
     fail-closed refusal caused by an error is not a policy block.
4. Verify with the user against their tenant:
   - one permitted call runs and returns its result;
   - one refused call never executes its callback;
   - both decisions appear in decision history with the expected reason,
     agent, actor and session.
5. Add further tools one at a time, repeating the verification. Re-verify
   after changing tools, policies, SDK versions or identity handling.

For a trial, the first-agent guide uses the `trial-demo` agent with
`demo.read` (allowed) and `shell.exec` (blocked):
https://docs.atensecurity.com/docs/getting-started/quickstart.md. A `BLOCK`
there quarantines `trial-demo`; an administrator restores it under
**Agents → trial-demo → Restore Agent** before re-running.

## Related skills

- Writing or choosing policy: `thoth-policies`
- Settings as code, keys, the configuration MCP server: `thoth-configure`
- MCP servers used from a desktop client: `thoth-mcp-proxy`
- Unexpected decisions or errors: `thoth-troubleshoot`
