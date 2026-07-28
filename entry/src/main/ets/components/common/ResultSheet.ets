import {
  AppFontSizes,
  AppRadii,
  ThemeTokens
} from '../../constants/DesignTokens';
import { AppStrings } from '../../constants/AppStrings';
import { AppButton, AppButtonVariant } from './AppButton';

@Component
export struct ResultSheet {
  @Prop visible: boolean = false;
  @Prop title: string = AppStrings.RESULT_TITLE;
  @Prop result: string = '';
  @Prop colors: ThemeTokens;
  @Prop showRetry: boolean = false;
  @Prop retryLabel: string = AppStrings.RETRY;
  onClose: () => void = (): void => {
  };
  onRetry: () => void = (): void => {
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
          if (this.showRetry) {
            AppButton({
              label: this.retryLabel,
              onPress: (): void => this.onRetry()
            })
          }
          AppButton({
            label: AppStrings.CLOSE_RESULT,
            variant: this.showRetry ? AppButtonVariant.SECONDARY : AppButtonVariant.PRIMARY,
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
