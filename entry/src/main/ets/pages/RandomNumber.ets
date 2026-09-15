import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { PageHeader } from '../components/common/PageHeader';
import { AppFontSizes, AppSpacing, ThemeTokens } from '../constants/DesignTokens';
import { AppStrings } from '../constants/AppStrings';
import { RandomService } from '../domain/random/RandomService';
import { QuickRangePreset, QuickRangeValue } from '../domain/random/QuickRangePreset';
import { NumberValidator } from '../domain/validation/NumberValidator';
import { HistoryRecord, ToolType } from '../models/AppModels';
import { clipboardService } from '../services/ClipboardService';
import { feedbackService } from '../services/FeedbackService';
import { SoundEffect, soundService } from '../services/SoundService';
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
  @State private selectedRange: string = '1–100';
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
    soundService.play(SoundEffect.RESULT);
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

  private async copyResult(): Promise<void> {
    const copied: boolean =
      await clipboardService.copyLines(this.resultText.split('\n'));
    try {
      this.getUIContext().getPromptAction().showToast({
        message: copied ? AppStrings.COPY_SUCCESS : AppStrings.COPY_FAILED
      });
    } catch (_error) {
    }
  }

  private applyQuickRange(range: string): void {
    this.selectedRange = range;
    if (range === '自定义') {
      return;
    }
    const value: QuickRangeValue = QuickRangePreset.resolve(range);
    this.minText = value.min;
    this.maxText = value.max;
    this.error = '';
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        PageHeader({
          title: '随机数字',
          subtitle: '支持负数·无重复抽取',
          colors: this.colors,
          onBack: (): void => this.onBack()
        })
        Column({ space: 12 }) {
          Text('设置范围')
            .width('100%')
            .fontSize(AppFontSizes.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors.text)
          Row() {
            Column({ space: 2 }) {
              Text('最小值').fontSize(AppFontSizes.CAPTION).fontColor(this.colors.text)
              Text('可输入负数').fontSize(9).fontColor(this.colors.subtext)
            }
            .layoutWeight(1).alignItems(HorizontalAlign.Start)
            TextInput({ text: this.minText })
              .width(86).height(42).type(InputType.Normal)
              .fontSize(AppFontSizes.BODY)
              .fontColor(this.colors.isDark ? '#FFFFFF' : this.colors.text)
              .backgroundColor(this.colors.input)
              .border({ width: 1, color: this.colors.border })
              .borderRadius(22)
              .onChange((value: string): void => {
                this.minText = value;
                this.selectedRange = QuickRangePreset.match(value, this.maxText);
              })
          }
          Row() {
            Column({ space: 2 }) {
              Text('最大值').fontSize(AppFontSizes.CAPTION).fontColor(this.colors.text)
              Text('必须大于最小值').fontSize(9).fontColor(this.colors.subtext)
            }
            .layoutWeight(1).alignItems(HorizontalAlign.Start)
            TextInput({ text: this.maxText })
              .width(86).height(42).type(InputType.Normal)
              .fontSize(AppFontSizes.BODY)
              .fontColor(this.colors.isDark ? '#FFFFFF' : this.colors.text)
              .backgroundColor(this.colors.input)
              .border({ width: 1, color: this.colors.border })
              .borderRadius(22)
              .onChange((value: string): void => {
                this.maxText = value;
                this.selectedRange = QuickRangePreset.match(this.minText, value);
              })
          }
          Row() {
            Column({ space: 2 }) {
              Text('抽取数量').fontSize(AppFontSizes.CAPTION).fontColor(this.colors.text)
              Text('1-100').fontSize(9).fontColor(this.colors.subtext)
            }
            .layoutWeight(1).alignItems(HorizontalAlign.Start)
            TextInput({ text: this.countText })
              .width(86).height(42).type(InputType.Number)
              .fontSize(AppFontSizes.BODY)
              .fontColor(this.colors.isDark ? '#FFFFFF' : this.colors.text)
              .backgroundColor(this.colors.input)
              .border({ width: 1, color: this.colors.border })
              .borderRadius(22)
              .onChange((value: string): void => { this.countText = value; })
          }
          Row() {
            Column({ space: 2 }) {
              Text('允许重复').fontSize(AppFontSizes.CAPTION).fontColor(this.colors.text)
              Text('关闭时不会抽中相同数字').fontSize(9).fontColor(this.colors.subtext)
            }
            .layoutWeight(1).alignItems(HorizontalAlign.Start)
            Toggle({ type: ToggleType.Switch, isOn: this.allowRepeat })
              .onChange((value: boolean): void => { this.allowRepeat = value; })
          }
        }
        .width('100%')
        .padding(18)
        .backgroundColor(this.colors.card)
        .borderRadius(12)
        .shadow({ radius: 8, color: this.colors.shadow, offsetX: 0, offsetY: 3 })

        if (this.error.length > 0) {
          Text(this.error).fontColor(this.colors.error)
        }
        Column({ space: 18 }) {
          Text('抽取结果')
            .width('100%')
            .fontSize(AppFontSizes.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors.text)
          Text(this.resultText.length > 0 ? this.resultText : '—')
            .fontSize(this.resultText.length > 0 ? 72 : 56)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.resultText.length > 0 ? this.colors.accent : this.colors.subtext)
            .textAlign(TextAlign.Center)
          Row({ space: 8 }) {
            ForEach(['1–10', '1–100', '1–1000', '自定义'], (range: string): void => {
              Button(range, { type: ButtonType.Normal })
                .layoutWeight(1).height(36).fontSize(11)
                .fontColor(range === this.selectedRange ? '#FFFFFF' : this.colors.text)
                .backgroundColor(range === this.selectedRange ?
                  this.colors.accent : this.colors.background)
                .borderRadius(14)
                .onClick((): void => this.applyQuickRange(range))
            })
          }
        }
        .width('100%')
        .constraintSize({ minHeight: 210 })
        .padding(18)
        .backgroundColor(this.colors.card)
        .borderRadius(12)
        .shadow({ radius: 8, color: this.colors.shadow, offsetX: 0, offsetY: 3 })

        AppButton({ colors: this.colors, label: '◇  生成数字', onPress: (): void => this.generate() })
        if (this.resultText.length > 0) {
          Column({ space: 12 }) {
            AppButton({
              colors: this.colors,
              label: '复制',
              variant: AppButtonVariant.SECONDARY,
              onPress: (): void => {
                this.copyResult();
              }
            })
            AppButton({
              colors: this.colors,
              label: this.saved ? '已保存' : '保存',
              isEnabled: !this.saved,
              onPress: (): void => {
                this.save();
              }
            })
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 36 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .constraintSize({ maxWidth: 720 })
    .backgroundColor(this.colors.background)
  }
}
