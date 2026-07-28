import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { PageHeader } from '../components/common/PageHeader';
import { AppSpacing, ThemeTokens } from '../constants/DesignTokens';
import { RandomService } from '../domain/random/RandomService';
import { NumberValidator } from '../domain/validation/NumberValidator';
import { HistoryRecord, ToolType } from '../models/AppModels';
import { clipboardService } from '../services/ClipboardService';
import { feedbackService } from '../services/FeedbackService';
import { appStore } from '../stores/AppStore';

@Component
export struct RandomNumberPage {
  @Prop colors: ThemeTokens;
  onBack: () => void = (): void => {
  };
  @State private minText: string = '1';
  @State private maxText: string = '100';
  @State private countText: string = '1';
  @State private allowRepeat: boolean = false;
  @State private error: string = '';
  @State private resultText: string = '';
  @State private saved: boolean = false;
  private record: HistoryRecord | null = null;

  private generate(): void {
    const min: number = Number(this.minText);
    const max: number = Number(this.maxText);
    const count: number = Number(this.countText);
    const validation = NumberValidator.validate(min, max, count, this.allowRepeat);
    if (!validation.valid) {
      this.error = validation.message;
      return;
    }
    const values: number[] =
      RandomService.randomIntegers(min, max, count, this.allowRepeat);
    this.resultText = values.join('\n');
    this.error = '';
    this.saved = false;
    this.record = {
      id: `${Date.now()}`,
      toolType: ToolType.NUMBER,
      title: '随机数字',
      options: [`${min} 至 ${max}`, `数量 ${count}`],
      result: values.join(', '),
      createdAt: new Date().toISOString()
    };
    feedbackService.impact();
    if (appStore.settings.autoSaveHistory) {
      this.save();
    }
  }

  private async save(): Promise<void> {
    if (this.record === null || this.saved) {
      return;
    }
    this.saved = await appStore.saveHistoryRecord(this.record);
  }

  build() {
    Scroll() {
      Column({ space: AppSpacing.MD }) {
        PageHeader({
          title: '随机数字',
          subtitle: '支持负数与无重复抽取',
          colors: this.colors,
          onBack: (): void => this.onBack()
        })
        TextInput({ text: this.minText, placeholder: '最小值' })
          .type(InputType.Number)
          .onChange((value: string): void => {
            this.minText = value;
          })
        TextInput({ text: this.maxText, placeholder: '最大值' })
          .type(InputType.Number)
          .onChange((value: string): void => {
            this.maxText = value;
          })
        TextInput({ text: this.countText, placeholder: '数量' })
          .type(InputType.Number)
          .onChange((value: string): void => {
            this.countText = value;
          })
        Row() {
          Text('允许重复').fontColor(this.colors.text)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.allowRepeat })
            .onChange((value: boolean): void => {
              this.allowRepeat = value;
            })
        }
        if (this.error.length > 0) {
          Text(this.error).fontColor(this.colors.error)
        }
        AppButton({ label: '生成数字', onPress: (): void => this.generate() })
        if (this.resultText.length > 0) {
          Text(this.resultText)
            .width('100%')
            .padding(18)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
            .backgroundColor(this.colors.card)
            .borderRadius(12)
          Row({ space: 12 }) {
            AppButton({
              label: '复制',
              variant: AppButtonVariant.SECONDARY,
              onPress: (): void => {
                clipboardService.copyLines(this.resultText.split('\n'));
              }
            })
            AppButton({
              label: this.saved ? '已保存' : '保存',
              isEnabled: !this.saved,
              onPress: (): void => {
                this.save();
              }
            })
          }
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.colors.background)
  }
}
