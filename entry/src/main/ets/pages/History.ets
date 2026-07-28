import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { ConfirmDialog } from '../components/common/ConfirmDialog';
import { PageHeader } from '../components/common/PageHeader';
import {
  AppFontSizes,
  AppRadii,
  AppSpacing,
  ThemeTokens
} from '../constants/DesignTokens';
import {
  HistoryRecord,
  ToolType
} from '../models/AppModels';
import { appStore, AppStore } from '../stores/AppStore';
import { TimeFormatter } from '../utils/TimeFormatter';

@Component
export struct HistoryPage {
  @Prop colors: ThemeTokens;
  onBack: () => void = (): void => {
  };
  onUseAgain: (record: HistoryRecord) => void = (_record: HistoryRecord): void => {
  };
  @State private store: AppStore = appStore;
  @State private selected: HistoryRecord | null = null;
  private clearDialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '清空历史记录',
      message: '此操作会删除全部历史记录，且无法撤销。自定义模板不会受到影响。',
      confirmLabel: '全部清空',
      colors: this.colors,
      onConfirm: (): void => {
        this.clearAll();
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  private toolName(type: ToolType): string {
    if (type === ToolType.WHEEL) return '幸运转盘';
    if (type === ToolType.DRAW) return '抽签';
    if (type === ToolType.FINGER) return '指尖选择';
    if (type === ToolType.COIN) return '抛硬币';
    if (type === ToolType.YES_NO) return '是或否';
    return '随机数字';
  }

  private async remove(record: HistoryRecord): Promise<void> {
    const deleted: boolean = await this.store.deleteHistoryRecord(record.id);
    try {
      this.getUIContext().getPromptAction().showToast({
        message: deleted ? '记录已删除' : '删除失败，请重试'
      });
    } catch (_error) {
    }
  }

  private async clearAll(): Promise<void> {
    const cleared: boolean = await this.store.clearHistory();
    this.selected = null;
    try {
      this.getUIContext().getPromptAction().showToast({
        message: cleared ? '历史记录已清空' : '清空失败，请重试'
      });
    } catch (_error) {
    }
  }

  build() {
    Stack() {
      Column({ space: AppSpacing.MD }) {
        PageHeader({
          title: '历史记录',
          subtitle: `已保存 ${this.store.history.length} 条`,
          colors: this.colors,
          onBack: (): void => this.onBack()
        })

        if (this.store.history.length === 0) {
          Column({ space: AppSpacing.SM }) {
            Text('还没有保存过决定')
              .fontSize(AppFontSizes.HEADING)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.colors.text)
            Text('完成决定后点击“保存结果”，记录会出现在这里。')
              .fontSize(AppFontSizes.BODY)
              .fontColor(this.colors.subtext)
              .textAlign(TextAlign.Center)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 10 }) {
            ForEach(this.store.history, (record: HistoryRecord): void => {
              ListItem() {
                Column({ space: 8 }) {
                  Row() {
                    Text(this.toolName(record.toolType))
                      .fontSize(AppFontSizes.CAPTION)
                      .fontColor(this.colors.accent)
                    Blank()
                    Text(TimeFormatter.format(record.createdAt))
                      .fontSize(AppFontSizes.CAPTION)
                      .fontColor(this.colors.subtext)
                  }
                  .width('100%')
                  Text(record.title)
                    .width('100%')
                    .fontSize(AppFontSizes.BODY)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.colors.text)
                  Text(record.result)
                    .width('100%')
                    .fontSize(AppFontSizes.HEADING)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.colors.text)
                }
                .width('100%')
                .padding(16)
                .backgroundColor(this.colors.card)
                .borderRadius(AppRadii.CARD)
                .border({ width: 1, color: this.colors.border })
                .onClick((): void => {
                  this.selected = record;
                })
                .gesture(
                  LongPressGesture({ duration: 600 })
                    .onAction((): void => {
                      this.remove(record);
                    })
                )
              }
            }, (record: HistoryRecord): string => record.id)
          }
          .layoutWeight(1)
          .width('100%')

          AppButton({
            label: '清空全部历史',
            variant: AppButtonVariant.DANGER,
            onPress: (): void => this.clearDialog.open()
          })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 24 })
      .backgroundColor(this.colors.background)

      if (this.selected !== null) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#66000000')
            .onClick((): void => {
              this.selected = null;
            })
          Column({ space: 14 }) {
            Text(this.selected.title)
              .width('100%')
              .fontSize(AppFontSizes.HEADING)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.colors.text)
            Text(`${this.toolName(this.selected.toolType)} · ${TimeFormatter.format(this.selected.createdAt)}`)
              .width('100%')
              .fontSize(AppFontSizes.CAPTION)
              .fontColor(this.colors.subtext)
            Text(this.selected.options.length > 0 ?
              this.selected.options.join('、') : '无输入选项')
              .width('100%')
              .fontSize(AppFontSizes.BODY)
              .fontColor(this.colors.subtext)
            Text(this.selected.result)
              .width('100%')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.colors.text)
              .textAlign(TextAlign.Center)
            AppButton({
              label: '再次使用',
              onPress: (): void => {
                if (this.selected !== null) {
                  this.onUseAgain(this.selected);
                }
              }
            })
            AppButton({
              label: '关闭',
              variant: AppButtonVariant.SECONDARY,
              onPress: (): void => {
                this.selected = null;
              }
            })
          }
          .width('calc(100% - 40vp)')
          .constraintSize({ maxWidth: 560 })
          .padding(22)
          .backgroundColor(this.colors.card)
          .borderRadius(AppRadii.DIALOG)
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
