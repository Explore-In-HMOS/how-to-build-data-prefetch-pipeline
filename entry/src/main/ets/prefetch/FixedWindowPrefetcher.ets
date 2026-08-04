import { IDataSourcePrefetching, IPrefetcher } from '@kit.ArkUI';

const LOOK_AHEAD = 3;

// Teaching foil to BasicPrefetcher: BasicPrefetcher adapts how many items it
// prefetches (and what it cancels) from scroll speed and fetch duration, while
// this one always covers the visible items plus a fixed window of LOOK_AHEAD ahead.
export class FixedWindowPrefetcher implements IPrefetcher {
  private dataSource?: IDataSourcePrefetching;

  setDataSource(dataSource: IDataSourcePrefetching): void {
    this.dataSource = dataSource;
  }

  visibleAreaChanged(minVisible: number, maxVisible: number): void {
    const total: number = this.dataSource?.totalCount() ?? 0;
    const start: number = Math.max(0, minVisible);
    const end: number = Math.min(total, maxVisible + LOOK_AHEAD + 1);
    for (let i = start; i < end; i++) {
      this.dataSource?.prefetch(i);
    }
  }
}
