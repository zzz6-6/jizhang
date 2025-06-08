import CommonStyle from '../config/CommonStyle'

@Preview
@Component
export default struct NoDataComponent {
  content: string = "暂无数据"

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.no_data')).width(88).aspectRatio(1)
      Text(this.content).fontSize(16).fontColor(CommonStyle.thirdTextColor)
    }
  }
}