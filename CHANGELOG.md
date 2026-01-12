## Unreleased

- Add `continue_after_action` to custom buttons to opt into auto-advance after the action.
- Remove special handling for `noop` custom actions.
- Add `OptionItem.isSelected` to allow preselected inline options.
- Clarify that answer persistence lives in app callbacks (no plugin storage).
- Replace `closeOnLastStepAction` with `closeBehavior` (`after_action`, `close_button`) and add last-step close button support.

## 0.2.0

- Add slug-based step schema with per-step buttons, dismissible steps, and closeOnLastStepAction.
- Add gatekeeper/onSubmit/optionsBuilder hooks for dynamic onboarding.
- Emit push events for delivery, steps, buttons, submits, and gate blocks.
- Add debug injection hook for message ID display pipeline tests.
- Render Markdown/HTML step bodies with image support.

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
