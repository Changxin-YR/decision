import {
  AppFontSizes,
  AppSpacing,
  ThemeResolver,
  ThemeTokens
} from '../constants/DesignTokens';
import { ThemeMode } from '../models/AppModels';
import { PageHeader } from '../components/common/PageHeader';

@Component
export struct PrivacyContent {
  @Prop colors: ThemeTokens;
  onBack: () => void = (): void => {
  };

  build() {
    Column({ space: AppSpacing.MD }) {
      PageHeader({
        title: '隐私说明',
        subtitle: '你的决定只属于你',
        colors: this.colors,
        onBack: (): void => this.onBack()
      })
      Scroll() {
        Column({ space: AppSpacing.MD }) {
          Text('全部数据都保存在本机')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
          Text('“做个决定”只在本机保存你的设置、自定义模板和你主动保存的历史记录。')
            .fontSize(AppFontSizes.BODY)
            .fontColor(this.colors.text)
          Text('不连接网络')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
          Text('应用不需要网络，不上传任何内容，也不包含账号、广告、统计或云同步。')
            .fontSize(AppFontSizes.BODY)
            .fontColor(this.colors.text)
          Text('不采集个人数据')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
          Text('应用不采集身份、位置、相册、通讯录、麦克风或其他个人信息。复制结果时，仅把你看到的结果写入系统剪贴板。')
            .fontSize(AppFontSizes.BODY)
            .fontColor(this.colors.text)
          Text('删除方式')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
          Text('你可以在设置中分别清除历史、模板或全部本地数据。卸载应用也会删除全部应用数据。')
            .fontSize(AppFontSizes.BODY)
            .fontColor(this.colors.text)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ bottom: 32 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 18 })
    .backgroundColor(this.colors.background)
  }
}

@Entry
@Component
struct Privacy {
  private colors: ThemeTokens = ThemeResolver.resolve(ThemeMode.SYSTEM, false);

  build() {
    Column() {
      PrivacyContent({
        colors: this.colors,
        onBack: (): void => {
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
