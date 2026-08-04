import { IDataSourcePrefetching } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { NewsItem } from '../model/NewsItem';
import { PipelineStatus } from '../model/PipelineState';
import { MockNewsService, SimulatedFetch } from '../service/MockNewsService';

const DOMAIN = 0x0000;
const TAG = 'PrefetchPipeline';
const LOAD_MORE_MARGIN = 5;

export class NewsDataSource implements IDataSourcePrefetching {
  private readonly items: NewsItem[] = [];
  private readonly listeners: DataChangeListener[] = [];
  private readonly fetches: Map<number, number> = new Map();
  readonly status: PipelineStatus;

  constructor(status: PipelineStatus) {
    this.status = status;
    this.loadPage();
  }

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): NewsItem {
    return this.items[index];
  }

  loadMoreIfNeeded(visibleEnd: number): void {
    if (visibleEnd >= this.items.length - LOAD_MORE_MARGIN) {
      this.loadPage();
    }
  }

  async prefetch(index: number): Promise<void>  {
    const item: NewsItem = this.items[index];
    if (!item || item.body !== undefined || this.fetches.has(index)) {
      return;
    }
    item.loading = true;
    this.status.onFetchStart();
    hilog.info(DOMAIN, TAG, 'prefetch start #%{public}d (in-flight %{public}d)', index, this.status.inFlight);
    new Promise<void>((resolve: () => void) => {
      const fetch: SimulatedFetch = MockNewsService.fetchBody(index);
      this.fetches.set(index, fetch.timerId);
      fetch.done.then((body: string) => {
        this.fetches.delete(index);
        item.body = body;
        item.loading = false;
        this.status.onFetchComplete();
        hilog.info(DOMAIN, TAG, 'prefetch done #%{public}d (in-flight %{public}d)', index, this.status.inFlight);
        resolve();
      });
    });
  }

  cancel(index: number): void {
    const timerId: number | undefined = this.fetches.get(index);
    if (timerId !== undefined) {
      clearTimeout(timerId);
      this.fetches.delete(index);
      const item: NewsItem = this.items[index];
      if (item) {
        item.loading = false;
      }
      this.status.onFetchCancel();
      hilog.info(DOMAIN, TAG, 'prefetch cancel #%{public}d (in-flight %{public}d)', index, this.status.inFlight);
    }
  }

  reset(): void {
    this.fetches.forEach((timerId: number) => clearTimeout(timerId));
    this.fetches.clear();
    this.items.forEach((item: NewsItem) => {
      item.body = undefined;
      item.loading = false;
    });
    this.status.reset();
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos: number = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  private loadPage(): void {
    const startIndex: number = this.items.length;
    const newItems: NewsItem[] = [];
    for (let i = startIndex; i < startIndex + MockNewsService.PAGE_SIZE; i++) {
      newItems.push(MockNewsService.generateItem(i));
    }
    this.items.splice(startIndex, 0, ...newItems);
    this.notifyBatchUpdate([
      {
        type: DataOperationType.ADD,
        index: startIndex,
        count: newItems.length,
        key: newItems.map((item: NewsItem) => item.key)
      }
    ]);
  }

  private notifyBatchUpdate(operations: DataOperation[]): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDatasetChange(operations);
    });
  }
}
