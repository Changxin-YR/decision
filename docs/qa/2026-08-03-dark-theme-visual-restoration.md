# 2026-08-03 夜间模式视觉还原 QA

- 深色主题令牌回归：先新增 `ThemeResolver.test.ets` 的深色令牌断言，确认因字段缺失构建失败；实现后测试 HAP 构建成功。
- 静态检查：`scripts/check-standard.ps1` 通过；仅保留项目原有的 `common/` 职责目录和 `2in1` 声明建议。
- HAP 构建：主 HAP 与 ohosTest HAP 均 `BUILD SUCCESSFUL`。
- 设备验证：本轮未执行，状态为 `blocked`；未将其表述为已验收。
