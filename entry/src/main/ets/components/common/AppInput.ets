import { AppFontSizes, AppRadii, ThemeTokens } from '../../constants/DesignTokens';

@Component
export struct AppInput {
  @Link value: string;
  @Prop placeholder: string = '';
  @Prop error: string = '';
  @Prop enabled: boolean = true;
  @Prop colors: ThemeTokens;
  @State private focused: boolean = false;

  build() {
    Column({ space: 6 }) {
      TextInput({ text: this.value, placeholder: this.placeholder })
        .width('100%')
        .height(46)
        .fontSize(AppFontSizes.BODY)
        .fontColor(this.colors.text)
        .placeholderColor(this.colors.subtext)
        .backgroundColor(this.colors.card)
        .borderRadius(AppRadii.INPUT)
        .border({
          width: this.focused || this.error.length > 0 ? 2 : 1,
          color: this.error.length > 0 ? this.colors.error :
            (this.focused ? this.colors.accent : this.colors.border)
        })
        .enabled(this.enabled)
        .onFocus((): void => {
          this.focused = true;
        })
        .onBlur((): void => {
          this.focused = false;
        })
        .onChange((next: string): void => {
          this.value = next;
        })

      if (this.error.length > 0) {
        Text(this.error)
          .fontSize(13)
          .fontColor(this.colors.error)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
