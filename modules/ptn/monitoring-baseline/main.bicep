metadata name = 'Monitoring Baseline'
metadata description = 'Opinionated monitoring baseline that composes a Log Analytics workspace, action groups, and metric and activity-log alerts, with diagnostics wired to the workspace. Scaffold only in this release.'

/*=====================================================
SUMMARY: Monitoring Baseline - opinionated monitoring composition.
DESCRIPTION: Planned pattern module composing AVM monitoring resource modules
into a reusable baseline. Not yet implemented.
AUTHOR/S: Marcin Biszczanik
VERSION: 0.1.0
=====================================================*/

targetScope = 'resourceGroup'

// TODO(author): implement. Planned composition (pin latest GA at build time):
//   - br/public:avm/res/operational-insights/workspace  (the central workspace)
//   - br/public:avm/res/insights/action-group           (notification targets)
//   - br/public:avm/res/insights/metric-alert           (resource metric alerts)
//   - br/public:avm/res/insights/activity-log-alert     (control-plane alerts)
// Each composed resource sends its diagnostics to the workspace via the
// built-in diagnosticSettings parameter (AVM has no separate diagnostics module).
