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
      Image(this.colors.isDark ?
        $r('app.media.ui_coin_dark') : $r('app.media.ui_coin'))
        .width(250)
        .height(274)
        .objectFit(ImageFit.Contain)
        .rotate({ y: 1, angle: this.rotation })
    }
    .width(270)
    .height(286)
  }
}
