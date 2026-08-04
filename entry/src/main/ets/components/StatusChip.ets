import { PipelineStatus } from '../model/PipelineState';

@Component
export struct StatusChip {
  @ObjectLink status: PipelineStatus;

  private isFetching(): boolean {
    return this.status.state === 'FETCHING';
  }

  build() {
    Row({ space: 5 }) {
      Circle({ width: 7, height: 7 })
        .fill(this.isFetching() ? '#32D74B' : '#8E8E93')

      Text(this.isFetching() ? `Fetching ${this.status.inFlight}` : 'Idle')
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isFetching() ? '#EAFBED' : '#C7C7CC')
    }
    .padding({ left: 9, right: 9, top: 5, bottom: 5 })
    .borderRadius(12)
    .backgroundColor(this.isFetching() ? '#1E3A24' : '#2C2C2E')
    .border({ width: 1, color: this.isFetching() ? '#32D74B' : '#3A3A3C' })
  }
}
