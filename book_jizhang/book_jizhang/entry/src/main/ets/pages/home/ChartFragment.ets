import CommonStyle from '../../config/CommonStyle'
import { McLineChart, Options } from '@mcui/mccharts'
import { BookKeepingService } from '../../db/BookKeepingService'

@Preview
@Component
export struct ChartFragment {
  @State
  currentIndex: number = 0

  @Builder TabBuilder(text: string, index: number) {
    Text(text)
      .fontColor(this.currentIndex === index ? CommonStyle.appPrimaryColor : Color.Black)
      .fontSize(14)
      .backgroundColor(this.currentIndex === index ? Color.Black : Color.Transparent)
      .textAlign(TextAlign.Center)
      .height("100%")
      .layoutWeight(1)
      .onClick(() => {
        if (this.currentIndex !== index) {
          this.currentIndex = index
          this.getList()
        }
      })
  }

  @State seriesOption: Options = new Options({
    xAxis: {
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    },
    series: [
      {
        name: '支出',
        data: [11, 11, 15, 13, 12, 130, 10]
      },
      {
        name: '收入',
        data: [11, 11, 15, 13, 12, 130, 10]
      },
    ]
  })

  aboutToAppear() {
    this.getList()
  }

  async getList() {
    try {
      let res = await BookKeepingService.statisticsByChart(this.currentIndex)
      if (!res) {
        return
      }
      this.seriesOption = new Options({
        color: [CommonStyle.appPrimaryColor, Color.Black, '#5f45ff', '#02cdff', '#0090ff', '#314976', '#f47a75', '#009db2', '#024b51', '#0780cf', '#765005'],
        xAxis: {
          data: res.dates
        },
        series: [
          {
            name: `收入`,
            data: res.incomeList,
          },
          {
            name: `支出`,
            data: res.expenditureList
          },
        ]
      })
    } catch (e) {
    }
  }

  build() {
    Column() {
      Column() {
        Row() {
          this.TabBuilder("周", 0)
          Row().width(1).height("100%").backgroundColor(Color.Black)
          this.TabBuilder("月", 1)
          Row().width(1).height("100%").backgroundColor(Color.Black)
          this.TabBuilder("年", 2)
        }
        .width("100%")
        .height(28)
        .borderColor(Color.Black)
        .borderWidth(1)
        .borderRadius(4)
        .clip(true)
      }.width("100%").backgroundColor(CommonStyle.appPrimaryColor).padding(12)

      McLineChart({
        options: this.seriesOption
      }).layoutWeight(1)
    }.width("100%").height("100%")
  }
}