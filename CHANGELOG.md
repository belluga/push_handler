## 0.1.3

- Add an optional presentation gate to defer UI until app readiness.
- Ensure background queue flush does not block app init.
- Keep only the latest queued push and clear queue on tap/open.
- De-duplicate concurrent presentations for the same push id.

## 0.1.2

- Add `enableDebugLogs` to `PushTransportConfig` and persist it in secure storage.
- Gate push debug logging across repository init/queue, background entrypoint/reporting, and action reporting.
- Add `test` dev dependency for package tests.

## 0.1.0

- Upgrade SDK and dependencies for current Flutter versions.
- Document package usage and payload format.

## 0.0.1

* TODO: Describe initial release.
