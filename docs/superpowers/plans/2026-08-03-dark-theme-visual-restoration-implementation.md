# Dark Theme Visual Restoration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Recreate the supplied night-mode references without changing light mode, decision behavior, navigation, persistence, or responsive layout structure.

**Architecture:** Keep `ThemeResolver` as the only deep/light branching point. Add visual-only theme tokens and pass the existing `ThemeTokens` to shared components; each page then uses those tokens for its reference-specific treatment while retaining its existing state, callbacks and scroll containers.

**Tech Stack:** HarmonyOS API 24, ArkTS, ArkUI, Hypium, Hvigor.

---

## File map

- Modify `entry/src/main/ets/constants/DesignTokens.ets`: deep-night palette and visual token contract.
- Modify `entry/src/main/ets/components/common/AppCard.ets`, `AppButton.ets`, `AppInput.ets`, `PageHeader.ets`: shared dark-only surface, border, button and header treatment.
- Modify `entry/src/main/ets/components/decision/OptionsEditor.ets`, `WheelCanvas.ets`, `DrawTube.ets`, `CoinView.ets`: editable rows and decision illustrations.
- Modify `entry/src/main/ets/pages/Index.ets`, `Wheel.ets`, `Draw.ets`, `FingerSelect.ets`, `Coin.ets`, `YesNo.ets`, `RandomNumber.ets`: only local deep-night layout styling and reference decoration.
- Modify `entry/src/ohosTest/ets/test/ThemeResolver.test.ets`, `VisualTokens.test.ets`: token and light-theme regression assertions.
- Modify `entry/src/ohosTest/ets/test/List.test.ets`: retain test registration if a new visual-token test is split out.
- Modify `tasks.md`, `design.md`, `changes.md`, `design-qa.md`: task state, implementation description and actual QA evidence.

### Task 1: Lock the deep-night token contract

**Files:**
- Modify: `entry/src/ohosTest/ets/test/ThemeResolver.test.ets`
- Modify: `entry/src/ohosTest/ets/test/VisualTokens.test.ets`
- Modify: `entry/src/main/ets/constants/DesignTokens.ets`

- [ ] **Step 1: Add failing assertions for the deep-night palette and light isolation.**

```ts
it('returnsReferenceDeepNightTokens', 0, (): void => {
  const tokens: ThemeTokens = ThemeResolver.resolve(ThemeMode.DARK, false);
  expect(tokens.background).assertEqual('#071426');
  expect(tokens.card).assertEqual('#101E35');
  expect(tokens.input).assertEqual('#0C1930');
  expect(tokens.primaryStart).assertEqual('#2E83FF');
  expect(tokens.primaryEnd).assertEqual('#1748D4');
  expect(tokens.isDark).assertTrue();
});

it('keepsLightTokensUnchanged', 0, (): void => {
  const tokens: ThemeTokens = ThemeResolver.resolve(ThemeMode.LIGHT, true);
  expect(tokens.background).assertEqual(AppColors.LIGHT_BACKGROUND);
  expect(tokens.card).assertEqual(AppColors.LIGHT_CARD);
  expect(tokens.isDark).assertFalse();
});
```

- [ ] **Step 2: Build the ohosTest module and verify the test fails because `ThemeTokens` has no visual fields.**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -Target ohosTest`

Expected: compilation failure naming missing `input`, `primaryStart`, `primaryEnd` and `isDark` properties.

- [ ] **Step 3: Add only visual fields to `ThemeTokens` and fill both branches.**

```ts
export interface ThemeTokens {
  background: string;
  card: string;
  input: string;
  text: string;
  subtext: string;
  border: string;
  accent: string;
  primaryStart: string;
  primaryEnd: string;
  glow: string;
  shadow: string;
  isDark: boolean;
  error: string;
  success: string;
}
```

Use the reference values above in the dark branch, `input: AppColors.LIGHT_CARD`, `primaryStart: AppColors.PRIMARY`, `primaryEnd: AppColors.PRIMARY`, transparent `glow`, current shadow and `isDark: false` in the light branch. Do not alter `WHEEL_COLORS`, app limits, typography or spacing constants.

- [ ] **Step 4: Rebuild the test HAP and verify it passes.**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -Target ohosTest`

Expected: `BUILD SUCCESSFUL`.

### Task 2: Apply tokens to reusable controls

**Files:**
- Modify: `entry/src/main/ets/components/common/AppCard.ets`
- Modify: `entry/src/main/ets/components/common/AppButton.ets`
- Modify: `entry/src/main/ets/components/common/AppInput.ets`
- Modify: `entry/src/main/ets/components/common/PageHeader.ets`
- Modify: all existing `AppButton` call sites listed by `rg -n "AppButton\\(" entry/src/main/ets`

- [ ] **Step 1: Add a failing source-level visual assertion.**

Add to `VisualTokens.test.ets`:

```ts
it('preservesApprovedPhoneMetrics', 0, (): void => {
  expect(AppSpacing.PAGE_HORIZONTAL).assertEqual(16);
  expect(AppRadii.CARD).assertEqual(12);
  expect(AppRadii.PRIMARY_BUTTON).assertEqual(10);
  expect(AppFontSizes.PAGE_TITLE).assertEqual(22);
});
```

Temporarily expect the new deep-night `AppRadii.ICON_BUTTON` value of `14`; run the test HAP and observe the assertion/compile failure before changing that constant.

- [ ] **Step 2: Implement shared visual treatment without altering sizing or callbacks.**

Add `@Prop colors: ThemeTokens` to `AppButton`, and supply it at every existing call site. Implement its colors as follows:

```ts
private buttonBackground(): string {
  if (this.variant === AppButtonVariant.TEXT) return '#00000000';
  if (this.variant === AppButtonVariant.SECONDARY) return this.colors.card;
  if (this.variant === AppButtonVariant.DANGER) return this.colors.error;
  return this.colors.primaryStart;
}
```

Keep the public `label`, `variant`, `isEnabled`, `fullWidth`, `buttonHeight`, `radius` and `onPress` contract unchanged. In `AppCard`, `AppInput` and `PageHeader`, use `colors.input`, `colors.border`, `colors.shadow` and `colors.glow`; apply 1vp borders in deep mode and preserve the current light values. Keep the 48vp back-button hit target and all current widths/heights.

- [ ] **Step 3: Build both modules.**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1`

Expected: main and ohosTest HAP output `BUILD SUCCESSFUL`; no ArkTS prop or call-site errors.

### Task 3: Restore decision surfaces and illustrations

**Files:**
- Modify: `entry/src/main/ets/components/decision/OptionsEditor.ets`
- Modify: `entry/src/main/ets/components/decision/WheelCanvas.ets`
- Modify: `entry/src/main/ets/components/decision/DrawTube.ets`
- Modify: `entry/src/main/ets/components/decision/CoinView.ets`

- [ ] **Step 1: Extend the token test before implementation.**

```ts
it('keepsDeepNightWheelAccentReadable', 0, (): void => {
  const tokens: ThemeTokens = ThemeResolver.resolve(ThemeMode.DARK, false);
  expect(tokens.accent).assertEqual(AppColors.PRIMARY);
  expect(tokens.border).assertEqual('#294361');
});
```

- [ ] **Step 2: Implement the visual-only component updates.**

In `OptionsEditor`, make row and input backgrounds `colors.card`/`colors.input`, retain 44vp inputs, dashed add button and all remove/move callbacks. In `WheelCanvas`, use a high-contrast deep palette only when `colors.isDark`, retain the light `WHEEL_COLORS`, use `colors.text` for labels, `colors.card`/`colors.border` for center, and add only a visual blue pointer glow. In `DrawTube` and `CoinView`, preserve the resource names, animation props and dimensions; use `colors.glow` and deep surfaces for label/reveal treatment.

- [ ] **Step 3: Build main and test HAPs.**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1`

Expected: `BUILD SUCCESSFUL`; no resource-name, Canvas API or type errors.

### Task 4: Apply reference hierarchy to home, wheel and draw

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/pages/Wheel.ets`
- Modify: `entry/src/main/ets/pages/Draw.ets`

- [ ] **Step 1: Preserve geometry with a regression check.**

Keep the existing VisualTokens assertions for 16vp horizontal gutters, 12vp cards, 10vp primary buttons and 22fp page headers. Build test HAP before styling and record it passes.

- [ ] **Step 2: Apply local deep-only styling.**

Keep the existing two-column home `Grid`, template rows, page `Scroll`, max-width constraints and all click handlers. Adjust only deep theme card borders/shadows, header action plates, image sizing inside their existing bounds and page spacing to match the four references. Keep wheel options, `spin`, `draw`, repeat toggle, `OptionsEditor`, template dialog and ResultSheet calls identical; change surfaces, glows, pointer/illustration presentation and button hierarchy only.

- [ ] **Step 3: Build and inspect with dark theme enabled.**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1`

Expected: `BUILD SUCCESSFUL`. If the API 24 phone is available, capture home, a 2-option wheel, a 5/6-option template wheel, and a draw page in dark mode.

### Task 5: Apply reference hierarchy to simple decision pages

**Files:**
- Modify: `entry/src/main/ets/pages/FingerSelect.ets`
- Modify: `entry/src/main/ets/pages/Coin.ets`
- Modify: `entry/src/main/ets/pages/YesNo.ets`
- Modify: `entry/src/main/ets/pages/RandomNumber.ets`

- [ ] **Step 1: Verify the state-machine test suite before page changes.**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1 -Target ohosTest`

Expected: `BUILD SUCCESSFUL`; `FingerSelectionMachine`, `SimpleDecisionState` and `RandomService` tests remain registered in `List.test.ets`.

- [ ] **Step 2: Apply only deep-night presentation.**

Retain finger `onTouch`, timers and active-point rendering; maintain the full-screen touch surface and use the existing guide image. Retain coin session/counts/flip; use the existing coin image and deep-night stats/question cards. Retain yes/no `decide` calls and choose buttons; make the affirmative circle blue-glowing only in dark mode and leave the negative control subdued. Retain random parsing, preset matching and generation; style range cards, numeric inputs, selected preset and result card via tokens. Do not change TextInput types, toggle state, button labels or callback code.

- [ ] **Step 3: Rebuild both modules.**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1`

Expected: main and ohosTest `BUILD SUCCESSFUL`.

### Task 6: Verify, document and isolate the finished change

**Files:**
- Modify: `tasks.md`
- Modify: `design.md`
- Modify: `changes.md`
- Modify: `design-qa.md`
- Create: `docs/qa/2026-08-03-dark-theme-visual-restoration.md`
- Create: `docs/qa/screenshots/2026-08-03-dark-*.jpeg` (only if captured)

- [ ] **Step 1: Run static standard checks.**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1`

Expected: success, with any pre-existing `common/` or `2in1` suggestions recorded as non-blocking only when the script reports them.

- [ ] **Step 2: Build release artifacts.**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1`

Expected: primary and test HAP `BUILD SUCCESSFUL`.

- [ ] **Step 3: Perform available-device verification.**

Enable deep mode, then verify home, wheel, draw, finger, coin, yes/no and random number for readable text, reachable controls, preserved scrolling, option editing, result close/retry and light-mode unchanged. Save real screenshots and list only executed actions in the QA note; mark unavailable phone/tablet checks `blocked`.

- [ ] **Step 4: Update project records.**

Mark `T-20260803-012` `done` only after successful checks. In `design.md` record the deep-token approach and unchanged behavior boundaries; in `changes.md` list visual-only changes; in `design-qa.md` link QA evidence and state actual device status.

- [ ] **Step 5: Review the final diff before any commit.**

Run: `git diff --check` and `git status --short`.

Expected: no whitespace errors. Do not stage or commit unrelated pre-existing modifications; commit only after the user explicitly requests a commit or a clean isolated staging set is available.

## Self-review

- Spec coverage: Tasks 1–3 implement the shared deep-night system; Tasks 4–5 map every page in the supplied four references; Task 6 covers documentation and verification.
- Placeholder scan: no deferred implementation markers or undefined token names remain.
- Type consistency: every proposed visual token is declared in `ThemeTokens`; `AppButton` receives the existing `ThemeTokens` at every call site; no state-machine or persistence signature changes are introduced.
