import { AppRadii, ThemeTokens } from '../../constants/DesignTokens';

@Component
export struct AppCard {
  @Prop colors: ThemeTokens;
  @Prop contentPadding: number = 16;
  @BuilderParam content: () => void;

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(this.contentPadding)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.colors.card)
    .borderRadius(AppRadii.CARD)
    .border({ width: 1, color: this.colors.border })
    .shadow({
      radius: 10,
      color: '#0D27496B',
      offsetX: 0,
      offsetY: 3
    })
  }
}
