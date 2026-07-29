# Draw Motion and Feedback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved two-second dramatic draw animation with reliable sound/vibration cues, then verify that manually entered wheel options survive two consecutive spins.

**Architecture:** A pure `DrawMotionPlan` owns timing, transforms, and feedback cue metadata. `DrawPage` schedules those stages and owns cancellation; `DrawTube` renders independent box, stick, label, and glow layers. Existing `DrawSession`, random selection, persistence, and settings remain unchanged.

**Tech Stack:** HarmonyOS Stage model, ArkTS/ArkUI, Hypium, MediaKit `AVPlayer`, vibrator API, HDC API 24 phone simulator.

**Repository note:** `.git` is read-only in this workspace. Each task ends with a diff/verification checkpoint instead of a commit; no attempt will be made to bypass the repository permission.

---

## File Map

- Create `entry/src/main/ets/domain/draw/DrawMotionPlan.ets`: immutable motion stages and feedback cues.
- Create `entry/src/ohosTest/ets/test/DrawMotionPlan.test.ets`: timing and cue regression tests.
- Modify `entry/src/ohosTest/ets/test/List.test.ets`: register the new test suite.
- Modify `entry/src/main/ets/pages/Draw.ets`: schedule and cancel approved motion/feedback stages.
- Modify `entry/src/main/ets/components/decision/DrawTube.ets`: separate box rotation from upright result stick/label.
- Modify `entry/src/main/ets/services/SoundService.ets`: log playback failures without logging option content.
- Modify `entry/src/ohosTest/ets/test/FeedbackRegression.test.ets`: strengthen wheel draft preservation coverage.
- Modify `changes.md`, `design-qa.md`, and `docs/qa/2026-07-29-ui-restoration.md`: record verification evidence.

### Task 1: Draw Motion Timeline

**Files:**
- Create: `entry/src/main/ets/domain/draw/DrawMotionPlan.ets`
- Create: `entry/src/ohosTest/ets/test/DrawMotionPlan.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: Write the failing timeline tests**

Create `DrawMotionPlan.test.ets`:

```typescript
import { describe, expect, it } from '@ohos/hypium';
import {
  DrawFeedbackKind,
  DrawMotionPlan
} from '../../../main/ets/domain/draw/DrawMotionPlan';

export default function drawMotionPlanTest(): void {
  describe('DrawMotionPlan', (): void => {
    it('usesApprovedDramaticTiming', 0, (): void => {
      expect(DrawMotionPlan.SHAKE_END).assertEqual(420);
      expect(DrawMotionPlan.PAUSE_END).assertEqual(560);
      expect(DrawMotionPlan.LIFT_SETTLE).assertEqual(1450);
      expect(DrawMotionPlan.RESULT_AT).assertEqual(2000);
    });

    it('usesFiveDecayingShakeSteps', 0, (): void => {
      expect(DrawMotionPlan.SHAKES.length).assertEqual(5);
      expect(Math.abs(DrawMotionPlan.SHAKES[0].angle))
        .assertLarger(Math.abs(DrawMotionPlan.SHAKES[4].angle));
    });

    it('definesThreeOrderedFeedbackCues', 0, (): void => {
      expect(DrawMotionPlan.CUES.length).assertEqual(3);
      expect(DrawMotionPlan.CUES[0].kind)
        .assertEqual(DrawFeedbackKind.START);
      expect(DrawMotionPlan.CUES[1].kind)
        .assertEqual(DrawFeedbackKind.FINAL_SHAKE);
      expect(DrawMotionPlan.CUES[2].kind)
        .assertEqual(DrawFeedbackKind.RESULT);
      expect(DrawMotionPlan.CUES[0].duration).assertEqual(18);
      expect(DrawMotionPlan.CUES[1].duration).assertEqual(28);
      expect(DrawMotionPlan.CUES[2].duration).assertEqual(70);
    });
  });
}
```

Register `drawMotionPlanTest()` in `List.test.ets`.

- [ ] **Step 2: Run the test build and verify RED**

Run:

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' `
  --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon
```

Expected: ArkTS compilation fails because `domain/draw/DrawMotionPlan` does not exist.

- [ ] **Step 3: Implement the minimal motion plan**

Create `DrawMotionPlan.ets`:

```typescript
export enum DrawFeedbackKind {
  START = 'start',
  FINAL_SHAKE = 'final-shake',
  RESULT = 'result'
}

export class DrawShakeStage {
  at: number;
  duration: number;
  angle: number;
  translateY: number;

  constructor(at: number, duration: number, angle: number, translateY: number) {
    this.at = at;
    this.duration = duration;
    this.angle = angle;
    this.translateY = translateY;
  }
}

export class DrawFeedbackCue {
  at: number;
  duration: number;
  kind: DrawFeedbackKind;

  constructor(at: number, duration: number, kind: DrawFeedbackKind) {
    this.at = at;
    this.duration = duration;
    this.kind = kind;
  }
}

export class DrawMotionPlan {
  static readonly SHAKE_END: number = 420;
  static readonly PAUSE_END: number = 560;
  static readonly LIFT_PEAK: number = 1250;
  static readonly LIFT_SETTLE: number = 1450;
  static readonly RESULT_AT: number = 2000;
  static readonly SHAKES: DrawShakeStage[] = [
    new DrawShakeStage(0, 70, 9, -3),
    new DrawShakeStage(70, 70, -10, 1),
    new DrawShakeStage(140, 70, 8, -2),
    new DrawShakeStage(210, 70, -6, 1),
    new DrawShakeStage(280, 140, 2, 0)
  ];
  static readonly CUES: DrawFeedbackCue[] = [
    new DrawFeedbackCue(0, 18, DrawFeedbackKind.START),
    new DrawFeedbackCue(350, 28, DrawFeedbackKind.FINAL_SHAKE),
    new DrawFeedbackCue(2000, 70, DrawFeedbackKind.RESULT)
  ];
}
```

- [ ] **Step 4: Build and run device tests to verify GREEN**

Build the test HAP, install main/test HAPs, then run:

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe' `
  -t 127.0.0.1:5555 shell aa test `
  -b com.yr23.decision -m entry_test -s unittest OpenHarmonyTestRunner
```

Expected: new `DrawMotionPlan` tests pass; total test count increases by three.

- [ ] **Step 5: Checkpoint**

Run `git diff --check` and inspect only the three task files.

### Task 2: Dramatic Draw Animation

**Files:**
- Modify: `entry/src/main/ets/pages/Draw.ets`
- Modify: `entry/src/main/ets/components/decision/DrawTube.ets`

- [ ] **Step 1: Add page animation state**

Add these `@State` fields to `DrawPage`:

```typescript
@State private shakeY: number = 0;
@State private stickOpacity: number = 0;
@State private stickScale: number = 0.96;
@State private revealGlow: number = 0;
```

Import `DrawMotionPlan` and replace the existing three hard-coded animation timers with stages from `DrawMotionPlan.SHAKES`.

- [ ] **Step 2: Schedule the approved four phases**

At draw start, reset all visual state. For each shake stage, schedule:

```typescript
this.timerIds.push(setTimeout((): void => {
  this.getUIContext().animateTo({
    duration: stage.duration,
    curve: Curve.EaseInOut
  }, (): void => {
    this.shakeAngle = stage.angle;
    this.shakeY = stage.translateY;
  });
}, stage.at));
```

At `SHAKE_END`, return the box to angle/y zero. At `PAUSE_END`, reveal and lift the stick to `-128vp`. At `LIFT_PEAK`, settle it to `-116vp`, scale to `1`, and fade in the glow. At `RESULT_AT`, complete the session and show the existing result sheet.

- [ ] **Step 3: Reset every animation field on cancel, close, retry, and reset**

Create a page-local method:

```typescript
private resetMotion(): void {
  this.shakeAngle = 0;
  this.shakeY = 0;
  this.stickOffset = 0;
  this.stickOpacity = 0;
  this.stickScale = 0.96;
  this.revealGlow = 0;
  this.liftedLabel = '';
}
```

Call it from `cancel()`, `resetDraws()`, result close, and immediately before retry.

- [ ] **Step 4: Separate rendering layers in DrawTube**

Extend `DrawTube` props:

```typescript
@Prop shakeY: number = 0;
@Prop stickOpacity: number = 0;
@Prop stickScale: number = 1;
@Prop revealGlow: number = 0;
```

Apply `.rotate({ angle: this.shakeAngle })` and `.translate({ y: this.shakeY })` only to the box image. Render the glow, stick, and text as sibling layers. Apply opacity/scale/vertical translation only to the stick column so the label remains upright.

- [ ] **Step 5: Build main HAP**

Run the main `assembleHap` command.

Expected: `TYPE CHECK SUCCESSFUL` and `BUILD SUCCESSFUL`.

- [ ] **Step 6: Checkpoint**

Run `git diff --check` and inspect `Draw.ets` plus `DrawTube.ets`.

### Task 3: Sound and Vibration Feedback

**Files:**
- Modify: `entry/src/main/ets/pages/Draw.ets`
- Modify: `entry/src/main/ets/services/SoundService.ets`

- [ ] **Step 1: Trigger all three feedback cues**

At draw start:

```typescript
soundService.play(SoundEffect.DRAW);
feedbackService.impact(18);
```

At `350ms`, call `feedbackService.impact(28)`.

At `RESULT_AT`, after `session.complete()`:

```typescript
feedbackService.impact(70);
soundService.play(SoundEffect.RESULT);
```

Do not inspect settings in the page; `SoundService` and `FeedbackService` remain the single enforcement points for their settings switches.

- [ ] **Step 2: Add non-sensitive sound diagnostics**

Import `hilog` in `SoundService.ets`, define the existing application domain/tag convention, and replace the empty catch with:

```typescript
} catch (_error) {
  hilog.warn(0x4443, 'Decision', 'Sound effect playback failed');
  await this.release();
  return false;
}
```

Do not include `effect`, file paths, or user option values in the log.

- [ ] **Step 3: Verify resource and settings behavior**

Confirm `draw.wav` and `result.wav` remain under `rawfile/sounds`, `soundEnabled` and `vibrationEnabled` default to true, and `ohos.permission.VIBRATE` remains declared.

- [ ] **Step 4: Device verification**

On the simulator:

1. Turn sound/vibration on in Settings.
2. Run one draw and verify two sound events plus three feedback calls in the expected sequence.
3. Turn both settings off and repeat; no sound or vibration should be emitted.
4. Background the app mid-animation; no result or delayed feedback should occur after cancellation.

- [ ] **Step 5: Checkpoint**

Run `git diff --check` and inspect `Draw.ets` plus `SoundService.ets`.

### Task 4: Wheel Manual Draft Persistence Regression

**Files:**
- Modify: `entry/src/ohosTest/ets/test/FeedbackRegression.test.ets`
- Verify: `entry/src/main/ets/pages/Wheel.ets`
- Verify: `entry/src/main/ets/stores/DecisionDraftStore.ets`

- [ ] **Step 1: Add a two-spin draft regression test**

Extend `FeedbackRegression.test.ets`:

```typescript
it('keepsManualWheelOptionsAcrossRepeatedSpinInputs', 0, (): void => {
  const store: DecisionDraftStore = new DecisionDraftStore();
  store.set('', ToolType.WHEEL, ['', '']);
  const firstId: string = store.decisionOptions()[0].id;
  const secondId: string = store.decisionOptions()[1].id;
  store.updateOption(firstId, 'Alpha');
  store.updateOption(secondId, 'Beta');
  const firstSpin: string[] = Array.from(store.options);
  store.updateOptions(firstSpin.map((value: string): string => value.trim()));
  const secondSpin: string[] = Array.from(store.options);
  expect(firstSpin.join('|')).assertEqual('Alpha|Beta');
  expect(secondSpin.join('|')).assertEqual('Alpha|Beta');
  expect(store.decisionOptions()[0].text).assertEqual('Alpha');
  expect(store.decisionOptions()[1].text).assertEqual('Beta');
});
```

Import `ToolType` if not already imported.

- [ ] **Step 2: Run the device tests**

Expected: the new regression test passes and the complete suite has zero failures/errors.

- [ ] **Step 3: Execute the required UI flow**

On a blank wheel:

1. Enter `Alpha` and `Beta`.
2. Verify Canvas labels update immediately.
3. Spin and close the result.
4. Verify both inputs and Canvas labels remain.
5. Spin again without editing.
6. Close the second result and verify values still remain.

Capture screenshots after steps 2, 4, and 6.

- [ ] **Step 4: Checkpoint**

If the UI flow fails, stop and trace the first state transition that changes `decisionDraftStore.options` or `wheelOptions`; do not add a second persistence store.

### Task 5: Full Verification and Documentation

**Files:**
- Modify: `changes.md`
- Modify: `design-qa.md`
- Modify: `docs/qa/2026-07-29-ui-restoration.md`
- Add: `docs/qa/screenshots/2026-07-29-draw-motion-*.jpeg`
- Add: `docs/qa/screenshots/2026-07-29-wheel-manual-repeat-*.jpeg`

- [ ] **Step 1: Run standard checks**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
git diff --check
```

Expected: standard check passes with only the existing non-blocking recommendations; diff check has no whitespace errors.

- [ ] **Step 2: Run clean builds**

Run `hvigorw.bat clean --no-daemon`, then build main and ohosTest HAPs.

Expected: both builds succeed; unsigned-signing and duplicated test color warnings remain the only expected warnings.

- [ ] **Step 3: Run the full device suite**

Install both HAPs and run OpenHarmonyTestRunner.

Expected: all tests pass, Failure 0, Error 0.

- [ ] **Step 4: Capture final device evidence**

Capture:

- start of dramatic shake,
- upright lifted label before result sheet,
- final result sheet,
- wheel values after first result close,
- wheel values after second result close.

- [ ] **Step 5: Update QA records**

Record the final test count, HAP sizes, exact screenshot names, animation timing, and the settings-on/settings-off feedback checks in the three QA documents.

- [ ] **Step 6: Final checkpoint**

Run `git status --short`, `git diff --stat`, and `git diff --check`. Restart `EntryAbility` so the user can test immediately.
