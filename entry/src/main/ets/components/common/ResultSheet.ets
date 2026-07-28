import {
  AppFontSizes,
  AppRadii,
  ThemeTokens
} from '../../constants/DesignTokens';
import { AppButton } from './AppButton';

@Component
export struct ResultSheet {
  @Prop visible: boolean = false;
  @Prop title: string = '决定结果';
  @Prop result: string = '';
  @Prop colors: ThemeTokens;
  onClose: () => void = (): void => {
  };

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')

        Column({ space: 20 }) {
          Text(this.title)
            .fontSize(AppFontSizes.CAPTION)
            .fontColor(this.colors.subtext)
          Text(this.result)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
            .textAlign(TextAlign.Center)
          AppButton({
            label: '知道了',
            onPress: (): void => this.onClose()
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 28, bottom: 32 })
        .backgroundColor(this.colors.card)
        .borderRadius({
          topLeft: AppRadii.DIALOG,
          topRight: AppRadii.DIALOG
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}
