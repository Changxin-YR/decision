import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { ConfirmDialog } from '../components/common/ConfirmDialog';
import { PageHeader } from '../components/common/PageHeader';
import {
  AppFontSizes,
  AppRadii,
  AppSpacing,
  ThemeTokens
} from '../constants/DesignTokens';
import { AppStrings } from '../constants/AppStrings';
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
  @State private filter: string = '全部';
  @State private pendingDelete: HistoryRecord | null = null;
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
  private deleteDialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '删除记录',
      message: '确定要删除这条历史记录吗？',
      confirmLabel: '删除',
      colors: this.colors,
      onConfirm: (): void => {
        if (this.pendingDelete !== null) {
          this.remove(this.pendingDelete);
          this.pendingDelete = null;
        }
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

  private visibleHistory(): HistoryRecord[] {
    if (this.filter === '全部') {
      return this.store.history;
    }
    let filterType: ToolType = ToolType.WHEEL;
    if (this.filter === '抽签') filterType = ToolType.DRAW;
    if (this.filter === '抛硬币') filterType = ToolType.COIN;
    if (this.filter === '数字') filterType = ToolType.NUMBER;
    if (this.filter === '是或否') filterType = ToolType.YES_NO;
    return this.store.history.filter((record: HistoryRecord): boolean =>
      record.toolType === filterType);
  }

  private historyIcon(type: ToolType): Resource {
    const dark: boolean = this.colors.isDark;
    if (type === ToolType.WHEEL) return dark ?
      $r('app.media.ui_home_wheel_dark') : $r('app.media.ui_home_wheel');
    if (type === ToolType.DRAW) return dark ?
      $r('app.media.ui_home_draw_dark') : $r('app.media.ui_home_draw');
    if (type === ToolType.COIN) return dark ?
      $r('app.media.ui_home_coin_dark') : $r('app.media.ui_home_coin');
    if (type === ToolType.YES_NO) return dark ?
      $r('app.media.ui_home_yesno_dark') : $r('app.media.ui_home_yesno');
    return dark ?
      $r('app.media.ui_home_number_dark') : $r('app.media.ui_home_number');
  }

  private dateLabel(isoTime: string): string {
    const value: Date = new Date(isoTime);
    const now: Date = new Date();
    const today: string = `${now.getFullYear()}-${now.getMonth()}-${now.getDate()}`;
    const recordDay: string =
      `${value.getFullYear()}-${value.getMonth()}-${value.getDate()}`;
    if (recordDay === today) return '今天';
    const yesterday: Date = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    const previousDay: string =
      `${yesterday.getFullYear()}-${yesterday.getMonth()}-${yesterday.getDate()}`;
    if (recordDay === previousDay) return '昨天';
    return `${value.getMonth() + 1}月${value.getDate()}日`;
  }

  private dateGroups(): string[] {
    const groups: string[] = [];
    this.visibleHistory().forEach((record: HistoryRecord): void => {
      const label: string = this.dateLabel(record.createdAt);
      if (groups.indexOf(label) < 0) groups.push(label);
    });
    return groups;
  }

  private recordsForGroup(group: string): HistoryRecord[] {
    return this.visibleHistory().filter((record: HistoryRecord): boolean =>
      this.dateLabel(record.createdAt) === group);
  }

  private timeOnly(isoTime: string): string {
    const value: Date = new Date(isoTime);
    return `${value.getHours()}`.padStart(2, '0') + ':' +
      `${value.getMinutes()}`.padStart(2, '0');
  }

  @Builder
  private historyRow(record: HistoryRecord) {
    Row({ space: 10 }) {
      Image(this.historyIcon(record.toolType))
        .width(46)
        .height(50)
        .objectFit(ImageFit.Contain)
      Column({ space: 2 }) {
        Text(this.toolName(record.toolType))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.colors.text)
        Text(record.title.length > 0 ? record.title :
          (record.options.length > 0 ? record.options.join(' · ') : '完成 1 次'))
          .fontSize(13)
          .fontColor(this.colors.subtext)
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column({ space: 2 }) {
        Text(record.result)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.colors.text)
          .maxLines(1)
        Text(this.timeOnly(record.createdAt))
          .fontSize(13)
          .fontColor(this.colors.subtext)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(70)
    .padding({ left: 10, right: 12 })
    .backgroundColor(this.colors.card)
    .onClick((): void => {
      this.selected = record;
    })
    .gesture(
      LongPressGesture({ duration: 600 })
        .onAction((): void => {
          this.pendingDelete = record;
          this.deleteDialog.open();
        })
    )
  }

  build() {
    Stack() {
      Column({ space: AppSpacing.MD }) {
        PageHeader({
          title: '历史记录',
          rightGlyph: this.store.history.length > 0 ? '⌫' : '',
          colors: this.colors,
          onBack: (): void => this.onBack(),
          onRightPress: (): void => this.clearDialog.open()
        })

        Row({ space: 6 }) {
          ForEach(['全部', '转盘', '抽签', '抛硬币', '数字', '是或否'],
            (label: string): void => {
              Button(label, { type: ButtonType.Normal })
                .width(54)
                .height(34)
                .padding(0)
                .fontSize(11)
                .fontColor(this.filter === label ? '#FFFFFF' : this.colors.text)
                .backgroundColor(this.filter === label ? this.colors.accent : this.colors.card)
                .borderRadius(14)
                .onClick((): void => {
                  this.filter = label;
                })
            })
        }
        .width('100%')

        if (this.store.history.length === 0) {
          Column({ space: AppSpacing.SM }) {
            Text(AppStrings.EMPTY_HISTORY)
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
          List({ space: 12 }) {
            ForEach(this.dateGroups(), (group: string): void => {
              ListItem() {
                Column({ space: 6 }) {
                  Text(group)
                    .width('100%')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.colors.text)
                  Column({ space: 1 }) {
                    ForEach(this.recordsForGroup(group),
                      (record: HistoryRecord): void => {
                        this.historyRow(record)
                      },
                      (record: HistoryRecord): string => record.id)
                  }
                  .width('100%')
                  .borderRadius(AppRadii.CARD)
                  .clip(true)
                  .border({ width: 1, color: this.colors.border })
                }
                .width('100%')
              }
            }, (group: string): string => group)
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }

        AppButton({
          colors: this.colors,
          label: '返回首页',
          variant: AppButtonVariant.SECONDARY,
          onPress: (): void => this.onBack()
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 22 })
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
              colors: this.colors,
              label: '再次使用',
              onPress: (): void => {
                if (this.selected !== null) {
                  const record: HistoryRecord = this.selected;
                  this.selected = null;
                  this.onUseAgain(record);
                }
              }
            })
            AppButton({
              colors: this.colors,
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
    .constraintSize({ maxWidth: 720 })
  }
}
