import { ThemeTokens } from '../../constants/DesignTokens';

@Component
export struct DrawTube {
  @Prop colors: ThemeTokens;
  @Prop shakeAngle: number = 0;
  @Prop shakeY: number = 0;
  @Prop stickOffset: number = 0;
  @Prop stickOpacity: number = 0;
  @Prop stickScale: number = 1;
  @Prop revealGlow: number = 0;
  @Prop liftedLabel: string = '';

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle({ width: 126, height: 126 })
        .fill(this.colors.accent)
        .opacity(this.revealGlow * 0.18)
        .scale({
          x: 0.92 + this.revealGlow * 0.08,
          y: 0.92 + this.revealGlow * 0.08
        })
        .translate({ y: this.stickOffset * 0.25 - 24 })

      Image($r('app.media.ui_draw_box'))
        .width(260)
        .height(260)
        .objectFit(ImageFit.Contain)
        .rotate({ angle: this.shakeAngle })
        .translate({ y: this.shakeY })

      if (this.liftedLabel.length > 0) {
        Column({ space: 0 }) {
          Text(this.liftedLabel)
            .constraintSize({ maxWidth: 180 })
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(this.colors.card)
            .border({ width: 1, color: this.colors.border })
            .borderRadius(8)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Rect({ width: 16, height: 86 })
            .radius(8)
            .fill('#4A90D9')
        }
        .opacity(this.stickOpacity)
        .scale({ x: this.stickScale, y: this.stickScale })
        .translate({ y: this.stickOffset * 0.25 + 6 })
      }
    }
    .width('100%')
    .height(240)
    .clip(true)
  }
}
