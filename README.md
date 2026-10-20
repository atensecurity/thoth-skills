# Thoth skills for AI coding agents

Skills that teach Claude Code, Codex and other agents how to work with
[Thoth](https://docs.atensecurity.com), the runtime enforcement layer for AI
agents by Aten Security. Thoth evaluates each agent action before it executes
and returns `ALLOW`, `STEP_UP` or `BLOCK`.

| Skill | Helps your agent |
| --- | --- |
| `thoth-govern-agent` | Put an agent's tool calls behind Thoth with the Python, TypeScript or Go SDK, and verify the first decisions |
| `thoth-policies` | Choose a profile, confirm tool declarations and action classes, write `action_class` rules, plan approvals |
| `thoth-configure` | Configure Thoth with Terraform, Pulumi, `thothctl` or the Thoth configuration MCP server |
| `thoth-mcp-proxy` | Govern MCP servers used by Claude Desktop, Claude Code or Cursor with the `thoth` proxy |
| `thoth-troubleshoot` | Tell a policy refusal from a service error, read a decision's explanation, recover a quarantined agent |

The skills follow the open [Agent Skills](https://agentskills.io) format. They
link to the live Thoth documentation for versions and exact APIs, so they stay
current as Thoth changes.

## Install

### Claude Code

```bash
claude plugin marketplace add atensecurity/thoth-skills
claude plugin install thoth@atensecurity
```

Or, inside a session: `/plugin install thoth --marketplace atensecurity/thoth-skills`.
Update with `claude plugin update thoth@atensecurity`.

### Codex

```bash
codex plugin marketplace add atensecurity/thoth-skills
codex plugin add thoth@atensecurity
```

Or open `/plugins` in Codex and install **Thoth** from the Aten Security
marketplace. Update with `codex plugin marketplace upgrade atensecurity`.

### Other agents

Copy the folders under `skills/` into your agent's skills directory, for
example `.agents/skills/` in a repository (shared with your team) or
`~/.agents/skills/` for yourself.

## Use

Ask your agent in plain language, for example:

- "Put this agent's tool calls behind Thoth."
- "Which Thoth profile fits this agent, and what would it step up or block?"
- "Manage our Thoth governance settings in Terraform."
- "Why did Thoth refuse this tool call?"

You need a Thoth workspace. Start a trial at
[start.atensecurity.com](https://start.atensecurity.com/trial). Your agent
will ask for your tenant ID, API URL and key; keep keys in environment
variables or a secret manager, never in code.

## What the skills will and won't do

- They keep enforcement fail-closed and never add a fallback that calls a tool
  without a Thoth decision.
- They show a plan or a server-generated preview before any configuration
  change, and configuration commits made while signed in need your approval in
  the browser.
- They don't make compliance or certification claims.

## Support

Documentation: [docs.atensecurity.com/docs/agent-skills](https://docs.atensecurity.com/docs/agent-skills).
Questions: support@atensecurity.com.

This repository is published from the Aten Security monorepo; pull requests
here are reviewed and applied upstream.

## License

Apache-2.0. See [LICENSE](LICENSE).
