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

  @Builder
  private privacyCard(title: string, body: string) {
    Column({ space: 10 }) {
      Text(title)
        .width('100%')
        .fontSize(AppFontSizes.HEADING)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colors.text)
      Text(body)
        .width('100%')
        .fontSize(AppFontSizes.BODY)
        .fontColor(this.colors.subtext)
        .lineHeight(24)
    }
    .width('100%')
    .padding(18)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.colors.card)
    .borderRadius(12)
    .border({ width: 1, color: this.colors.border })
    .shadow({
      radius: 9,
      color: '#0D27496B',
      offsetX: 0,
      offsetY: 3
    })
  }

  build() {
    Column({ space: 18 }) {
      PageHeader({
        title: '隐私说明',
        subtitle: '你的决定只属于你',
        colors: this.colors,
        onBack: (): void => this.onBack()
      })
      Scroll() {
        Column({ space: 16 }) {
          Text('简单、透明、只在本机')
            .width('100%')
            .fontSize(AppFontSizes.BODY)
            .fontColor(this.colors.subtext)
            .textAlign(TextAlign.Center)
            .padding({ bottom: 2 })
          this.privacyCard(
            '全部数据都保存在本机',
            '“做个决定”只在本机保存你的设置、自定义模板和你主动保存的历史记录。'
          )
          this.privacyCard(
            '不连接网络',
            '应用不需要网络，不上传任何内容，也不包含账号、广告、统计或云同步。'
          )
          this.privacyCard(
            '不采集个人数据',
            '应用不采集身份、位置、相册、通讯录、麦克风或其他个人信息。复制结果时，仅把你看到的结果写入系统剪贴板。'
          )
          this.privacyCard(
            '删除方式',
            '你可以在设置中分别清除历史、模板或全部本地数据。卸载应用也会删除全部应用数据。'
          )
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ bottom: 36 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 14 })
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
