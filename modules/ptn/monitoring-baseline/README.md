# Monitoring Baseline (scaffold)

> Status: scaffold only. `main.bicep` carries a `// TODO(author):` marker and is
> not yet implemented.

An opinionated monitoring baseline that composes Azure Verified Modules into a
reusable starting point: a Log Analytics workspace, action groups, and metric
and activity-log alerts, with diagnostics wired to the workspace.

## Planned composition

| AVM module | Purpose |
| --- | --- |
| `avm/res/operational-insights/workspace` | Central Log Analytics workspace. |
| `avm/res/insights/action-group` | Notification targets (email, webhook, etc.). |
| `avm/res/insights/metric-alert` | Resource metric alerts. |
| `avm/res/insights/activity-log-alert` | Control-plane (activity log) alerts. |

## When NOT to use this

- When you only need a workspace: consume `avm/res/operational-insights/workspace` directly.
- When you have a full observability platform (for example Azure Monitor
  baseline / AMBA): use that instead of this lightweight baseline.

Pin the latest GA AVM versions at implementation time and record them here.
