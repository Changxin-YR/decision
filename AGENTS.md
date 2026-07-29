# 做个决定项目规则

本文件适用于项目根目录及全部子目录。

## 项目边界

- 项目类型：HarmonyOS Stage 模型 ArkTS/ArkUI 应用。
- 业务源码：`entry/src/main/ets/`。
- 页面位于 `pages/`，复用 UI 位于 `components/`，数据能力位于 `services/`。
- 模型、常量和工具分别位于 `models/`、`constants/`、`utils/`。
- 应用资源：`entry/src/main/resources/`。
- 不修改项目范围外的文件，不改变包名、签名身份或发布元数据。

## 标准流程

1. 开始前阅读 `README.md`、`tasks.md`、`changes.md`、`design.md` 和 `design-qa.md`。
2. 在 `tasks.md` 登记任务，状态只使用 `pending`、`in_progress`、`done`、`blocked`。
3. 保持改动与用户需求一致，不顺带重构业务、存储和随机算法。
4. 用户可见交互变更同步更新设计说明和 QA 证据。
5. 完成后执行静态检查、HAP 构建和与风险相称的设备验证。

## ArkTS 与 ArkUI

- 使用明确的 ArkTS 类型，共享颜色、间距和尺寸集中在设计令牌中。
- 页面负责组合和交互；规则、存储与系统能力保留在现有职责模块。
- 路由、资源名和 `$r('app.xxx.xxx')` 引用必须与资源目录一致。
- phone 竖屏是设计稿逐像素目标；tablet 保持响应式可用，不伪造未执行的设备结论。

## 验证

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1
```

设备证据保存至 `docs/qa/`，不得写入密钥、签名口令、令牌或用户隐私。
