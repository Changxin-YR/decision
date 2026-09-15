import { AppFontSizes, ThemeTokens } from '../../constants/DesignTokens';

@Component
export struct PageHeader {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop showBack: boolean = true;
  @Prop colors: ThemeTokens;
  @Prop backButtonSize: number = 48;
  @Prop backButtonRadius: number = 14;
  @Prop rightLabel: string = '';
  @Prop rightGlyph: string = '';
  onBack: () => void = (): void => {
  };
  onRightPress: () => void = (): void => {
  };

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column({ space: 3 }) {
        Text(this.title)
          .fontSize(AppFontSizes.PAGE_TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.colors.text)
          .textAlign(TextAlign.Center)
          .maxLines(2)
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(AppFontSizes.CAPTION)
            .fontColor(this.colors.subtext)
            .textAlign(TextAlign.Center)
            .maxLines(1)
        }
      }
      .constraintSize({ maxWidth: 250 })
      .alignItems(HorizontalAlign.Center)

      Row() {
        if (this.showBack) {
          Button('‹', { type: ButtonType.Normal })
            .width(this.backButtonSize)
            .height(this.backButtonSize)
            .fontSize(34)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors.text)
            .backgroundColor(this.colors.card)
            .border({ width: 1, color: this.colors.border })
            .borderRadius(this.backButtonRadius)
            .shadow({
              radius: 9,
              color: this.colors.shadow,
              offsetX: 0,
              offsetY: 2
            })
            .onClick((): void => this.onBack())
        }
        Blank()
        if (this.rightLabel.length > 0) {
          Button(this.rightLabel, { type: ButtonType.Normal })
            .height(44)
            .fontSize(AppFontSizes.BODY)
            .fontColor(this.colors.accent)
            .backgroundColor(this.colors.card)
            .border({ width: 1, color: this.colors.border })
            .borderRadius(14)
            .onClick((): void => this.onRightPress())
        }
        if (this.rightGlyph.length > 0) {
          Text(this.rightGlyph)
            .width(44)
            .height(44)
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors.accent)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.colors.card)
            .borderRadius(14)
            .border({ width: 1, color: this.colors.border })
            .shadow({
              radius: 8,
              color: this.colors.shadow,
              offsetX: 0,
              offsetY: 2
            })
            .onClick((): void => this.onRightPress())
        }
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(68)
  }
}
