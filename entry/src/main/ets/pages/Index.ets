import { BasicPrefetcher, IPrefetcher } from '@kit.ArkUI';
import { NewsDataSource } from '../data/NewsDataSource';
import { NewsCard } from '../components/NewsCard';
import { StatusChip } from '../components/StatusChip';
import { NewsItem } from '../model/NewsItem';
import { PipelineStatus } from '../model/PipelineState';
import { FixedWindowPrefetcher } from '../prefetch/FixedWindowPrefetcher';

type Strategy = 'BASIC' | 'FIXED';

@Entry
@Component
struct Index {
  @State private status: PipelineStatus = new PipelineStatus();
  private dataSource: NewsDataSource = new NewsDataSource(this.status);
  @State private strategy: Strategy = 'BASIC';
  private prefetcher: IPrefetcher = new BasicPrefetcher(this.dataSource);
  private listScroller: Scroller = new Scroller();
  private visibleStart: number = 0;
  private visibleEnd: number = 0;

  private resetFeed(): void {
    this.dataSource.reset();
    this.listScroller.scrollEdge(Edge.Top);
    this.visibleStart = 0;
    this.visibleEnd = 0;
    // BasicPrefetcher only loads ahead of the visible area, so load the top
    // window directly to refill the on-screen cards, then let the prefetcher run.
    const top: number = Math.min(this.dataSource.totalCount(), 6);
    for (let i = 0; i < top; i++) {
      this.dataSource.prefetch(i);
    }
    this.prefetcher.visibleAreaChanged(0, top - 1);
  }

  private switchStrategy(next: Strategy): void {
    if (next === this.strategy) {
      return;
    }
    this.strategy = next;
    const prefetcher: IPrefetcher =
      next === 'BASIC' ? new BasicPrefetcher(this.dataSource) : new FixedWindowPrefetcher();
    prefetcher.setDataSource(this.dataSource);
    this.prefetcher = prefetcher;
    // Apply the new strategy to the range already on screen.
    this.prefetcher.visibleAreaChanged(this.visibleStart, this.visibleEnd);
  }

  @Builder
  private segment(label: string, value: Strategy) {
    Text(label)
      .fontSize(10)
      .fontWeight(this.strategy === value ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.strategy === value ? '#000000' : '#EBEBF5')
      .textAlign(TextAlign.Center)
      .padding({ top: 3, bottom: 3 })
      .layoutWeight(1)
      .backgroundColor(this.strategy === value ? '#32D74B' : '#2C2C2E')
      .borderRadius(8)
      .onClick(() => this.switchStrategy(value))
  }

  build() {
    Column() {
      Row() {
        this.segment('Basic', 'BASIC')
        this.segment('Fixed×3', 'FIXED')
      }
      .width('60%')
      .padding(2)
      .backgroundColor('#1C1C1E')
      .borderRadius(9)
      .margin({ top: 10, bottom: 4 })

      Text('Reset')
        .fontSize(10)
        .fontColor('#EBEBF5')
        .textAlign(TextAlign.Center)
        .padding({ left: 12, right: 12, top: 3, bottom: 3 })
        .backgroundColor('#2C2C2E')
        .borderRadius(8)
        .margin({ bottom: 6 })
        .onClick(() => this.resetFeed())

      Stack() {
        List({ space: 8, scroller: this.listScroller }) {
          LazyForEach(this.dataSource, (item: NewsItem) => {
            ListItem() {
              NewsCard({ info: item })
            }
            .height(74)
            .width('100%')
          }, (item: NewsItem) => item.key)
        }
        .width('86%')
        .height('100%')
        .cachedCount(3)
        .scrollBar(BarState.Off)
        .onScrollIndex((start: number, end: number) => {
          this.visibleStart = start;
          this.visibleEnd = end;
          this.dataSource.loadMoreIfNeeded(end);
          this.prefetcher.visibleAreaChanged(start, end);
        })

        StatusChip({ status: this.status })
          .offset({ y: -10 })
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Bottom)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
