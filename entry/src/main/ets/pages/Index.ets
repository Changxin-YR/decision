import { AppCard } from '../components/common/AppCard';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import {
  AppFontSizes,
  AppRadii,
  AppSpacing,
  ThemeResolver,
  ThemeTokens
} from '../constants/DesignTokens';
import { PRESET_TEMPLATES } from '../constants/PresetTemplates';
import { AppStrings } from '../constants/AppStrings';
import {
  DecisionTemplate,
  HistoryRecord,
  ToolType
} from '../models/AppModels';
import {
  AppRoute,
  HomeToolItem,
  ResponsiveLayout
} from '../models/NavigationModels';
import { appStore, AppStore } from '../stores/AppStore';
import { decisionDraftStore } from '../stores/DecisionDraftStore';
import { PrivacyContent } from './Privacy';
import { CoinPage } from './Coin';
import { DrawPage } from './Draw';
import { FingerSelectPage } from './FingerSelect';
import { HistoryPage } from './History';
import { RandomNumberPage } from './RandomNumber';
import { SettingsPage } from './Settings';
import { YesNoPage } from './YesNo';
import { WheelPage } from './Wheel';

const HOME_TOOLS: HomeToolItem[] = [
  {
    route: AppRoute.WHEEL,
    toolType: ToolType.WHEEL,
    title: AppStrings.WHEEL,
    description: '转动转盘做选择',
    symbol: '转',
    tint: '#E97878'
  },
  {
    route: AppRoute.DRAW,
    toolType: ToolType.DRAW,
    title: AppStrings.DRAW,
    description: '写下选项随机抽取',
    symbol: '签',
    tint: '#E2BD55'
  },
  {
    route: AppRoute.FINGER_SELECT,
    toolType: ToolType.FINGER,
    title: AppStrings.FINGER_SELECT,
    description: '大家一起按住屏幕',
    symbol: '指',
    tint: '#70B983'
  },
  {
    route: AppRoute.COIN,
    toolType: ToolType.COIN,
    title: AppStrings.COIN,
    description: '正面还是反面',
    symbol: '币',
    tint: '#6897D2'
  },
  {
    route: AppRoute.YES_NO,
    toolType: ToolType.YES_NO,
    title: AppStrings.YES_NO,
    description: '只需要一个明确答案',
    symbol: '？',
    tint: '#B783C5'
  },
  {
    route: AppRoute.RANDOM_NUMBER,
    toolType: ToolType.NUMBER,
    title: AppStrings.RANDOM_NUMBER,
    description: '从范围中公平取数',
    symbol: '#',
    tint: '#58B7B0'
  }
];

@Entry
@Component
struct Index {
  @State private pathStack: NavPathStack = new NavPathStack();
  @State private store: AppStore = appStore;
  @State private contentWidth: number = 360;
  @State private systemDark: boolean = false;

  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  private theme(): ThemeTokens {
    return ThemeResolver.resolve(this.store.settings.themeMode, this.systemDark);
  }

  private columnCount(): number {
    return ResponsiveLayout.columnsForWidth(this.contentWidth);
  }

  private toolIcon(route: AppRoute): Resource {
    if (route === AppRoute.WHEEL) return $r('app.media.ui_home_wheel');
    if (route === AppRoute.DRAW) return $r('app.media.ui_home_draw');
    if (route === AppRoute.FINGER_SELECT) return $r('app.media.ui_home_finger');
    if (route === AppRoute.COIN) return $r('app.media.ui_home_coin');
    if (route === AppRoute.YES_NO) return $r('app.media.ui_home_yesno');
    return $r('app.media.ui_home_number');
  }

  private templateIcon(template: DecisionTemplate): Resource {
    if (template.id === 'preset_eat') return $r('app.media.ui_quick_food');
    if (template.id === 'preset_takeout') return $r('app.media.ui_quick_takeout');
    if (template.id === 'preset_weekend') return $r('app.media.ui_quick_weekend');
    if (template.id === 'preset_first') return $r('app.media.ui_quick_first');
    return template.toolType === ToolType.WHEEL ?
      $r('app.media.ui_home_wheel') : $r('app.media.ui_home_draw');
  }

  private openTool(tool: HomeToolItem, title: string = ''): void {
    decisionDraftStore.set(title, tool.toolType, []);
    this.pathStack.pushPathByName(tool.route, undefined);
  }

  private openTemplate(template: DecisionTemplate): void {
    decisionDraftStore.set(template.name, template.toolType, template.options);
    const route: AppRoute = template.toolType === ToolType.WHEEL ?
      AppRoute.WHEEL : AppRoute.DRAW;
    this.pathStack.pushPathByName(route, undefined);
  }

  @Builder
  private toolCard(tool: HomeToolItem) {
    AppCard({ colors: this.theme(), contentPadding: 10 }) {
      Row({ space: 6 }) {
        Image(this.toolIcon(tool.route))
          .width(62)
          .height(78)
          .objectFit(ImageFit.Contain)
        Column({ space: 6 }) {
          Text(tool.title)
            .width('100%')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.theme().text)
            .maxLines(1)
          Text(tool.description)
            .width('100%')
            .fontSize(9)
            .fontColor(this.theme().subtext)
            .maxLines(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height(80)
      .alignItems(VerticalAlign.Center)
      .onClick((): void => this.openTool(tool))
    }
  }

  @Builder
  private headerAction(icon: Resource, label: string, action: () => void) {
    Column({ space: 2 }) {
      Image(icon)
        .width(28)
        .height(28)
        .objectFit(ImageFit.Contain)
      Text(label)
        .fontSize(11)
        .fontColor(this.theme().text)
    }
    .width(48)
    .height(70)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.theme().card)
    .borderRadius(10)
    .shadow({ radius: 10, color: '#0D27496B', offsetX: 0, offsetY: 3 })
    .onClick(action)
  }

  @Builder
  private home() {
    Scroll() {
      Column({ space: AppSpacing.SECTION }) {
        Row() {
          Column({ space: 4 }) {
            Text('做个决定')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.theme().text)
            Text('把选择交给直觉')
              .fontSize(AppFontSizes.BODY)
              .fontColor(this.theme().subtext)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Row({ space: 8 }) {
            this.headerAction(
              $r('app.media.ui_home_history'),
              '历史',
              (): void => {
              this.pathStack.pushPathByName(AppRoute.HISTORY, undefined);
              }
            )
            this.headerAction(
              $r('app.media.ui_home_settings'),
              '设置',
              (): void => {
              this.pathStack.pushPathByName(AppRoute.SETTINGS, undefined);
              }
            )
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Grid() {
          ForEach(HOME_TOOLS, (tool: HomeToolItem): void => {
            GridItem() {
              this.toolCard(tool)
            }
          }, (tool: HomeToolItem): string => tool.route)
        }
        .columnsTemplate(`repeat(${this.columnCount()}, 1fr)`)
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')

        Column({ space: 12 }) {
          Row() {
            Text('快速模板')
              .fontSize(AppFontSizes.HEADING)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.theme().text)
            Blank()
            Text(`${PRESET_TEMPLATES.length + this.store.templates.length} 个`)
              .fontSize(AppFontSizes.CAPTION)
              .fontColor(this.theme().subtext)
          }
          .width('100%')

          ForEach(
            PRESET_TEMPLATES.concat(this.store.templates),
            (template: DecisionTemplate): void => {
              Row({ space: 14 }) {
                Image(this.templateIcon(template))
                  .width(38)
                  .height(38)
                  .objectFit(ImageFit.Contain)
                Column({ space: 3 }) {
                  Text(template.name)
                    .fontSize(AppFontSizes.BODY)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.theme().text)
                  Text(template.builtIn ? '内置模板' : '我的模板')
                    .fontSize(AppFontSizes.CAPTION)
                    .fontColor(this.theme().subtext)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                if (!template.builtIn) {
                  Button('删除', { type: ButtonType.Normal })
                    .fontSize(AppFontSizes.CAPTION)
                    .fontColor(this.theme().error)
                    .backgroundColor('#00000000')
                    .onClick(async (): Promise<void> => {
                      const deleted: boolean =
                        await this.store.deleteCustomTemplate(template.id);
                      this.getUIContext().getPromptAction().showToast({
                        message: deleted ? '模板已删除' : '删除失败，请重试'
                      });
                    })
                }
                Text('›')
                  .fontSize(26)
                  .fontColor(this.theme().subtext)
              }
              .width('100%')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.theme().card)
              .borderRadius(AppRadii.CARD)
              .border({ width: 1, color: this.theme().border })
              .onClick((): void => this.openTemplate(template))
            },
            (template: DecisionTemplate): string => template.id
          )
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Button('隐私说明 · 数据只保存在本机', { type: ButtonType.Normal })
          .fontSize(AppFontSizes.CAPTION)
          .fontColor(this.theme().subtext)
          .backgroundColor('#00000000')
          .onClick((): void => {
            this.pathStack.pushPathByName(AppRoute.PRIVACY, undefined);
          })
      }
      .width('100%')
      .constraintSize({ maxWidth: 1040 })
      .padding({ left: 16, right: 16, top: 14, bottom: 28 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(this.theme().background)
  }

  @Builder
  destination(name: string) {
    NavDestination() {
      if (name === AppRoute.PRIVACY) {
        PrivacyContent({
          colors: this.theme(),
          onBack: (): void => {
            this.pathStack.pop();
          }
        })
      } else if (name === AppRoute.WHEEL) {
        WheelPage({
          colors: this.theme(),
          initialTitle: decisionDraftStore.title,
          initialOptions: decisionDraftStore.options,
          onBack: (): void => {
            this.pathStack.pop();
          }
        })
      } else if (name === AppRoute.DRAW) {
        DrawPage({
          colors: this.theme(),
          initialTitle: decisionDraftStore.title,
          initialOptions: decisionDraftStore.options,
          onBack: (): void => {
            this.pathStack.pop();
          }
        })
      } else if (name === AppRoute.FINGER_SELECT) {
        FingerSelectPage({
          colors: this.theme(),
          onBack: (): void => {
            this.pathStack.pop();
          }
        })
      } else if (name === AppRoute.HISTORY) {
        HistoryPage({
          colors: this.theme(),
          onBack: (): void => {
            this.pathStack.pop();
          },
          onUseAgain: (record: HistoryRecord): void => {
            decisionDraftStore.set(record.title, record.toolType, record.options);
            if (record.toolType === ToolType.WHEEL) {
              this.pathStack.pushPathByName(AppRoute.WHEEL, undefined);
            } else if (record.toolType === ToolType.DRAW) {
              this.pathStack.pushPathByName(AppRoute.DRAW, undefined);
            } else if (record.toolType === ToolType.COIN) {
              this.pathStack.pushPathByName(AppRoute.COIN, undefined);
            } else if (record.toolType === ToolType.YES_NO) {
              this.pathStack.pushPathByName(AppRoute.YES_NO, undefined);
            } else if (record.toolType === ToolType.NUMBER) {
              this.pathStack.pushPathByName(AppRoute.RANDOM_NUMBER, undefined);
            } else {
              this.pathStack.pushPathByName(AppRoute.FINGER_SELECT, undefined);
            }
          }
        })
      } else if (name === AppRoute.SETTINGS) {
        SettingsPage({
          colors: this.theme(),
          onBack: (): void => {
            this.pathStack.pop();
          },
          onPrivacy: (): void => {
            this.pathStack.pushPathByName(AppRoute.PRIVACY, undefined);
          }
        })
      } else if (name === AppRoute.YES_NO) {
        YesNoPage({
          colors: this.theme(),
          onBack: (): void => {
            this.pathStack.pop();
          }
        })
      } else if (name === AppRoute.COIN) {
        CoinPage({
          colors: this.theme(),
          onBack: (): void => {
            this.pathStack.pop();
          }
        })
      } else if (name === AppRoute.RANDOM_NUMBER) {
        RandomNumberPage({
          colors: this.theme(),
          onBack: (): void => {
            this.pathStack.pop();
          }
        })
      } else {
        Column({ space: 18 }) {
          Text('‹')
            .fontSize(34)
            .fontColor(this.theme().text)
            .onClick((): void => {
              this.pathStack.pop();
            })
          Text(name)
            .fontSize(AppFontSizes.TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.theme().text)
          Text('功能页面正在接入，当前阶段已完成原生导航。')
            .fontSize(AppFontSizes.BODY)
            .fontColor(this.theme().subtext)
        }
        .width('100%')
        .height('100%')
        .padding(20)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.theme().background)
      }
    }
    .hideTitleBar(true)
  }

  build() {
    Navigation(this.pathStack) {
      this.home()
    }
    .hideTitleBar(true)
    .navDestination(this.destination)
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.contentWidth = Number(newValue.width);
    })
  }
}
