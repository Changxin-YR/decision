export type LifecycleListener = (inBackground: boolean) => void;

export class AppLifecycleBus {
  private listeners: Set<LifecycleListener> = new Set<LifecycleListener>();

  subscribe(listener: LifecycleListener): () => void {
    this.listeners.add(listener);
    return (): void => {
      this.listeners.delete(listener);
    };
  }

  notify(inBackground: boolean): void {
    this.listeners.forEach((listener: LifecycleListener): void => {
      listener(inBackground);
    });
  }
}

export const appLifecycleBus: AppLifecycleBus = new AppLifecycleBus();
