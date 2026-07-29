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
  @Prop isEnabled: boolean = true;
  @Prop fullWidth: boolean = true;
  @Prop buttonHeight: number = 48;
  @Prop radius: number = AppRadii.PRIMARY_BUTTON;
  onPress: () => void = (): void => {
  };

  private buttonBackground(): string {
    if (this.variant === AppButtonVariant.TEXT) {
      return '#00000000';
    }
    if (this.variant === AppButtonVariant.SECONDARY) {
      return '#FFFFFF';
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
      return AppColors.PRIMARY;
    }
    return '#FFFFFF';
  }

  build() {
    Button(this.label, { type: ButtonType.Normal })
      .width(this.fullWidth ? '100%' : 'auto')
      .height(this.buttonHeight)
      .fontSize(AppFontSizes.BODY)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.foreground())
      .backgroundColor(this.buttonBackground())
      .borderRadius(this.radius)
      .border({
        width: this.variant === AppButtonVariant.SECONDARY ? 1 : 0,
        color: this.variant === AppButtonVariant.SECONDARY ?
          AppColors.PRIMARY : '#00000000'
      })
      .shadow(this.variant === AppButtonVariant.PRIMARY ? {
        radius: 10,
        color: '#292D94F4',
        offsetX: 0,
        offsetY: 4
      } : {
        radius: 0,
        color: '#00000000',
        offsetX: 0,
        offsetY: 0
      })
      .opacity(this.isEnabled ? 1 : 0.45)
      .enabled(this.isEnabled)
      .onClick((): void => this.onPress())
  }
}
