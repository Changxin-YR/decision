# “做个决定”原生鸿蒙应用 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 使用 API 24、ArkTS 和 ArkUI 构建可离线安装使用的“做个决定”v1.0，并完整实现六个决策工具、模板、历史、设置和自适应体验。

**Architecture:** 工程采用 Stage 模型和单 `entry` HAP，按页面、可复用组件、纯领域逻辑、仓储和设备服务分层。所有随机结果由统一领域服务在动画前确定；Preferences 只通过仓储访问；UIAbility 统一广播前后台状态。

**Tech Stack:** HarmonyOS 6.1.1 API 24、ArkTS、ArkUI、Stage 模型、Preferences、Canvas、AVPlayer、Vibrator、Hypium、Hvigor 6.24.3。

---

## 文件结构

```text
AppScope/
├── app.json5
└── resources/base/{element,media}/
entry/
├── build-profile.json5
├── hvigorfile.ts
├── oh-package.json5
└── src/
    ├── main/
    │   ├── module.json5
    │   ├── resources/base/{element,media,profile}/
    │   └── ets/
    │       ├── entryability/EntryAbility.ets
    │       ├── pages/{Index,Wheel,Draw,FingerSelect,Coin,YesNo,RandomNumber,History,Settings,Privacy}.ets
    │       ├── components/common/{AppButton,AppCard,AppInput,PageHeader,ResultSheet,ConfirmDialog}.ets
    │       ├── components/decision/{OptionsEditor,WheelCanvas,DrawTube,CoinView}.ets
    │       ├── constants/{AppStrings,DesignTokens,PresetTemplates}.ets
    │       ├── models/{AppModels,NavigationModels}.ets
    │       ├── domain/random/RandomService.ets
    │       ├── domain/validation/{OptionValidator,NumberValidator}.ets
    │       ├── domain/state/{DrawSession,FingerSelectionMachine}.ets
    │       ├── domain/wheel/WheelGeometry.ets
    │       ├── data/{JsonCodec,PreferencesStore}.ets
    │       ├── data/repositories/{SettingsRepository,TemplateRepository,HistoryRepository}.ets
    │       ├── services/{AppLifecycleBus,FeedbackService,SoundService,ClipboardService}.ets
    │       ├── stores/AppStore.ets
    │       └── utils/{IdFactory,TimeFormatter}.ets
    └── ohosTest/
        ├── module.json5
        └── ets/test/*.test.ets
```

---

### Task 1: 创建 API 24 Stage 工程骨架

**Files:**
- Create: `build-profile.json5`
- Create: `oh-package.json5`
- Create: `package.json`
- Create: `hvigorfile.ts`
- Create: `hvigor/hvigor-config.json5`
- Create: `entry/build-profile.json5`
- Create: `entry/oh-package.json5`
- Create: `entry/hvigorfile.ts`
- Create: `AppScope/app.json5`
- Create: `AppScope/resources/base/element/string.json`
- Create: `AppScope/resources/base/element/color.json`
- Create: `entry/src/main/module.json5`
- Create: `entry/src/main/resources/base/profile/main_pages.json`
- Create: `entry/src/main/resources/base/element/string.json`
- Create: `entry/src/main/resources/base/element/color.json`
- Create: `entry/src/main/ets/entryability/EntryAbility.ets`
- Create: `entry/src/main/ets/pages/Index.ets`
- Create: `entry/src/ohosTest/module.json5`
- Create: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写入工程清单和 API 24 配置**

`build-profile.json5` 的产品配置固定为：

```json5
{
  "app": {
    "signingConfigs": [],
    "products": [{
      "name": "default",
      "compatibleSdkVersion": "6.1.1(24)",
      "targetSdkVersion": "6.1.1(24)",
      "runtimeOS": "HarmonyOS",
      "buildOption": {
        "strictMode": {
          "caseSensitiveCheck": true,
          "useNormalizedOHMUrl": true
        }
      }
    }],
    "buildModeSet": [{ "name": "debug" }, { "name": "release" }]
  },
  "modules": [{
    "name": "entry",
    "srcPath": "./entry",
    "targets": [{ "name": "default", "applyToProducts": ["default"] }]
  }]
}
```

`AppScope/app.json5` 使用 `bundleName: "com.yr23.decision"`、`vendor: "YR23"`、`versionCode: 1000000`、`versionName: "1.0.0"`。

- [ ] **Step 2: 写入零权限模块配置**

`entry/src/main/module.json5` 仅包含 `phone` 和 `tablet` 设备类型、`EntryAbility`、主页技能和页面清单，不增加 `requestPermissions` 字段。

- [ ] **Step 3: 写入最小可运行页面**

```arkts
@Entry
@Component
struct Index {
  build() {
    Column({ space: 12 }) {
      Text('做个决定')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Text('原生鸿蒙离线决策工具')
        .fontSize(16)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
```

- [ ] **Step 4: 安装本地工程依赖并构建**

Run:

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p module=entry@default assembleHap --no-daemon
```

Expected: `TYPE CHECK SUCCESSFUL` 和 `BUILD SUCCESSFUL`，允许出现“未配置签名”的警告。

- [ ] **Step 5: 提交并推送**

```powershell
git add AppScope entry hvigor build-profile.json5 hvigorfile.ts oh-package.json5 package.json
git commit -m "build: scaffold HarmonyOS API 24 app"
git push origin master
```

---

### Task 2: 建立模型、设计常量和随机算法

**Files:**
- Create: `entry/src/main/ets/models/AppModels.ets`
- Create: `entry/src/main/ets/constants/DesignTokens.ets`
- Create: `entry/src/main/ets/constants/AppStrings.ets`
- Create: `entry/src/main/ets/constants/PresetTemplates.ets`
- Create: `entry/src/main/ets/domain/random/RandomService.ets`
- Create: `entry/src/ohosTest/ets/test/RandomService.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写随机服务失败测试**

```arkts
import { describe, expect, it } from '@ohos/hypium';
import { RandomService } from '../../../main/ets/domain/random/RandomService';

export default function randomServiceTest(): void {
  describe('RandomService', (): void => {
    it('pickOne rejects an empty list', 0, (): void => {
      expect((): void => RandomService.pickOne<string>([])).assertThrowError('列表不能为空');
    });
    it('pickMany without replacement returns unique values', 0, (): void => {
      const values: number[] = RandomService.pickMany<number>([1, 2, 3, 4], 4, false);
      expect(new Set<number>(values).size).assertEqual(4);
    });
    it('randomIntegers stays in the inclusive range', 0, (): void => {
      const values: number[] = RandomService.randomIntegers(-2, 2, 100, true);
      expect(values.every((value: number): boolean => value >= -2 && value <= 2)).assertTrue();
    });
  });
}
```

- [ ] **Step 2: 编译测试并确认 RED**

Run the `ohosTest` target from DevEco Studio or:

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon
```

Expected: FAIL because `RandomService.ets` or exported methods do not exist.

- [ ] **Step 3: 实现统一随机服务**

```arkts
export class RandomService {
  static pickOne<T>(values: readonly T[]): T {
    if (values.length === 0) {
      throw new Error('列表不能为空');
    }
    return values[Math.floor(Math.random() * values.length)];
  }

  static pickMany<T>(values: readonly T[], count: number, allowRepeat: boolean): T[] {
    if (count <= 0) {
      return [];
    }
    if (!allowRepeat && count > values.length) {
      throw new Error('可选项数量不足');
    }
    if (allowRepeat) {
      return Array.from({ length: count }, (): T => RandomService.pickOne<T>(values));
    }
    const pool: T[] = Array.from(values);
    for (let index: number = 0; index < count; index++) {
      const swapIndex: number = index + Math.floor(Math.random() * (pool.length - index));
      const current: T = pool[index];
      pool[index] = pool[swapIndex];
      pool[swapIndex] = current;
    }
    return pool.slice(0, count);
  }

  static randomBoolean(): boolean {
    return Math.random() < 0.5;
  }

  static randomIntegers(min: number, max: number, count: number, allowRepeat: boolean): number[] {
    const size: number = max - min + 1;
    if (min > max || count <= 0 || (!allowRepeat && count > size)) {
      throw new Error('随机数字参数无效');
    }
    if (allowRepeat) {
      return Array.from({ length: count },
        (): number => min + Math.floor(Math.random() * size));
    }
    const selected: Set<number> = new Set<number>();
    while (selected.size < count) {
      selected.add(min + Math.floor(Math.random() * size));
    }
    return Array.from(selected);
  }
}
```

- [ ] **Step 4: 定义稳定模型**

`AppModels.ets` 定义 `ToolType`、`ThemeMode`、`AppSettings`、`DecisionTemplate`、`HistoryRecord`、`DecisionOption`、`CoinSide` 和默认设置；不使用 `any`、联合对象字面量或动态字段。

- [ ] **Step 5: 写入设计常量和四个内置模板**

`PresetTemplates.ets` 精确包含“今天吃什么”“谁去拿外卖”“周末去哪里”“谁先开始”及功能规格中的选项。

- [ ] **Step 6: 运行测试和构建确认 GREEN**

Expected: 随机服务测试通过，Debug HAP 构建成功。

- [ ] **Step 7: 提交并推送**

```powershell
git add entry/src/main/ets/models entry/src/main/ets/constants entry/src/main/ets/domain/random entry/src/ohosTest
git commit -m "feat: add decision models and random service"
git push origin master
```

---

### Task 3: 实现输入校验和转盘几何

**Files:**
- Create: `entry/src/main/ets/domain/validation/OptionValidator.ets`
- Create: `entry/src/main/ets/domain/validation/NumberValidator.ets`
- Create: `entry/src/main/ets/domain/wheel/WheelGeometry.ets`
- Create: `entry/src/ohosTest/ets/test/Validation.test.ets`
- Create: `entry/src/ohosTest/ets/test/WheelGeometry.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写失败测试**

```arkts
it('rejects normalized duplicate options', 0, (): void => {
  const result: ValidationResult = OptionValidator.validate(['火锅', ' 火锅 ']);
  expect(result.valid).assertFalse();
  expect(result.message).assertEqual('选项不能重复');
});

it('rejects impossible unique number draw', 0, (): void => {
  const result: ValidationResult = NumberValidator.validate(1, 3, 4, false);
  expect(result.message).assertEqual('数字不够抽，请调整范围或允许重复');
});

it('maps result index to pointer stop angle', 0, (): void => {
  expect(WheelGeometry.stopAngle(4, 0) % 360).assertEqual(315);
  expect(WheelGeometry.resultIndexAtPointer(4, 315)).assertEqual(0);
});
```

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL because validators and geometry are missing.

- [ ] **Step 3: 实现校验结果和规则**

```arkts
export class ValidationResult {
  valid: boolean;
  message: string;

  constructor(valid: boolean, message: string = '') {
    this.valid = valid;
    this.message = message;
  }
}
```

`OptionValidator.validate` 必须依次检查数量、空值、十五字符上限和 `trim()` 后重复；`NumberValidator.validate` 必须检查整数、范围、数量和无放回容量。

- [ ] **Step 4: 实现互为逆运算的转盘角度函数**

```arkts
export class WheelGeometry {
  static stopAngle(optionCount: number, resultIndex: number): number {
    const sector: number = 360 / optionCount;
    return (360 - (resultIndex * sector + sector / 2)) % 360;
  }

  static resultIndexAtPointer(optionCount: number, rotation: number): number {
    const sector: number = 360 / optionCount;
    const normalized: number = ((360 - rotation) % 360 + 360) % 360;
    return Math.floor(normalized / sector) % optionCount;
  }
}
```

- [ ] **Step 5: 运行测试和构建确认 GREEN**

Expected: 校验和角度映射测试通过，ArkTS 类型检查成功。

- [ ] **Step 6: 提交并推送**

```powershell
git add entry/src/main/ets/domain entry/src/ohosTest
git commit -m "feat: add validation and wheel geometry"
git push origin master
```

---

### Task 4: 实现 JSON 编解码和 Preferences 仓储

**Files:**
- Create: `entry/src/main/ets/data/JsonCodec.ets`
- Create: `entry/src/main/ets/data/PreferencesStore.ets`
- Create: `entry/src/main/ets/data/repositories/SettingsRepository.ets`
- Create: `entry/src/main/ets/data/repositories/TemplateRepository.ets`
- Create: `entry/src/main/ets/data/repositories/HistoryRepository.ets`
- Create: `entry/src/ohosTest/ets/test/JsonCodec.test.ets`
- Create: `entry/src/ohosTest/ets/test/HistoryRepository.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写损坏数据和历史裁剪失败测试**

```arkts
it('falls back when settings JSON is damaged', 0, (): void => {
  const settings: AppSettings = JsonCodec.decodeSettings('{broken');
  expect(settings.themeMode).assertEqual(ThemeMode.SYSTEM);
  expect(settings.autoSaveHistory).assertFalse();
});

it('keeps newest 200 history records', 0, (): void => {
  const records: HistoryRecord[] = createRecords(201);
  const trimmed: HistoryRecord[] = HistoryRepository.trim(records);
  expect(trimmed.length).assertEqual(200);
  expect(trimmed[0].id).assertEqual('200');
  expect(trimmed[199].id).assertEqual('1');
});
```

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL because codec and repositories are missing.

- [ ] **Step 3: 实现安全编解码**

`JsonCodec` 为设置、模板和历史分别提供 `encode*` 与 `decode*`；解析后逐字段校验类型，缺失字段应用默认值，模板和历史中的非法记录直接过滤。

- [ ] **Step 4: 实现 PreferencesStore**

```arkts
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export class PreferencesStore {
  private data: preferences.Preferences | null = null;

  async initialize(context: common.Context): Promise<void> {
    this.data = await preferences.getPreferences(context, 'decision_data');
  }

  async getString(key: string, fallback: string): Promise<string> {
    if (this.data === null) {
      return fallback;
    }
    return await this.data.get(key, fallback) as string;
  }

  async putString(key: string, value: string): Promise<void> {
    if (this.data === null) {
      throw new Error('本地存储尚未初始化');
    }
    await this.data.put(key, value);
    await this.data.flush();
  }

  async remove(key: string): Promise<void> {
    if (this.data !== null) {
      await this.data.delete(key);
      await this.data.flush();
    }
  }
}
```

- [ ] **Step 5: 实现三个仓储**

设置仓储读写单个对象；模板仓储只保存自定义模板；历史仓储新增时置顶并裁剪到 200 条。每个写方法返回 `Promise<boolean>`，失败返回 `false` 供 UI 展示。

- [ ] **Step 6: 运行测试和构建确认 GREEN**

Expected: 编解码与裁剪测试通过，API 24 构建成功。

- [ ] **Step 7: 提交并推送**

```powershell
git add entry/src/main/ets/data entry/src/ohosTest
git commit -m "feat: add local preference repositories"
git push origin master
```

---

### Task 5: 建立应用状态、生命周期和设备反馈服务

**Files:**
- Create: `entry/src/main/ets/stores/AppStore.ets`
- Create: `entry/src/main/ets/services/AppLifecycleBus.ets`
- Create: `entry/src/main/ets/services/FeedbackService.ets`
- Create: `entry/src/main/ets/services/SoundService.ets`
- Create: `entry/src/main/ets/services/ClipboardService.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Create: `entry/src/main/resources/rawfile/sounds/tap.wav`
- Create: `entry/src/main/resources/rawfile/sounds/coin.wav`
- Create: `entry/src/main/resources/rawfile/sounds/wheel.wav`
- Create: `entry/src/main/resources/rawfile/sounds/draw.wav`
- Create: `entry/src/main/resources/rawfile/sounds/result.wav`

- [ ] **Step 1: 写 AppStore 状态合并失败测试**

测试初始化默认设置、更新单个设置不覆盖其他字段、清除全部数据后恢复默认设置。

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL because `AppStore` is missing.

- [ ] **Step 3: 实现 AppStore**

`AppStore` 持有可观察的 `settings`、`templates`、`history` 和 `initialized`，通过三个仓储完成加载和变更；页面只调用 AppStore 方法。

- [ ] **Step 4: 实现生命周期总线**

```arkts
export type LifecycleListener = (inBackground: boolean) => void;

export class AppLifecycleBus {
  private listeners: Set<LifecycleListener> = new Set<LifecycleListener>();

  subscribe(listener: LifecycleListener): () => void {
    this.listeners.add(listener);
    return (): void => {
      this.listeners.delete(listener);
    };
  }

  notify(inBackground: boolean): void {
    this.listeners.forEach((listener: LifecycleListener): void => listener(inBackground));
  }
}
```

- [ ] **Step 5: 实现振动、音频和剪贴板降级**

`FeedbackService` 读取设置后调用 `vibrator.startVibration`；`SoundService` 使用 `AVPlayer` 播放 rawfile 并在后台释放；`ClipboardService` 使用 `pasteboard.getSystemPasteboard()` 写入换行分隔结果。所有设备服务捕获异常但不吞掉需要显示的保存失败。

- [ ] **Step 6: 接入 UIAbility**

`onWindowStageCreate` 初始化 AppStore 后加载 `pages/Index`；`onBackground` 通知生命周期总线并停止音频；`onForeground` 只通知恢复，不自动重播声音。

- [ ] **Step 7: 运行测试和构建**

Expected: Store 测试通过，API 24 类型检查和 HAP 构建成功。

- [ ] **Step 8: 提交并推送**

```powershell
git add entry/src/main/ets/stores entry/src/main/ets/services entry/src/main/ets/entryability entry/src/main/resources/rawfile
git commit -m "feat: add app state and device services"
git push origin master
```

---

### Task 6: 构建通用 ArkUI 组件、导航和首页

**Files:**
- Create: `entry/src/main/ets/models/NavigationModels.ets`
- Create: `entry/src/main/ets/components/common/AppButton.ets`
- Create: `entry/src/main/ets/components/common/AppCard.ets`
- Create: `entry/src/main/ets/components/common/AppInput.ets`
- Create: `entry/src/main/ets/components/common/PageHeader.ets`
- Create: `entry/src/main/ets/components/common/ResultSheet.ets`
- Create: `entry/src/main/ets/components/common/ConfirmDialog.ets`
- Rewrite: `entry/src/main/ets/pages/Index.ets`
- Create: `entry/src/main/ets/pages/Privacy.ets`
- Modify: `entry/src/main/resources/base/profile/main_pages.json`

- [ ] **Step 1: 实现主题 token 选择纯函数并写测试**

测试浅色、深色和跟随系统分别返回功能规格指定的背景、卡片、文字、边框和强调色。

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL before token selector implementation.

- [ ] **Step 3: 实现通用组件**

`AppButton` 支持主、次、文字、危险四种外观和禁用态；`AppInput` 支持焦点与错误边框；`ResultSheet` 使用半透明遮罩和底部圆角面板；`ConfirmDialog` 使用 `CustomDialogController`，点击遮罩不执行破坏操作。

- [ ] **Step 4: 实现首页 Navigation**

首页使用 `Navigation` 和 `NavPathStack`。六个工具卡片按窗口宽度计算两至四列；模板区域合并内置与自定义模板，点击后传递结构化页面参数。

- [ ] **Step 5: 实现隐私页**

隐私页逐字覆盖功能规格中的本地、无网络、无数据采集和卸载删除说明。

- [ ] **Step 6: 构建并在 Previewer 检查**

Expected: 首页六卡片可见，浅/深色正常，320vp 无横向溢出，折叠屏宽度下网格增加列数。

- [ ] **Step 7: 提交并推送**

```powershell
git add entry/src/main/ets/components entry/src/main/ets/models/NavigationModels.ets entry/src/main/ets/pages entry/src/main/resources/base/profile
git commit -m "feat: add navigation home and common UI"
git push origin master
```

---

### Task 7: 实现是或否、抛硬币和随机数字

**Files:**
- Create: `entry/src/main/ets/pages/YesNo.ets`
- Create: `entry/src/main/ets/pages/Coin.ets`
- Create: `entry/src/main/ets/pages/RandomNumber.ets`
- Create: `entry/src/main/ets/components/decision/CoinView.ets`
- Create: `entry/src/main/ets/domain/state/SimpleDecisionState.ets`
- Create: `entry/src/ohosTest/ets/test/SimpleDecisionState.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写动画锁定和硬币统计失败测试**

```arkts
it('ignores a second start while running', 0, (): void => {
  const state: SimpleDecisionState = new SimpleDecisionState();
  expect(state.begin()).assertTrue();
  expect(state.begin()).assertFalse();
});

it('counts only completed coin results', 0, (): void => {
  const state: CoinSession = new CoinSession();
  state.begin(CoinSide.HEADS);
  state.cancel();
  expect(state.headsCount).assertEqual(0);
  state.begin(CoinSide.HEADS);
  state.complete();
  expect(state.headsCount).assertEqual(1);
});
```

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL because state classes are missing.

- [ ] **Step 3: 实现纯状态类**

状态类显式提供 `begin`、`complete`、`cancel` 和 `reset`；取消操作不得提交预先计算但尚未展示的结果。

- [ ] **Step 4: 实现三个页面**

- 是或否：先调用 `randomBoolean`，再播放 150ms 按压和 250ms 淡入。
- 抛硬币：先确定面，再把旋转角度落到对应的 180 度倍数，1.5 秒后才更新统计。
- 随机数字：通过 `NumberValidator` 后调用 `randomIntegers`，支持复制和保存。

- [ ] **Step 5: 接入自动与手动保存**

自动保存开启时结果展示后保存一次；用户再次点击保存时根据当前记录 ID 防重复，并准确反馈保存成功或失败。

- [ ] **Step 6: 运行测试、构建和交互检查**

Expected: 三个页面完整流程可用；快速双击只产生一个结果；后台切换取消未完成结果。

- [ ] **Step 7: 提交并推送**

```powershell
git add entry/src/main/ets/pages/YesNo.ets entry/src/main/ets/pages/Coin.ets entry/src/main/ets/pages/RandomNumber.ets entry/src/main/ets/components/decision/CoinView.ets entry/src/main/ets/domain/state entry/src/ohosTest
git commit -m "feat: add simple decision tools"
git push origin master
```

---

### Task 8: 实现选项编辑器和模板保存

**Files:**
- Create: `entry/src/main/ets/components/decision/OptionsEditor.ets`
- Create: `entry/src/main/ets/domain/state/OptionEditorState.ets`
- Create: `entry/src/ohosTest/ets/test/OptionEditorState.test.ets`
- Modify: `entry/src/main/ets/stores/AppStore.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: 写增删改排序失败测试**

测试默认至少两个空选项、最多十二个、只剩两个时不可删除、移动后顺序更新、重复选项被拒绝。

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL because `OptionEditorState` is missing.

- [ ] **Step 3: 实现 OptionEditorState**

状态类使用稳定 ID，公开 `add`、`update`、`remove`、`move`、`texts` 和 `validate`；所有修改返回新数组，避免 UI 观察不到原地变更。

- [ ] **Step 4: 实现 OptionsEditor**

每行包含拖拽手柄、输入框和删除按钮；使用长按后拖动改变顺序；不可编辑态禁用输入、拖动和删除。

- [ ] **Step 5: 实现模板保存对话框**

仅允许转盘和抽签保存模板；名称 `trim()` 后非空、不超过十五字符；保存失败显示 Toast，成功后首页立即出现模板。

- [ ] **Step 6: 运行测试、构建和交互检查**

Expected: 选项编辑规则符合功能规格，自定义模板关闭应用后仍存在。

- [ ] **Step 7: 提交并推送**

```powershell
git add entry/src/main/ets/components/decision/OptionsEditor.ets entry/src/main/ets/domain/state/OptionEditorState.ets entry/src/main/ets/stores/AppStore.ets entry/src/main/ets/pages/Index.ets entry/src/ohosTest
git commit -m "feat: add option editor and custom templates"
git push origin master
```

---

### Task 9: 实现幸运转盘

**Files:**
- Create: `entry/src/main/ets/components/decision/WheelCanvas.ets`
- Create: `entry/src/main/ets/pages/Wheel.ets`
- Create: `entry/src/main/ets/domain/state/WheelSession.ets`
- Create: `entry/src/ohosTest/ets/test/WheelSession.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写结果先算和取消失败测试**

测试 `start` 返回确定结果下标与目标角度；`cancel` 后不进入完成态；同一运行态再次 `start` 被拒绝。

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL because `WheelSession` is missing.

- [ ] **Step 3: 实现 WheelSession**

`start(options)` 先选择下标，再用 `WheelGeometry.stopAngle` 计算基础角度并增加五至八整圈；页面只消费该结果，不再调用随机数。

- [ ] **Step 4: 使用 Canvas 绘制转盘**

按选项数绘制等角扇区、十二色循环、居中文字、中心圆和固定顶部指针；尺寸来自父容器最短边，不使用固定屏幕宽度。

- [ ] **Step 5: 实现页面状态和动画**

校验通过后立即锁定输入与返回，使用 3–5 秒减速动画；完成回调才展示 `ResultSheet`、振动并可保存。

- [ ] **Step 6: 运行测试和角度交互验收**

对 2、3、6、12 个选项分别执行至少十次，指针位置必须与结果文字一致。

- [ ] **Step 7: 提交并推送**

```powershell
git add entry/src/main/ets/components/decision/WheelCanvas.ets entry/src/main/ets/pages/Wheel.ets entry/src/main/ets/domain/state/WheelSession.ets entry/src/ohosTest
git commit -m "feat: add fair animated decision wheel"
git push origin master
```

---

### Task 10: 实现抽签

**Files:**
- Create: `entry/src/main/ets/components/decision/DrawTube.ets`
- Create: `entry/src/main/ets/pages/Draw.ets`
- Create: `entry/src/main/ets/domain/state/DrawSession.ets`
- Create: `entry/src/ohosTest/ets/test/DrawSession.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写重复与不重复模式失败测试**

```arkts
it('removes completed result in no-repeat mode', 0, (): void => {
  const session: DrawSession = new DrawSession(['甲', '乙'], false);
  const first: string = session.start();
  session.complete();
  expect(session.remaining.includes(first)).assertFalse();
});

it('keeps all candidates in repeat mode', 0, (): void => {
  const session: DrawSession = new DrawSession(['甲', '乙'], true);
  session.start();
  session.complete();
  expect(session.remaining.length).assertEqual(2);
});
```

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL because `DrawSession` is missing.

- [ ] **Step 3: 实现抽签状态机**

运行态保存预定结果；只有 `complete` 才从无重复候选池移除结果；后台 `cancel` 保留之前已经完成的抽取历史。

- [ ] **Step 4: 实现签筒组件和页面**

签筒使用 ArkUI 图形绘制；1 秒左右晃动后签条上升 0.5 秒；抽完显示“所有选项已经抽取完成”和“重新开始”。

- [ ] **Step 5: 运行测试和交互验收**

Expected: 无重复模式直到抽空不重复，重复模式可无限抽取，动画期间不可编辑。

- [ ] **Step 6: 提交并推送**

```powershell
git add entry/src/main/ets/components/decision/DrawTube.ets entry/src/main/ets/pages/Draw.ets entry/src/main/ets/domain/state/DrawSession.ets entry/src/ohosTest
git commit -m "feat: add repeat-aware drawing tool"
git push origin master
```

---

### Task 11: 实现指尖选择状态机和多点触控

**Files:**
- Create: `entry/src/main/ets/domain/state/FingerSelectionMachine.ets`
- Create: `entry/src/main/ets/pages/FingerSelect.ets`
- Create: `entry/src/ohosTest/ets/test/FingerSelectionMachine.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写状态机失败测试**

测试少于两指保持空闲、两指进入倒计时、增加或减少触点重置倒计时、三秒完成锁定、锁定期忽略触摸、三秒后恢复空闲。

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL because `FingerSelectionMachine` is missing.

- [ ] **Step 3: 实现纯状态机**

```arkts
export enum FingerState {
  IDLE = 'idle',
  COUNTDOWN = 'countdown',
  LOCKED = 'locked'
}

export class FingerSelectionMachine {
  state: FingerState = FingerState.IDLE;
  activeIds: number[] = [];
  selectedId: number = -1;
  countdown: number = 3;

  updateTouches(ids: number[]): void {
    if (this.state === FingerState.LOCKED) {
      return;
    }
    const changed: boolean = ids.join(',') !== this.activeIds.join(',');
    this.activeIds = Array.from(ids);
    if (ids.length < 2) {
      this.resetCountdown();
      return;
    }
    if (changed || this.state === FingerState.IDLE) {
      this.state = FingerState.COUNTDOWN;
      this.countdown = 3;
    }
  }

  tick(): void {
    if (this.state !== FingerState.COUNTDOWN) {
      return;
    }
    this.countdown--;
    if (this.countdown === 0) {
      this.selectedId = RandomService.pickOne<number>(this.activeIds);
      this.state = FingerState.LOCKED;
    }
  }

  reset(): void {
    this.activeIds = [];
    this.selectedId = -1;
    this.resetCountdown();
  }

  private resetCountdown(): void {
    this.state = FingerState.IDLE;
    this.countdown = 3;
  }
}
```

- [ ] **Step 4: 实现多点触控页面**

使用全屏触摸事件中的触点 ID 与局部坐标渲染彩色圆；触点集合变化时重启倒计时；选中圆放大、振动并显示“选中你了！”；后台立即清空计时器和触点。

- [ ] **Step 5: 运行测试和真机/模拟器验收**

Expected: 2–10 个触点可追踪，增减触点重置，锁定期不响应，三秒后自动恢复。

- [ ] **Step 6: 提交并推送**

```powershell
git add entry/src/main/ets/domain/state/FingerSelectionMachine.ets entry/src/main/ets/pages/FingerSelect.ets entry/src/ohosTest
git commit -m "feat: add multi-touch finger selector"
git push origin master
```

---

### Task 12: 实现历史、设置和完整数据清理

**Files:**
- Create: `entry/src/main/ets/pages/History.ets`
- Create: `entry/src/main/ets/pages/Settings.ets`
- Create: `entry/src/main/ets/utils/TimeFormatter.ets`
- Create: `entry/src/ohosTest/ets/test/TimeFormatter.test.ets`
- Modify: `entry/src/main/ets/stores/AppStore.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写时间格式和清理隔离失败测试**

测试时间格式为“7月28日 18:30”；清除历史不改变模板；清除模板不改变历史；清除全部恢复默认设置。

- [ ] **Step 2: 编译确认 RED**

Expected: FAIL before formatter and clear methods exist.

- [ ] **Step 3: 实现历史页**

记录倒序显示；点击展示时间、工具、选项与结果；详情提供“再次使用”；长按删除单条；底部清空全部必须二次确认；空列表显示“还没有保存过决定”。

- [ ] **Step 4: 实现设置页**

开关即时持久化；主题切换立即重绘；三个清除动作使用独立 AppStore 方法；关于区显示名称、1.0.0、隐私和使用说明。

- [ ] **Step 5: 运行测试和持久化验收**

Expected: 重启应用后设置、模板和历史保持；三种清除操作互不误删。

- [ ] **Step 6: 提交并推送**

```powershell
git add entry/src/main/ets/pages/History.ets entry/src/main/ets/pages/Settings.ets entry/src/main/ets/utils entry/src/main/ets/stores/AppStore.ets entry/src/ohosTest
git commit -m "feat: add history settings and data controls"
git push origin master
```

---

### Task 13: 完成资源、文档和全量验收

**Files:**
- Create: `AppScope/resources/base/media/app_icon.png`
- Create: `entry/src/main/resources/base/media/start_icon.png`
- Rewrite: `README.md`
- Rewrite: `README.en.md`
- Create: `docs/TESTING.md`
- Create: `docs/PRIVACY.md`
- Create: `docs/ACCEPTANCE.md`
- Modify: `.gitignore`

- [ ] **Step 1: 补齐应用图标和启动资源**

图标使用蓝色圆角底、白色分叉选择符号，不包含文字；启动背景使用 `#4A90D9`。

- [ ] **Step 2: 执行全量 Hypium 测试**

Run all registered suites from `List.test.ets`.

Expected: 所有测试通过，零失败。

- [ ] **Step 3: 执行干净构建**

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' clean --no-daemon
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p module=entry@default assembleHap --no-daemon
```

Expected: `TYPE CHECK SUCCESSFUL`、`BUILD SUCCESSFUL`，无 ArkTS 错误。

- [ ] **Step 4: 检查权限和仓库卫生**

```powershell
rg -n "requestPermissions|INTERNET|CAMERA|LOCATION|MICROPHONE|READ_MEDIA" AppScope entry/src/main
git status --short
git diff --check
```

Expected: 权限扫描无匹配；生成包、签名文件和构建目录未被 Git 跟踪；差异无空白错误。

- [ ] **Step 5: 按功能规格执行人工验收**

`docs/ACCEPTANCE.md` 必须记录六个工具、模板、历史、设置、离线、动画锁定、后台恢复、浅深色、小屏、大字体和折叠屏的逐项结果与证据。

- [ ] **Step 6: 更新 README**

README 写明 DevEco Studio 6.1.1、API 24、构建命令、运行步骤、零网络权限、项目结构和测试方法，不保留 Gitee 初始化模板占位文字。

- [ ] **Step 7: 提交并推送**

```powershell
git add AppScope entry README.md README.en.md docs .gitignore
git commit -m "docs: complete release assets and verification"
git push origin master
```

---

### Task 14: Claude Code 外部复核闭环

**Files:**
- Modify: 根据 Claude Code 反馈定位的文件
- Modify: `docs/ACCEPTANCE.md`

- [ ] **Step 1: 发送完成信号**

在现有 VS Code/Claude Code 会话中发送：

```text
Codex 已完成“做个决定”API 24 纯鸿蒙 v1.0。请对照 FUNCTIONAL_SPEC.md、
V1_DEVELOPMENT_DOC.md 和仓库 docs/ACCEPTANCE.md 检查功能完整性、ArkTS 规范、
API 24 构建、结果公平性、离线权限、持久化、生命周期和自适应布局。
请运行可执行的测试与构建。若存在问题，请给出具体文件、复现步骤和修改要求；
若全部满足，请明确回复“CLAUDE_CODE_ACCEPTED”。
```

- [ ] **Step 2: 对每条反馈先建立失败证据**

逻辑问题新增 Hypium 失败测试；UI 问题记录复现尺寸、页面和预期；构建问题保留完整错误输出。

- [ ] **Step 3: 修复并重新验证**

每轮必须运行相关测试、全量测试、干净 HAP 构建、权限扫描和 `git diff --check`。

- [ ] **Step 4: 每轮提交并推送**

```powershell
git add --update
git add entry/src/main entry/src/ohosTest docs/ACCEPTANCE.md
git commit -m "fix: address Claude Code review feedback"
git push origin master
```

- [ ] **Step 5: 重复复核直到完成信号**

只有 Claude Code 返回 `CLAUDE_CODE_ACCEPTED`，且该反馈之后最新提交通过全量验证，才可结束。

---

## 最终完成条件

- API 24 原生 ArkTS/ArkUI 工程可由 Hvigor 干净构建。
- 六大工具及模板、历史、设置、主题、生命周期全部满足功能规格。
- 模块不声明禁止权限，应用不依赖网络。
- Hypium 全量测试通过。
- `docs/ACCEPTANCE.md` 的所有条目有明确结果。
- 最新提交已推送到 `origin/master`。
- Claude Code 已返回 `CLAUDE_CODE_ACCEPTED`。
