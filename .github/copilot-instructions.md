This repository is a HarmonyOS application built with ArkTS/ETS and Hvigor.

When reviewing pull requests in this repository:

- Prioritize correctness, regressions, crashes, permission issues, lifecycle mistakes, broken navigation, resource loading failures, and missing null or error handling.
- Focus on user-visible behavior and production risks before maintainability concerns.
- Do not spend review budget on formatting-only or naming-only comments unless they hide a real bug.

Project-specific guidance:

- Main app code is under `entry/src/main/ets/`.
- Pay close attention to `EntryAbility.ets`, page files such as `pages/Index.ets`, and `module.json5` changes.
- For ArkUI state updates, check whether state is declared and updated in a way that will actually refresh the UI.
- For async work, check for unhandled failures, stale state, and lifecycle-related issues.
- For resource references, verify that files under `resources/` and `rawfile/` match the code that loads them.
- For `module.json5` or capability changes, verify that required permissions, abilities, and routing configuration stay consistent.

Testing guidance:

- Prefer pointing out missing tests only when the change introduces meaningful logic or a regression risk.
- If you report a problem, explain the concrete failure mode briefly and reference the affected file and line.

Files and areas that usually do not need detailed review unless they affect behavior:

- `build/`
- `.hvigor/`
- `oh_modules/`
- lockfiles and generated artifacts
