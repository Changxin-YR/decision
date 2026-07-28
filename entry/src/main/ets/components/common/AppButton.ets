import { AppColors, AppFontSizes, AppRadii } from '../../constants/DesignTokens';

export enum AppButtonVariant {
  PRIMARY = 'primary',
  SECONDARY = 'secondary',
  TEXT = 'text',
  DANGER = 'danger'
}

@Component
export struct AppButton {
  @Prop label: string = '';
  @Prop variant: AppButtonVariant = AppButtonVariant.PRIMARY;
  @Prop enabled: boolean = true;
  @Prop fullWidth: boolean = true;
  onPress: () => void = (): void => {
  };

  private background(): string {
    if (this.variant === AppButtonVariant.TEXT) {
      return '#00000000';
    }
    if (this.variant === AppButtonVariant.SECONDARY) {
      return '#E8F2FC';
    }
    if (this.variant === AppButtonVariant.DANGER) {
      return AppColors.ERROR;
    }
    return AppColors.PRIMARY;
  }

  private foreground(): string {
    if (this.variant === AppButtonVariant.TEXT) {
      return AppColors.PRIMARY;
    }
    if (this.variant === AppButtonVariant.SECONDARY) {
      return '#28679F';
    }
    return '#FFFFFF';
  }

  build() {
    Button(this.label, { type: ButtonType.Normal })
      .width(this.fullWidth ? '100%' : 'auto')
      .height(48)
      .fontSize(AppFontSizes.BODY)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.foreground())
      .backgroundColor(this.background())
      .borderRadius(AppRadii.CARD)
      .opacity(this.enabled ? 1 : 0.45)
      .enabled(this.enabled)
      .onClick((): void => this.onPress())
  }
}
