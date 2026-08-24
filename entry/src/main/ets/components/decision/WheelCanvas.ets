import {
  ThemeTokens,
  WHEEL_COLORS
} from '../../constants/DesignTokens';
import { WheelLabelLayout } from '../../domain/wheel/WheelLabelLayout';

@Component
export struct WheelCanvas {
  @Watch('redraw') @Prop options: string[] = [];
  @Watch('redraw') @Prop refreshVersion: number = 0;
  @Prop rotation: number = 0;
  @Prop colors: ThemeTokens;
  @State private diameter: number = 280;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(this.settings);
  private readonly deepColors: string[] = [
    '#7255C8', '#C3699B', '#D5A248', '#5C927F', '#346BBB', '#A05D6D'
  ];

  private redraw(): void {
    this.draw();
  }

  private draw(): void {
    const size: number = this.diameter;
    const center: number = size / 2;
    const radius: number = center - 8;
    this.context.clearRect(0, 0, size, size);
    if (this.options.length === 0) {
      return;
    }
    const sector: number = Math.PI * 2 / this.options.length;
    for (let index: number = 0; index < this.options.length; index++) {
      const start: number = index * sector - Math.PI / 2;
      const end: number = start + sector;
      this.context.beginPath();
      this.context.moveTo(center, center);
      this.context.arc(center, center, radius, start, end);
      this.context.closePath();
      this.context.fillStyle = this.colors.isDark ?
        this.deepColors[index % this.deepColors.length] :
        WHEEL_COLORS[index % WHEEL_COLORS.length];
      this.context.fill();
      this.context.strokeStyle = '#FFFFFF';
      this.context.lineWidth = 2;
      this.context.stroke();

      this.context.save();
      const labelAngle: number = start + sector / 2;
      const labelX: number = center + Math.cos(labelAngle) * radius * 0.62;
      const labelY: number = center + Math.sin(labelAngle) * radius * 0.62;
      this.context.translate(labelX, labelY);
      this.context.fillStyle = this.colors.isDark ? '#F5F7FB' : '#53647A';
      const crowded: boolean = this.options.length > 8;
      this.context.font =
        `${WheelLabelLayout.fontSize(this.options.length)}px sans-serif`;
      this.context.textAlign = 'center';
      this.context.textBaseline = 'middle';
      const maxChars: number =
        WheelLabelLayout.maxCharacters(this.options.length);
      const label: string = this.options[index].length > maxChars ?
        `${this.options[index].slice(0, maxChars - 1)}…` : this.options[index];
      this.context.fillText(label, 0, 0,
        radius * WheelLabelLayout.maxWidthRatio(this.options.length));
      this.context.restore();
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.context)
        .width(this.diameter)
        .height(this.diameter)
        .rotate({ angle: this.rotation })
        .onReady((): void => {
          this.draw();
        })

      Circle({ width: 58, height: 58 })
        .fill(this.colors.card)
        .stroke(this.colors.border)
        .strokeWidth(2)
        .shadow({ radius: this.colors.isDark ? 16 : 0, color: this.colors.glow,
          offsetX: 0, offsetY: 0 })

      Text('转')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colors.accent)

      Polygon()
        .width(28)
        .height(30)
        .points([[0, 0], [28, 0], [14, 30]])
        .fill(this.colors.accent)
        .position({ x: this.diameter / 2 - 14, y: -2 })
    }
    .width('100%')
    .height(this.diameter + 18)
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      const width: number = Number(newValue.width);
      const next: number = Math.max(220, Math.min(330, width - 20));
      if (Math.abs(next - this.diameter) >= 1) {
        this.diameter = next;
        this.draw();
      }
    })
  }
}
