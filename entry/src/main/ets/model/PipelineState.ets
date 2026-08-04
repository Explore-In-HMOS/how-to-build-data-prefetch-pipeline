export type PipelineState = 'IDLE' | 'FETCHING';

@Observed
export class PipelineStatus {
  state: PipelineState = 'IDLE';
  inFlight: number = 0;
  totalPrefetched: number = 0;
  totalCanceled: number = 0;

  onFetchStart(): void {
    this.inFlight += 1;
    this.state = 'FETCHING';
  }

  onFetchComplete(): void {
    this.inFlight = Math.max(0, this.inFlight - 1);
    this.totalPrefetched += 1;
    this.state = this.inFlight > 0 ? 'FETCHING' : 'IDLE';
  }

  onFetchCancel(): void {
    this.inFlight = Math.max(0, this.inFlight - 1);
    this.totalCanceled += 1;
    this.state = this.inFlight > 0 ? 'FETCHING' : 'IDLE';
  }

  reset(): void {
    this.state = 'IDLE';
    this.inFlight = 0;
    this.totalPrefetched = 0;
    this.totalCanceled = 0;
  }
}
