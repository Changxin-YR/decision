import { CoinSide } from '../../models/AppModels';
import { ThemeTokens } from '../../constants/DesignTokens';

@Component
export struct CoinView {
  @Prop rotation: number = 0;
  @Prop side: CoinSide = CoinSide.HEADS;
  @Prop revealed: boolean = false;
  @Prop colors: ThemeTokens;

  build() {
    Stack() {
      Image($r('app.media.ui_coin'))
        .width(250)
        .height(274)
        .objectFit(ImageFit.Contain)
        .rotate({ y: 1, angle: this.rotation })
      if (this.revealed) {
        Text(this.side === CoinSide.HEADS ? '正' : '反')
          .fontSize(38)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.colors.accent)
          .backgroundColor('#CCFFFFFF')
          .borderRadius(36)
          .padding(16)
      }
    }
    .width(270)
    .height(286)
  }
}
