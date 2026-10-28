# Thoth skills for AI coding agents

Skills that teach Claude Code, Codex and other agents how to work with
[Thoth](https://docs.atensecurity.com), the runtime enforcement layer for AI
agents by Aten Security. Thoth evaluates each agent action before it executes
and returns `ALLOW`, `STEP_UP` or `BLOCK` (shown as `DENY` in the dashboard
and `thothctl`).

| Skill | Helps your agent |
| --- | --- |
| `thoth-govern-agent` | Put an agent's tool calls behind Thoth with the Python, TypeScript or Go SDK, roll it out in observe mode, and verify the first decisions |
| `thoth-policies` | Choose a profile, confirm tool declarations, write policy rules (`thoth_policy`, `thothctl governance policies`), move agents from observe to enforce, handle exceptions |
| `thoth-configure` | Configure Thoth with Terraform, Pulumi, `thothctl` or the Thoth configuration MCP server, including team, sign-in security, fleets and endpoints |
| `thoth-mcp-proxy` | Govern MCP servers used by Claude Desktop, Claude Code or Cursor with the `thoth` proxy, and manage the endpoints it runs on |
| `thoth-troubleshoot` | Tell a policy refusal from a service error or a billing limit, read a decision's explanation, resolve held actions, recover a quarantined agent or endpoint |

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
curl -fsSL https://raw.githubusercontent.com/atensecurity/thoth-skills/main/install.sh | sh
```

This installs the skills into `~/.agents/skills`, where Codex loads them
automatically (restart Codex if they don't appear). Run it again to update.
Options: `--project` installs into `./.agents/skills` for one repository,
`--ref <tag>` installs a specific release, and `--uninstall` removes them. To
read the script first, open
[`install.sh`](https://github.com/atensecurity/thoth-skills/blob/main/install.sh).

A Codex plugin listing is pending OpenAI's review; until then, use the script.

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

## What the skills connect to

The plugin contains instructions only: no hooks, scripts, MCP servers or
bundled code, and it sends nothing on its own. When you use a skill, your agent
may make these requests with your tools and credentials:

- **Thoth documentation.** It reads public pages from
  `https://docs.atensecurity.com` (Markdown pages and `llms.txt`) to get current
  versions and APIs. These requests carry no data from your session.
- **Your Thoth workspace, when you ask.** It runs the tools you choose
  (`thothctl`, the Terraform or Pulumi provider, the Thoth SDKs, or the Thoth
  configuration MCP server) against your own workspace, which sends the
  configuration changes and decision requests you approve. Your workspace
  keeps its configuration and decision evidence under your agreement with Aten
  Security and the [privacy policy](https://atensecurity.com/legal/privacy/).
- **Package registries, when you install something.** Installing an SDK,
  provider or the `thoth` CLI fetches it from where it is published: PyPI, npm,
  the Go module proxy, the Terraform Registry, or the release channel named in
  the Thoth docs.

## Support

Documentation: [docs.atensecurity.com/docs/agent-skills](https://docs.atensecurity.com/docs/agent-skills).
Help: [atensecurity.com/support](https://atensecurity.com/support/) or
support@atensecurity.com.

This repository is published from the Aten Security monorepo; pull requests
here are reviewed and applied upstream.

## License

Apache-2.0. See [LICENSE](LICENSE).
