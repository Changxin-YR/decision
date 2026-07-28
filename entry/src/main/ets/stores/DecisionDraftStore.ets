import {
  DecisionOption,
  ToolType
} from '../models/AppModels';
import { DrawSession } from '../domain/state/DrawSession';
import { OptionEditorState } from '../domain/state/OptionEditorState';

export class DecisionDraftStore {
  title: string = '';
  toolType: ToolType = ToolType.WHEEL;
  options: string[] = [];
  private editor: OptionEditorState = new OptionEditorState();
  private drawSession: DrawSession | null = null;
  private drawSignature: string = '';

  set(title: string, toolType: ToolType, options: readonly string[]): void {
    this.title = title;
    this.toolType = toolType;
    this.editor = new OptionEditorState(options);
    this.options = this.editor.texts();
    this.drawSession = null;
    this.drawSignature = '';
  }

  updateOptions(options: readonly string[]): void {
    const changed: boolean = this.options.join('\u0001') !== options.join('\u0001');
    if (!changed) {
      return;
    }
    this.editor = new OptionEditorState(options);
    this.options = this.editor.texts();
    this.drawSession = null;
    this.drawSignature = '';
  }

  decisionOptions(): DecisionOption[] {
    return Array.from(this.editor.options);
  }

  updateOption(id: string, text: string): boolean {
    const changed: boolean = this.editor.update(id, text);
    if (changed) {
      this.options = this.editor.texts();
      this.drawSession = null;
      this.drawSignature = '';
    }
    return changed;
  }

  removeOption(id: string): boolean {
    const changed: boolean = this.editor.remove(id);
    if (changed) {
      this.options = this.editor.texts();
      this.drawSession = null;
      this.drawSignature = '';
    }
    return changed;
  }

  moveOption(from: number, to: number): boolean {
    const changed: boolean = this.editor.move(from, to);
    if (changed) {
      this.options = this.editor.texts();
      this.drawSession = null;
      this.drawSignature = '';
    }
    return changed;
  }

  addOption(): boolean {
    const changed: boolean = this.editor.add();
    if (changed) {
      this.options = this.editor.texts();
      this.drawSession = null;
      this.drawSignature = '';
    }
    return changed;
  }

  getDrawSession(options: readonly string[], allowRepeat: boolean): DrawSession {
    const signature: string = `${allowRepeat}:${options.join('\u0001')}`;
    if (this.drawSession === null || this.drawSignature !== signature) {
      this.drawSession = new DrawSession(options, allowRepeat);
      this.drawSignature = signature;
    }
    return this.drawSession;
  }

  currentDrawSession(): DrawSession | null {
    return this.drawSession;
  }
}

export const decisionDraftStore: DecisionDraftStore = new DecisionDraftStore();
