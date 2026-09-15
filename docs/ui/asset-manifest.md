# UI 资源清单

| 资源 | 批准源图 | 裁切矩形 | 用途 |
| --- | --- | --- | --- |
| `ui_draw_box.png` | `1ace3e03-13b6-45ea-8b05-c1258ba1f7a6.jpg` | `120,390,620,620` | 抽签页主插画 |
| `ui_finger_guide.png` | `33655a8a-fcbb-4a14-8eac-58e55f988d0c.jpg` | `100,510,660,710` | 指尖选择空闲态 |
| `ui_coin.png` | `a6939ca5-15c2-4357-8700-6cb5ec6b51d9.jpg` | `180,430,520,570` | 抛硬币初始态 |
| `ui_coin_dark.png` | 用户硬币参考图，SHA-256 `3946B415277597DDFD1912B4A43EBEDA0060EFAEAE698D0462CF858C9B57E83D` | 椭圆主体遮罩与边缘清理，见 `restore-approved-ui-assets.ps1` | 深色抛硬币初始态 |
| `ui_home_*.png` | `27091e94-4671-46df-a81d-378bb76e8f16.jpg` | 见 `prepare-ui-assets.ps1` | 首页六工具及历史/设置图标 |
| `ui_home_*_dark.png` | 用户最新深色首页参考图，SHA-256 `08ABFEBD290DA393EA2384CF1BED373A4B7864C35537A666890891C9BE236282` | 见 `restore-approved-ui-assets.ps1` | 独立深色首页工具、历史和设置图标 |
| `ui_quick_*.png` | `27091e94-4671-46df-a81d-378bb76e8f16.jpg` | 见 `prepare-ui-assets.ps1` | 四个快捷模板图标 |
| `ui_history_*.png` | `4b61dbed-4c98-440d-a33c-3fc3838c1db6.jpg` | 见 `prepare-ui-assets.ps1` | 历史清空及工具类型图标 |
| `app_icon_foreground.png` | `Gemini_Generated_Image_cy0zdgcy0zdgcy0z(1).png` | 提取中央获批图标主体；1024×1024 RGBA | AppScope/EntryAbility 分层图标前景与启动窗口 |
| `app_icon_background.png` | 同上 | 取获批图标冷白底色；1024×1024 RGB 满画布 | AppScope/EntryAbility 分层图标背景 |

资源包含批准设计稿的冷白背景，用于浅色主题逐像素还原。深色主题保持功能可用，
但其插画背景不作为本轮逐像素验收对象。

浅色首页的 12 个资源继续使用任务开始前的获批版本，恢复脚本不覆盖它们；脚本只确定性生成深色首页与深色硬币资源。

应用图标源文件位于用户提供目录 `C:\Users\27363\Desktop`，SHA-256 为
`F439622F74ED26F23140BB12E76B73365677593111EE357C005C34D9E152FC9B`。
源图棋盘格为实际像素，不直接打包；两套 AppScope/entry 派生资源保持相同哈希。
