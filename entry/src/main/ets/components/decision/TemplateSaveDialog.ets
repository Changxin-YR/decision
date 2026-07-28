import {
  AppFontSizes,
  AppLimits,
  AppRadii,
  ThemeResolver,
  ThemeTokens
} from '../../constants/DesignTokens';
import {
  OptionValidator,
  ValidationResult
} from '../../domain/validation/OptionValidator';
import { ThemeMode } from '../../models/AppModels';
import { AppButton, AppButtonVariant } from '../common/AppButton';

@CustomDialog
export struct TemplateSaveDialog {
  controller: CustomDialogController;
  colors: ThemeTokens = ThemeResolver.resolve(ThemeMode.SYSTEM, false);
  onSave: (name: string) => Promise<boolean> =
    async (_name: string): Promise<boolean> => false;
  @State private name: string = '';
  @State private error: string = '';
  @State private saving: boolean = false;

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch {
    }
  }

  private async save(): Promise<void> {
    const result: ValidationResult = OptionValidator.validateTemplateName(this.name);
    this.error = result.message;
    if (!result.valid || this.saving) {
      return;
    }
    this.saving = true;
    const saved: boolean = await this.onSave(this.name.trim());
    this.saving = false;
    if (saved) {
      this.controller.close();
      this.showToast('模板已保存');
      return;
    }
    this.showToast('模板保存失败，请重试');
  }

  build() {
    Column({ space: 16 }) {
      Text('保存为模板')
        .width('100%')
        .fontSize(AppFontSizes.HEADING)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colors.text)
      Text('模板会保存在本机，并立即出现在首页。')
        .width('100%')
        .fontSize(AppFontSizes.CAPTION)
        .fontColor(this.colors.subtext)
      TextInput({
        text: this.name,
        placeholder: `模板名称（最多 ${AppLimits.MAX_TEMPLATE_NAME_LENGTH} 字）`
      })
        .width('100%')
        .height(46)
        .maxLength(AppLimits.MAX_TEMPLATE_NAME_LENGTH)
        .fontSize(AppFontSizes.BODY)
        .fontColor(this.colors.text)
        .backgroundColor(this.colors.card)
        .borderRadius(AppRadii.INPUT)
        .border({
          width: this.error.length > 0 ? 2 : 1,
          color: this.error.length > 0 ? this.colors.error : this.colors.border
        })
        .enabled(!this.saving)
        .onChange((value: string): void => {
          this.name = value;
          this.error = '';
        })
      if (this.error.length > 0) {
        Text(this.error)
          .width('100%')
          .fontSize(AppFontSizes.CAPTION)
          .fontColor(this.colors.error)
      }
      Column({ space: 12 }) {
        AppButton({
          label: '取消',
          variant: AppButtonVariant.SECONDARY,
          isEnabled: !this.saving,
          onPress: (): void => this.controller.close()
        })
        AppButton({
          label: this.saving ? '保存中…' : '保存',
          isEnabled: !this.saving,
          onPress: (): void => {
            this.save();
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
