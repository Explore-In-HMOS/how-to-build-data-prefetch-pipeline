@Observed
export class NewsItem {
  index: number;
  headline: string;
  body?: string;
  debugTag: string;
  loading: boolean;
  readonly key: string;

  constructor(index: number, headline: string, debugTag: string) {
    this.index = index;
    this.headline = headline;
    this.debugTag = debugTag;
    this.loading = false;
    this.key = `news-${index}`;
  }
}
