import CommonStyle from '../../config/CommonStyle'
import { AddFragment } from './AddFragment'
import { ChartFragment } from './ChartFragment'
import { HomeFragment } from './HomeFragment'
import { ProfileFragment } from './ProfileFragment'

@Entry
@Component
struct HomePage {
  @State currentIndex: number = 0

  @Builder tabBuilder(title: string, index: number, normalImg: Resource, selectedImg: Resource) {
    Column() {
      Stack() {
        Image(selectedImg).visibility(this.currentIndex === index ? Visibility.Visible : Visibility.Hidden)
        Image(normalImg)
      }.width(26)
      .aspectRatio(1)

      Text(title).fontSize(15)
        .fontColor(Color.Black)
    }
    .justifyContent(FlexAlign.SpaceAround)
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        HomeFragment()
      }
      .tabBar(this.tabBuilder("首页", 0, $r('app.media.bottom_detail_stroke'), $r('app.media.bottom_detail_fill')))
      .backgroundColor(Color.White)

      TabContent() {
        ChartFragment()
      }
      .tabBar(this.tabBuilder("图表", 1, $r('app.media.bottom_chart_stroke'), $r('app.media.bottom_chart_fill')))
      .backgroundColor(Color.White)

      TabContent() {
        AddFragment()
      }
      .tabBar(this.tabBuilder("记账", 2, $r('app.media.bottom_add_stroke'), $r('app.media.bottom_assets_fill')))
      .backgroundColor(Color.White)

      TabContent() {
        ProfileFragment()
      }
      .tabBar(this.tabBuilder("我的", 3, $r('app.media.bottom_me_stroke'), $r('app.media.bottom_me_fill')))
      .backgroundColor("#efefef")
    }.width("100%").scrollable(false).backgroundColor(Color.White)
    .onChange((index) => {
      this.currentIndex = index
    })
  }
}




