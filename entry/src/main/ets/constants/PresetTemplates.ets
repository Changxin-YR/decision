import { DecisionTemplate, ToolType } from '../models/AppModels';

export const PRESET_TEMPLATES: DecisionTemplate[] = [
  {
    id: 'preset_eat',
    name: '今天吃什么',
    toolType: ToolType.WHEEL,
    options: ['米饭', '面条', '火锅', '烧烤', '汉堡', '炒菜'],
    createdAt: '2026-07-28T00:00:00.000Z',
    builtIn: true
  },
  {
    id: 'preset_takeout',
    name: '谁去拿外卖',
    toolType: ToolType.DRAW,
    options: ['张三', '李四', '王五'],
    createdAt: '2026-07-28T00:00:00.000Z',
    builtIn: true
  },
  {
    id: 'preset_weekend',
    name: '周末去哪里',
    toolType: ToolType.WHEEL,
    options: ['公园', '商场', '电影院', '在家', '爬山'],
    createdAt: '2026-07-28T00:00:00.000Z',
    builtIn: true
  },
  {
    id: 'preset_first',
    name: '谁先开始',
    toolType: ToolType.DRAW,
    options: ['玩家A', '玩家B'],
    createdAt: '2026-07-28T00:00:00.000Z',
    builtIn: true
  }
];
