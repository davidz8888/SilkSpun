// stats-js.d.ts
declare module 'stats-js' {
    export default class Stats {
      dom: HTMLElement;
      begin(): void;
      end(): void;
      update?(): void;
    }
  }
  