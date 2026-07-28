import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { PageHeader } from '../components/common/PageHeader';
import { ResultSheet } from '../components/common/ResultSheet';
import { OptionsEditor } from '../components/decision/OptionsEditor';
import { TemplateSaveDialog } from '../components/decision/TemplateSaveDialog';
import { WheelCanvas } from '../components/decision/WheelCanvas';
import {
  AppFontSizes,
  AppSpacing,
  ThemeTokens
} from '../constants/DesignTokens';
import { OptionEditorState } from '../domain/state/OptionEditorState';
import {
  WheelSession,
  WheelSpin
} from '../domain/state/WheelSession';
import {
  DecisionOption,
  HistoryRecord,
  ToolType
} from '../models/AppModels';
import { appLifecycleBus } from '../services/AppLifecycleBus';
import { feedbackService } from '../services/FeedbackService';
import { SoundEffect, soundService } from '../services/SoundService';
import { appStore } from '../stores/AppStore';

@Component
export struct WheelPage {
  @Prop colors: ThemeTokens;
  @Prop initialTitle: string = '';
  @Prop initialOptions: string[] = [];
  onBack: () => void = (): void => {
  };
  @State private options: DecisionOption[] = [];
  @State private error: string = '';
  @State private rotation: number = 0;
  @State private running: boolean = false;
  @State private result: string = '';
  @State private saved: boolean = false;
  private editor: OptionEditorState = new OptionEditorState();
  private session: WheelSession = new WheelSession();
  private timerId: number = -1;
  private unsubscribe: (() => void) | null = null;
  private record: HistoryRecord | null = null;
  private templateDialog: CustomDialogController = new CustomDialogController({
    builder: TemplateSaveDialog({
      colors: this.colors,
      onSave: async (name: string): Promise<boolean> => {
        return appStore.createCustomTemplate(
          name,
          ToolType.WHEEL,
          this.editor.texts()
        );
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear(): void {
    const initial: string[] = this.initialOptions.length >= 2 ?
      this.initialOptions : ['', ''];
    this.editor = new OptionEditorState(initial);
    this.syncOptions();
    this.unsubscribe = appLifecycleBus.subscribe((background: boolean): void => {
      if (background) {
        this.cancel();
      }
    });
  }

  aboutToDisappear(): void {
    this.cancel();
    if (this.unsubscribe !== null) {
      this.unsubscribe();
      this.unsubscribe = null;
    }
  }

  private syncOptions(): void {
    this.options = Array.from(this.editor.options);
  }

  private updateOption(id: string, text: string): void {
    this.editor.update(id, text);
    this.syncOptions();
    this.error = '';
  }

  private removeOption(id: string): void {
    this.editor.remove(id);
    this.syncOptions();
    this.error = '';
  }

  private moveOption(from: number, to: number): void {
    this.editor.move(from, to);
    this.syncOptions();
  }

  private addOption(): void {
    this.editor.add();
    this.syncOptions();
  }

  private cancel(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
    this.session.cancel();
    this.running = false;
  }

  private spin(): void {
    const validation = this.editor.validate();
    if (!validation.valid) {
      this.error = validation.message;
      return;
    }
    const values: string[] =
      this.editor.texts().map((value: string): string => value.trim());
    const spin: WheelSpin | null = this.session.start(values);
    if (spin === null) {
      return;
    }
    this.error = '';
    this.running = true;
    this.result = '';
    this.saved = false;
    this.record = null;
    soundService.play(SoundEffect.WHEEL);
    const base: number = Math.ceil(this.rotation / 360) * 360;
    this.getUIContext().animateTo({
      duration: 3600,
      curve: Curve.EaseOut
    }, (): void => {
      this.rotation = base + spin.targetAngle;
    });
    this.timerId = setTimeout((): void => {
      this.timerId = -1;
      if (!this.session.complete()) {
        return;
      }
      this.running = false;
      this.result = spin.result;
      this.record = {
        id: `${Date.now()}`,
        toolType: ToolType.WHEEL,
        title: this.initialTitle.trim().length > 0 ?
          this.initialTitle.trim() : '幸运转盘',
        options: values,
        result: spin.result,
        createdAt: new Date().toISOString()
      };
      feedbackService.impact();
      soundService.play(SoundEffect.RESULT);
      if (appStore.settings.autoSaveHistory) {
        this.save();
      }
    }, 3600);
  }

  private async save(): Promise<void> {
    if (this.record === null || this.saved) {
      return;
    }
    this.saved = await appStore.saveHistoryRecord(this.record);
  }

  private openTemplateDialog(): void {
    const validation = this.editor.validate();
    if (!validation.valid) {
      this.error = validation.message;
      return;
    }
    this.templateDialog.open();
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: AppSpacing.LG }) {
          PageHeader({
            title: this.initialTitle.length > 0 ? this.initialTitle : '幸运转盘',
            subtitle: this.running ? '转动中，请稍候' : '结果在动画开始前已经公平确定',
            colors: this.colors,
            onBack: (): void => {
              if (!this.running) {
                this.onBack();
              }
            }
          })

          WheelCanvas({
            options: this.editor.texts().map((value: string): string => {
              return value.trim().length > 0 ? value.trim() : '待填写';
            }),
            rotation: this.rotation,
            colors: this.colors
          })

          AppButton({
            label: this.running ? '转动中…' : '开始转动',
            isEnabled: !this.running,
            onPress: (): void => this.spin()
          })

          Text('选项')
            .width('100%')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)

          OptionsEditor({
            options: this.options,
            isEnabled: !this.running,
            colors: this.colors,
            onUpdate: (id: string, text: string): void => this.updateOption(id, text),
            onRemove: (id: string): void => this.removeOption(id),
            onMove: (from: number, to: number): void => this.moveOption(from, to),
            onAdd: (): void => this.addOption()
          })

          if (this.error.length > 0) {
            Text(this.error)
              .width('100%')
              .fontSize(AppFontSizes.CAPTION)
              .fontColor(this.colors.error)
          }

          AppButton({
            label: '保存为模板',
            variant: AppButtonVariant.SECONDARY,
            isEnabled: !this.running,
            onPress: (): void => this.openTemplateDialog()
          })
          if (this.result.length > 0) {
            AppButton({
              label: this.saved ? '结果已保存' : '保存结果',
              variant: AppButtonVariant.SECONDARY,
              isEnabled: !this.saved,
              onPress: (): void => {
                this.save();
              }
            })
          }
        }
        .width('100%')
        .constraintSize({ maxWidth: 720 })
        .padding({ left: 20, right: 20, top: 20, bottom: 36 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.colors.background)

      ResultSheet({
        visible: this.result.length > 0,
        result: this.result,
        colors: this.colors,
        onClose: (): void => {
          this.result = '';
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
