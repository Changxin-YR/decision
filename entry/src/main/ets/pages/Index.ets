@Entry
@Component
struct Index {
  build() {
    Column({ space: 12 }) {
      Text('做个决定')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      Text('原生鸿蒙离线决策工具')
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
