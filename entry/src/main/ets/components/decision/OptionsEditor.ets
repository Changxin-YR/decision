import {
  AppFontSizes,
  AppLimits,
  AppRadii,
  ThemeTokens
} from '../../constants/DesignTokens';
import { DecisionOption } from '../../models/AppModels';

@Component
export struct OptionsEditor {
  @Prop options: DecisionOption[] = [];
  @Prop isEnabled: boolean = true;
  @Prop colors: ThemeTokens;
  onUpdate: (id: string, text: string) => void =
    (_id: string, _text: string): void => {
    };
  onRemove: (id: string) => void = (_id: string): void => {
  };
  onMove: (from: number, to: number) => void =
    (_from: number, _to: number): void => {
    };
  onAdd: () => void = (): void => {
  };

  build() {
    Column({ space: 10 }) {
      List({ space: 8 }) {
        ForEach(
          this.options,
          (option: DecisionOption, index: number): void => {
            ListItem() {
              Row({ space: 8 }) {
                Text('☰')
                  .width(28)
                  .fontSize(20)
                  .fontColor(this.colors.subtext)
                  .textAlign(TextAlign.Center)
                  .gesture(
                    GestureGroup(
                      GestureMode.Sequence,
                      LongPressGesture({ repeat: false, duration: 450 }),
                      PanGesture({ direction: PanDirection.Vertical })
                        .onActionEnd((event: GestureEvent): void => {
                          const delta: number = Math.round(event.offsetY / 60);
                          const target: number = Math.max(
                            0,
                            Math.min(this.options.length - 1, index + delta)
                          );
                          if (this.isEnabled && target !== index) {
                            this.onMove(index, target);
                          }
                        })
                    )
                  )
                TextInput({
                  text: option.text,
                  placeholder: `选项 ${index + 1}`
                })
                  .layoutWeight(1)
                  .height(44)
                  .fontSize(AppFontSizes.BODY)
                  .fontColor(this.colors.text)
                  .placeholderColor(this.colors.subtext)
                  .backgroundColor(this.colors.card)
                  .borderRadius(AppRadii.INPUT)
                  .border({ width: 1, color: this.colors.border })
                  .maxLength(AppLimits.MAX_OPTION_LENGTH)
                  .enabled(this.isEnabled)
                  .onChange((text: string): void => {
                    this.onUpdate(option.id, text);
                  })
                Button('删除', { type: ButtonType.Normal })
                  .height(40)
                  .fontSize(AppFontSizes.CAPTION)
                  .fontColor(this.colors.error)
                  .backgroundColor('#00000000')
                  .enabled(this.isEnabled && this.options.length > AppLimits.MIN_OPTIONS)
                  .opacity(
                    this.isEnabled && this.options.length > AppLimits.MIN_OPTIONS ? 1 : 0.35
                  )
                  .onClick((): void => {
                    this.onRemove(option.id);
                  })
              }
              .width('100%')
              .padding({ left: 6, right: 4, top: 4, bottom: 4 })
              .backgroundColor(this.colors.card)
              .borderRadius(AppRadii.CARD)
              .border({ width: 1, color: this.colors.border })
            }
          },
          (option: DecisionOption): string => option.id
        )
      }
      .width('100%')
      .height(this.options.length * 60)
      .scrollBar(BarState.Off)

      Button(`＋ 添加选项（${this.options.length}/${AppLimits.MAX_OPTIONS}）`, {
        type: ButtonType.Normal
      })
        .width('100%')
        .height(44)
        .fontSize(AppFontSizes.BODY)
        .fontColor(this.colors.accent)
        .backgroundColor(this.colors.card)
        .borderRadius(AppRadii.CARD)
        .border({ width: 1, color: this.colors.border })
        .enabled(this.isEnabled && this.options.length < AppLimits.MAX_OPTIONS)
        .opacity(
          this.isEnabled && this.options.length < AppLimits.MAX_OPTIONS ? 1 : 0.45
        )
        .onClick((): void => {
          this.onAdd();
        })
    }
    .width('100%')
  }
}
