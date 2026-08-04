import { NewsItem } from '../model/NewsItem';

@Reusable
@Component
export struct NewsCard {
  @ObjectLink info: NewsItem;

  build() {
    Column({ space: 3 }) {
      Text(this.info.headline)
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F2F2F7')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Text(this.info.debugTag)
        .fontSize(8)
        .fontColor('#8E8E93')
        .width('100%')

      if (this.info.loading) {
        Text('Loading…')
          .fontSize(9)
          .fontColor('#5AC8FA')
          .width('100%')
      } else if (this.info.body !== undefined) {
        Text(this.info.body)
          .fontSize(9)
          .fontColor('#C7C7CC')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      } else {
        Text('Scroll to load')
          .fontSize(9)
          .fontColor('#8E8E93')
          .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .borderRadius(10)
    .backgroundColor('#1C1C1E')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }
}
