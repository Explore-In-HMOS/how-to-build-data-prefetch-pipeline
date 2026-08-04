import { NewsItem } from '../model/NewsItem';

export interface SimulatedFetch {
  timerId: number;
  done: Promise<string>;
}

const REAL_HEADLINES: string[] = [
  'Morning fog lifts across the valley',
  'Weekend market adds ten new stalls',
  'Library extends late-night study hours',
  'City bus route gains a riverside stop',
  'Local choir schedules a spring concert',
  'Community garden opens new plots',
  'Ferry timetable shifts for the summer',
  'Night sky show draws early crowds'
];

const FILLER_WORDS: string[] = [
  'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing',
  'elit', 'sed', 'tempor', 'incididunt', 'labore', 'magna', 'aliqua'
];

export class MockNewsService {
  static readonly PAGE_SIZE: number = 20;

  static generateItem(index: number): NewsItem {
    const page: number = Math.floor(index / MockNewsService.PAGE_SIZE) + 1;
    const item: number = (index % MockNewsService.PAGE_SIZE) + 1;
    const debugTag: string = `Page ${page} · Item ${item}`;
    return new NewsItem(index, MockNewsService.headlineFor(index), debugTag);
  }

  static fetchBody(index: number): SimulatedFetch {
    let timerId: number = 0;
    const done: Promise<string> = new Promise<string>((resolve: (body: string) => void) => {
      timerId = setTimeout(() => {
        resolve(MockNewsService.bodyFor(index));
      }, MockNewsService.delayFor(index));
    });
    return { timerId: timerId, done: done };
  }

  private static headlineFor(index: number): string {
    if (index < REAL_HEADLINES.length) {
      return REAL_HEADLINES[index];
    }
    return `${MockNewsService.word(index, 0)} ${MockNewsService.word(index, 2)} report #${index}`;
  }

  private static bodyFor(index: number): string {
    const parts: string[] = [];
    for (let i = 0; i < 16; i++) {
      parts.push(MockNewsService.word(index, i));
    }
    const sentence: string = parts.join(' ');
    return `${sentence.charAt(0).toUpperCase()}${sentence.slice(1)}.`;
  }

  // Deterministic per-index latency in the 400-800ms range.
  private static delayFor(index: number): number {
    return 400 + (index * 53) % 401;
  }

  private static word(index: number, offset: number): string {
    return FILLER_WORDS[(index * 7 + offset * 3) % FILLER_WORDS.length];
  }
}
