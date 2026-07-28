import { AppLimits } from '../../constants/DesignTokens';
import { DecisionOption } from '../../models/AppModels';
import {
  OptionValidator,
  ValidationResult
} from '../validation/OptionValidator';

export class OptionEditorState {
  options: DecisionOption[] = [];
  private nextId: number = 1;

  constructor(initial: readonly string[] = []) {
    const source: string[] = initial.length >= AppLimits.MIN_OPTIONS ?
      Array.from(initial).slice(0, AppLimits.MAX_OPTIONS) : ['', ''];
    this.options = source.map((text: string): DecisionOption => {
      return this.createOption(text);
    });
  }

  add(): boolean {
    if (this.options.length >= AppLimits.MAX_OPTIONS) {
      return false;
    }
    this.options = this.options.concat([this.createOption('')]);
    return true;
  }

  update(id: string, text: string): boolean {
    const index: number =
      this.options.findIndex((option: DecisionOption): boolean => option.id === id);
    if (index < 0) {
      return false;
    }
    this.options = this.options.map((option: DecisionOption): DecisionOption => {
      if (option.id !== id) {
        return option;
      }
      return {
        id: option.id,
        text: text
      };
    });
    return true;
  }

  remove(id: string): boolean {
    if (this.options.length <= AppLimits.MIN_OPTIONS) {
      return false;
    }
    const next: DecisionOption[] =
      this.options.filter((option: DecisionOption): boolean => option.id !== id);
    if (next.length === this.options.length) {
      return false;
    }
    this.options = next;
    return true;
  }

  move(from: number, to: number): boolean {
    if (from < 0 || from >= this.options.length ||
      to < 0 || to >= this.options.length || from === to) {
      return false;
    }
    const next: DecisionOption[] = Array.from(this.options);
    const moved: DecisionOption = next[from];
    next.splice(from, 1);
    next.splice(to, 0, moved);
    this.options = next;
    return true;
  }

  texts(): string[] {
    return this.options.map((option: DecisionOption): string => option.text);
  }

  validate(): ValidationResult {
    return OptionValidator.validate(this.texts());
  }

  private createOption(text: string): DecisionOption {
    const option: DecisionOption = {
      id: `option-${this.nextId}`,
      text: text
    };
    this.nextId++;
    return option;
  }
}
