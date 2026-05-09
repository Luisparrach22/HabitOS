/**
 * HabitOS — Catálogo centralizado de iconos
 * Usa exclusivamente @expo/vector-icons (FontAwesome5 + Feather)
 * Organizado por categorías para el selector de iconos
 */

export interface IconCategory {
  label: string;
  icons: string[];
}

// ─── Categorías de Iconos ─────────────────────────────────────

export const ICON_CATEGORIES: IconCategory[] = [
  {
    label: '💪 Fitness',
    icons: [
      'running', 'dumbbell', 'bicycle', 'swimmer', 'walking',
      'skiing', 'skating', 'basketball-ball', 'football-ball', 'volleyball-ball',
    ],
  },
  {
    label: '🧘 Mindfulness',
    icons: [
      'brain', 'spa', 'praying-hands', 'peace', 'yin-yang',
      'moon', 'sun', 'cloud-sun', 'leaf', 'seedling',
    ],
  },
  {
    label: '🍎 Health',
    icons: [
      'heartbeat', 'tint', 'apple-alt', 'carrot', 'lemon',
      'weight', 'bed', 'lungs', 'tooth', 'pills',
    ],
  },
  {
    label: '📚 Learning',
    icons: [
      'book-open', 'book-reader', 'graduation-cap', 'pen-fancy', 'pencil-alt',
      'laptop-code', 'language', 'chess', 'puzzle-piece', 'lightbulb',
    ],
  },
  {
    label: '🎨 Creative',
    icons: [
      'palette', 'paint-brush', 'music', 'guitar', 'camera',
      'film', 'microphone', 'headphones', 'drafting-compass', 'cut',
    ],
  },
  {
    label: '🏠 Daily Life',
    icons: [
      'home', 'broom', 'utensils', 'coffee', 'shower',
      'dog', 'cat', 'tree', 'wallet', 'piggy-bank',
    ],
  },
  {
    label: '🚀 Productivity',
    icons: [
      'tasks', 'calendar-check', 'clock', 'laptop', 'envelope',
      'briefcase', 'chart-line', 'bullseye', 'flag-checkered', 'rocket',
    ],
  },
  {
    label: '🤝 Social',
    icons: [
      'users', 'comments', 'phone', 'hands-helping', 'hand-holding-heart',
      'smile', 'laugh', 'heart', 'star', 'gift',
    ],
  },
];

// Lista plana de todos los iconos (sin duplicados)
export const ALL_ICONS = Array.from(
  new Set(ICON_CATEGORIES.flatMap((cat) => cat.icons))
);

// Iconos por defecto para mostrar en la fila rápida
export const DEFAULT_QUICK_ICONS = [
  'heartbeat', 'book-open', 'moon', 'dumbbell', 'brain',
];

// ─── Colores para hábitos ─────────────────────────────────────

export interface HabitColor {
  value: string;
  label: string;
}

export const HABIT_COLORS: HabitColor[] = [
  { value: '#018ABE', label: 'Ocean' },
  { value: '#2DD4A8', label: 'Mint' },
  { value: '#F5A623', label: 'Amber' },
  { value: '#EF4444', label: 'Coral' },
  { value: '#8B5CF6', label: 'Violet' },
  { value: '#EC4899', label: 'Rose' },
  { value: '#06B6D4', label: 'Cyan' },
  { value: '#10B981', label: 'Emerald' },
  { value: '#F97316', label: 'Orange' },
  { value: '#6366F1', label: 'Indigo' },
];

// ─── Frecuencias ──────────────────────────────────────────────

export interface FrequencyOption {
  value: string;
  label: string;
  icon: string;    // Feather icon name
  description: string;
}

export const FREQUENCY_OPTIONS: FrequencyOption[] = [
  { value: 'DAILY',  label: 'Daily',   icon: 'sun',      description: 'Every day' },
  { value: 'WEEKLY', label: 'Weekly',  icon: 'calendar',  description: 'Once a week' },
  { value: 'CUSTOM', label: 'Custom',  icon: 'sliders',   description: 'Set your own' },
];
