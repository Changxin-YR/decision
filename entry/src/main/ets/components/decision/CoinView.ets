import { CoinSide } from '../../models/AppModels';
import { ThemeTokens } from '../../constants/DesignTokens';

@Component
export struct CoinView {
  @Prop rotation: number = 0;
  @Prop side: CoinSide = CoinSide.HEADS;
  @Prop colors: ThemeTokens;

  build() {
    Stack() {
      Circle()
        .width(190)
        .height(190)
        .fill('#E7B83B')
        .stroke('#C68E19')
        .strokeWidth(8)
      Text(this.side === CoinSide.HEADS ? '正' : '反')
        .fontSize(66)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFF8DC')
    }
    .width(210)
    .height(210)
    .rotate({ y: 1, angle: this.rotation })
  }
}
