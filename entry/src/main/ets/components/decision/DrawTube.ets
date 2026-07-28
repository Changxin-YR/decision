import { ThemeTokens } from '../../constants/DesignTokens';

@Component
export struct DrawTube {
  @Prop colors: ThemeTokens;
  @Prop shakeAngle: number = 0;
  @Prop stickOffset: number = 0;
  @Prop liftedLabel: string = '';
  private sticks: number[] = [0, 1, 2, 3, 4, 5, 6];

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row({ space: 9 }) {
        ForEach(this.sticks, (index: number): void => {
          Rect({ width: 12, height: 128 })
            .radius(6)
            .fill(index % 2 === 0 ? '#E2BD55' : '#E49661')
            .rotate({ angle: index * 4 - 12 })
        }, (index: number): string => `${index}`)
      }
      .translate({ y: -54 })

      if (this.liftedLabel.length > 0) {
        Column({ space: 6 }) {
          Rect({ width: 16, height: 112 })
            .radius(8)
            .fill('#4A90D9')
          Text(this.liftedLabel)
            .constraintSize({ maxWidth: 180 })
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .translate({ y: this.stickOffset - 76 })
      }

      Column() {
        Text('签')
          .fontSize(52)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(220)
      .height(190)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#B78355')
      .borderRadius({ topLeft: 28, topRight: 28, bottomLeft: 58, bottomRight: 58 })
      .border({ width: 4, color: '#8B5E3C' })
    }
    .width('100%')
    .height(330)
    .rotate({ angle: this.shakeAngle })
  }
}
