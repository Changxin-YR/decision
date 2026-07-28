import { AppFontSizes, AppRadii, ThemeTokens } from '../../constants/DesignTokens';
import { AppButton, AppButtonVariant } from './AppButton';

@CustomDialog
export struct ConfirmDialog {
  controller: CustomDialogController;
  title: string = '确认操作';
  message: string = '';
  confirmLabel: string = '确认';
  colors: ThemeTokens;
  onConfirm: () => void = (): void => {
  };

  build() {
    Column({ space: 18 }) {
      Text(this.title)
        .width('100%')
        .fontSize(AppFontSizes.HEADING)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colors.text)
      Text(this.message)
        .width('100%')
        .fontSize(AppFontSizes.BODY)
        .fontColor(this.colors.subtext)
      Row({ space: 12 }) {
        AppButton({
          label: '取消',
          variant: AppButtonVariant.SECONDARY,
          onPress: (): void => this.controller.close()
        })
        AppButton({
          label: this.confirmLabel,
          variant: AppButtonVariant.DANGER,
          onPress: (): void => {
            this.controller.close();
            this.onConfirm();
          }
        })
      }
      .width('100%')
    }
    .padding(24)
    .backgroundColor(this.colors.card)
    .borderRadius(AppRadii.DIALOG)
  }
}
