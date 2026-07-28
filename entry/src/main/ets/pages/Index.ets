import { AppCard } from '../components/common/AppCard';
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
  ToolType
} from '../models/AppModels';
import {
  AppRoute,
  DecisionPageParams,
  HomeToolItem,
  ResponsiveLayout
} from '../models/NavigationModels';
import { appStore, AppStore } from '../stores/AppStore';
import { PrivacyContent } from './Privacy';
import { CoinPage } from './Coin';
import { RandomNumberPage } from './RandomNumber';
import { YesNoPage } from './YesNo';

const HOME_TOOLS: HomeToolItem[] = [
  {
    route: AppRoute.WHEEL,
    toolType: ToolType.WHEEL,
    title: AppStrings.WHEEL,
    description: '把纠结交给公平转盘',
    symbol: '转',
    tint: '#E97878'
  },
  {
    route: AppRoute.DRAW,
    toolType: ToolType.DRAW,
    title: AppStrings.DRAW,
    description: '抽一个名字或选项',
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

  private theme(): ThemeTokens {
    return ThemeResolver.resolve(this.store.settings.themeMode, this.systemDark);
  }

  private columnCount(): number {
    return ResponsiveLayout.columnsForWidth(this.contentWidth);
  }

  private openTool(tool: HomeToolItem, title: string = ''): void {
    const params: DecisionPageParams = {
      title: title,
      toolType: tool.toolType,
      options: []
    };
    this.pathStack.pushPath({
      name: tool.route,
      param: params
    });
  }

  private openTemplate(template: DecisionTemplate): void {
    const params: DecisionPageParams = {
      title: template.name,
      toolType: template.toolType,
      options: Array.from(template.options)
    };
    const route: AppRoute = template.toolType === ToolType.WHEEL ?
      AppRoute.WHEEL : AppRoute.DRAW;
    this.pathStack.pushPath({
      name: route,
      param: params
    });
  }

  @Builder
  private toolCard(tool: HomeToolItem) {
    AppCard({ colors: this.theme(), contentPadding: 14 }) {
      Column({ space: 12 }) {
        Text(tool.symbol)
          .width(44)
          .height(44)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .backgroundColor(tool.tint)
          .borderRadius(22)
        Text(tool.title)
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.theme().text)
          .maxLines(1)
        Text(tool.description)
          .width('100%')
          .fontSize(AppFontSizes.CAPTION)
          .fontColor(this.theme().subtext)
          .maxLines(2)
      }
      .width('100%')
      .height(132)
      .alignItems(HorizontalAlign.Start)
      .onClick((): void => this.openTool(tool))
    }
  }

  @Builder
  private home() {
    Scroll() {
      Column({ space: AppSpacing.LG }) {
        Row() {
          Column({ space: 4 }) {
            Text('做个决定')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.theme().text)
            Text('不联网，不纠结，马上开始')
              .fontSize(AppFontSizes.BODY)
              .fontColor(this.theme().subtext)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Button('历史', { type: ButtonType.Normal })
            .fontColor(this.theme().text)
            .backgroundColor(this.theme().card)
            .borderRadius(AppRadii.CARD)
            .onClick((): void => {
              this.pathStack.pushPathByName(AppRoute.HISTORY, undefined);
            })
          Button('设置', { type: ButtonType.Normal })
            .fontColor(this.theme().text)
            .backgroundColor(this.theme().card)
            .borderRadius(AppRadii.CARD)
            .onClick((): void => {
              this.pathStack.pushPathByName(AppRoute.SETTINGS, undefined);
            })
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
                Text(template.toolType === ToolType.WHEEL ? '转' : '签')
                  .width(38)
                  .height(38)
                  .textAlign(TextAlign.Center)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.theme().accent)
                  .borderRadius(19)
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
              .padding(14)
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
      .padding({ left: 18, right: 18, top: 20, bottom: 32 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme().background)
  }

  @Builder
  private destination(name: string, _param: object) {
    if (name === AppRoute.PRIVACY) {
      PrivacyContent({
        colors: this.theme(),
        onBack: (): void => {
          this.pathStack.pop();
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
