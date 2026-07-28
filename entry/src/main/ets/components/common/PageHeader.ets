import { AppFontSizes, ThemeTokens } from '../../constants/DesignTokens';

@Component
export struct PageHeader {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop showBack: boolean = true;
  @Prop colors: ThemeTokens;
  onBack: () => void = (): void => {
  };

  build() {
    Row({ space: 12 }) {
      if (this.showBack) {
        Button('‹', { type: ButtonType.Circle })
          .width(42)
          .height(42)
          .fontSize(30)
          .fontColor(this.colors.text)
          .backgroundColor(this.colors.card)
          .onClick((): void => this.onBack())
      }
      Column({ space: 3 }) {
        Text(this.title)
          .fontSize(AppFontSizes.TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.colors.text)
          .maxLines(2)
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(AppFontSizes.CAPTION)
            .fontColor(this.colors.subtext)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}
