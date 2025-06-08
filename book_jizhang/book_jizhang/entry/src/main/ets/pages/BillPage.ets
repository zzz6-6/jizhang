import CommonStyle from '../config/CommonStyle'
import { BookKeepingListWrapperBean, BookKeepingService } from '../db/BookKeepingService'
import DatePickDialog from '../dialogs/DatePickDialog'

@Entry
@Component
struct BillPage {
  @State
  currentIndex: number = 0
  @State
  currentYear: number = 2024
  @State
  currentMonth: number = 9
  @State
  income: number = 0
  @State
  expenditure: number = 0
  @State
  dataList: BookKeepingListWrapperBean[] = []
  @Provide("selectedTime")
  @Watch("changeDate")
  currentDate: number = Date.now()
  private dateDialogController: CustomDialogController | null = new CustomDialogController({
    builder: DatePickDialog({ selectedDate: new Date() }),
    autoCancel: false
  })

  changeDate() {
    let date = new Date(this.currentDate)
    this.currentYear = date.getFullYear()
    this.currentMonth = date.getMonth() + 1
    this.getList()
  }

  aboutToAppear() {
    this.getList()
  }

  async getList() {
    try {
      let res = await BookKeepingService.statistics(this.currentDate, this.currentIndex)
      if (res) {
        this.income = res.income
        this.expenditure = res.expenditure
        this.dataList = res.data
      } else {
        this.income = 0
        this.expenditure = 0
        this.dataList = []
      }
    } catch (e) {
      this.income = 0
      this.expenditure = 0
      this.dataList = []
    }
  }

  aboutToDisappear() {
    this.dateDialogController = null
  }

  @Builder TabBuilder(text: string, index: number) {
    Text(text)
      .fontColor(this.currentIndex === index ? Color.White : Color.Black)
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

  build() {
    Column() {
      Stack() {
        if (this.currentIndex === 0) {
          Row() {
            Row() {
              Text(`${`${this.currentYear}`.padStart(2, '0')}年`)
                .fontColor(CommonStyle.mainTextColor)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.pull_down_selector_normal')).width(11).aspectRatio(1)
            }.onClick(() => {
              this.dateDialogController?.open()
            })
          }.width("100%")
        }

        Row() {
          this.TabBuilder("月账单", 0)
          Row().width(1).height("100%").backgroundColor(Color.Black)
          this.TabBuilder("年账单", 1)
        }
        .width(120)
        .height(28)
        .borderColor(Color.Black)
        .borderWidth(1)
        .borderRadius(6)
        .clip(true)

      }.width("100%").padding(12)

      Stack() {
        Column({ space: 12 }) {
          Text(this.currentIndex === 0 ? "年结余" : "总结余").fontColor(Color.Black).fontSize(14)
          Text(`${(this.income - this.expenditure).toFixed(2)}`)
            .fontSize(26)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
          Row() {
            Row() {
              Text(this.currentIndex === 0 ? "年收入 " : "总收入 ").fontColor(Color.Black).fontSize(14)
              Text(`${this.income}`).fontColor(Color.Black).fontSize(18)
            }.layoutWeight(1)

            Row() {
              Text(this.currentIndex === 0 ? "年支出 " : "总支出 ").fontColor(Color.Black).fontSize(14)
              Text(`${this.expenditure}`).fontColor(Color.Black).fontSize(18)
            }.layoutWeight(1)

          }.width("100%").margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .width("100%")
        .backgroundColor(CommonStyle.appPrimaryColor)
        .padding(15)
        .borderRadius(10)
      }.width("100%").padding(15)

      List() {

        if (this.currentIndex === 0) {
          ListItem() {
            ItemWidget()
          }
        } else {
          ListItem() {
            ItemWidget({
              text1: "年份",
              text2: "年收入",
              text3: "年支出",
              text4: "年结余",
            })
          }
        }

        ForEach(this.dataList, (data: BookKeepingListWrapperBean) => {
          ListItem() {
            ItemWidget({
              text1: `${data.date}${this.currentIndex === 0 ? "月" : "年"}`,
              text2: `${data.income.toFixed(2)}`,
              text3: `${data.expenditure.toFixed(2)}`,
              text4: `${(data.income - data.expenditure).toFixed(2)}`,
              textColor: "#ff373737"
            })
          }
        })

        if (this.currentIndex !== 0) {

          ListItem() {
            Stack() {
              Text("年账单为自然年（1.1-12.31）").height(36).fontColor("#FF959595")
            }.width("100%")
          }
        }
      }
      .width("100%").height("100%")
      .divider({ color: "#fff4f4f4", strokeWidth: 1 }).padding({ left: 15, right: 15, bottom: 15 })
    }.width('100%')
    .height('100%')
  }
}

@Component
struct ItemWidget {
  text1: string = "月份"
  text2: string = "月收入"
  text3: string = "月支出"
  text4: string = "月结余"
  textColor: ResourceColor = "#FF959595"

  build() {
    Row() {
      Text(this.text1).layoutWeight(1).fontColor(this.textColor)
      Text(this.text2).layoutWeight(1).fontColor(this.textColor)
      Text(this.text3).layoutWeight(1).fontColor(this.textColor)
      Text(this.text4).layoutWeight(1).fontColor(this.textColor)
    }.width("100%").layoutWeight(1).height(36)
  }
}