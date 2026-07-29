# Image2 批准源图

本项目 UI 还原以用户提供的 `C:\Users\27363\Desktop\decision_jpg` 为批准源。
12 张 JPG 的文件名与页面映射见
`docs/superpowers/specs/2026-07-29-ui-restoration-design.md`。

生产资源由 `scripts/prepare-ui-assets.ps1` 从批准源图确定性裁切，不重新设计主体。
原始源图保留在用户提供目录，仓库保存派生资源、裁切参数和用途清单。
