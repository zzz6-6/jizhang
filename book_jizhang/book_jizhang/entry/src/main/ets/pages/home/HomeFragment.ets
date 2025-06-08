import router from '@ohos.router'
import NoDataComponent from '../../components/NoData'
import { EXPENDITURE_KEY } from '../../config/CategoryList'
import CommonStyle from '../../config/CommonStyle'
import { BookKeepingListBean, BookKeepingListWrapperBean, BookKeepingService } from '../../db/BookKeepingService'
import DatePickDialog from '../../dialogs/DatePickDialog'

@Preview
@Component
export struct HomeFragment {
  @State
  income: number = 0
  @State
  expenditure: number = 0
  @State
  dataList: BookKeepingListWrapperBean[] = []
  @State
  currentYear: number = 2024
  @State
  currentMonth: number = 9
  @Provide("selectedTime")
  @Watch("changeDate")
  currentDate: number = Date.now()
  private dateDialogController: CustomDialogController | null = new CustomDialogController({
    builder: DatePickDialog({ selectedDate: new Date() }),
    autoCancel: false
  })
  @StorageProp('addBookKeepingSuccess')
  @Watch('onAddBookKeepingSuccessWatch')
  addBookKeepingSuccess: number = Date.now()

  onAddBookKeepingSuccessWatch() {
    this.getList()
  }

  changeDate() {
    let date = new Date(this.currentDate)
    this.currentYear = date.getFullYear()
    this.currentMonth = date.getMonth() + 1
    this.getList()
  }

  aboutToAppear() {
    this.changeDate()
    this.getList()
  }

  aboutToDisappear() {
    this.dateDialogController = null
  }

  async getList() {
    try {
      let res = await BookKeepingService.getList(this.currentDate)
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

  build() {
    Column() {
      Column() {
        Row() {
          Text($r('app.string.app_name')).fontColor(Color.Black).fontWeight(FontWeight.Bold)
        }.width("100%").height(56).justifyContent(FlexAlign.Center)

        Row({ space: 30 }) {
          Column() {
            Text(`${this.currentYear}`).fontColor(Color.Black).fontSize(12).margin({bottom:6})
            Row({ space: 15 }) {
              Text(`${`${this.currentMonth}`.padStart(2, '0')}月`)
                .fontColor(CommonStyle.mainTextColor)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.pull_down_selector_normal')).width(11).aspectRatio(1)
            }
          }.alignItems(HorizontalAlign.Center).onClick(() => {
            this.dateDialogController?.open()
          })

          Column() {
            Text(`收入`).fontColor(Color.Black).fontSize(14).margin({bottom:6})
            Text(`${`${this.income.toFixed(2)}`}`)
              .fontColor(CommonStyle.mainTextColor)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
          }.alignItems(HorizontalAlign.Center).layoutWeight(1)

          Column() {
            Text(`支出`).fontColor(Color.Black).fontSize(14).margin({bottom:6})
            Text(`${`${this.expenditure.toFixed(2)}`}`)
              .fontColor(CommonStyle.mainTextColor)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
          }.alignItems(HorizontalAlign.Center).layoutWeight(1)

        }.width("100%").padding({ left: 15, right: 15, top: 10, bottom: 10 })
      }.width("100%").backgroundColor(CommonStyle.appPrimaryColor)
      //
      // Row() {
      //   IconWithIconBgAndText({
      //     backIcon: $r('app.media.sk_icon_detail_op_zhangdan'),
      //     /*frontIcon: $r('app.media.sk_icon_detail_op_bill_stroke'),*/
      //     content: "账单"
      //   }).layoutWeight(1).onClick(() => {
      //     router.pushUrl({ url: "pages/BillPage" })
      //   })
      //
      //   IconWithIconBgAndText({
      //     backIcon: $r('app.media.sk_icon_detail_op_yusuan'),
      //     /*frontIcon: $r('app.media.sk_icon_detail_op_budget_stroke'),*/
      //     content: "预算"
      //   }).layoutWeight(1).onClick(()=>{
      //     router.pushUrl({ url: "pages/BudgetPage" })
      //   })
      //
      //   IconWithIconBgAndText({
      //     backIcon: $r('app.media.sk_icon_detail_op_zichan'),
      //     /*frontIcon: $r('app.media.sk_icon_detail_op_assets_stroke'),*/
      //     content: "资产管家"
      //   }).layoutWeight(1)
      //
      //   /*IconWithIconBgAndText({
      //     backIcon: $r('app.media.sk_icon_detail_op_saving_fill'),
      //     frontIcon: $r('app.media.sk_icon_detail_op_saving_stroke'),
      //     content: "购物返现"
      //   }).layoutWeight(1)*/
      //
      //   IconWithIconBgAndText({
      //     backIcon: $r('app.media.sk_icon_detail_op_gengduo'),
      //     /*frontIcon: $r('app.media.sk_icon_detail_op_more_stroke'),*/
      //     content: "更多"
      //   }).layoutWeight(1)
      //
      // }.width("100%").height(56).backgroundColor(Color.White)

      if (this.dataList.length === 0) {
        Stack() {
          NoDataComponent()
        }.width("100%").layoutWeight(1)
      } else {
        List() {
          ForEach(this.dataList, (data: BookKeepingListWrapperBean) => {
            ListItemGroup({ header: this.itemHead(data) }) {
              ForEach(data.infoList, (item: BookKeepingListBean) => {
                ListItem() {
                  ItemWidget({ data: item })
                }.width("100%")
              })
            }.width("100%")
          })
        }.height("100%").width("100%").divider({ strokeWidth: 0.5, color: CommonStyle.thirdTextColor })

      }
    }.width("100%").height("100%")
  }

  @Builder itemHead(data: BookKeepingListWrapperBean) {
    Column() {
      Row({ space: 10 }) {
        Text(data.date).fontSize(CommonStyle.thirdTextColor).fontSize(12).layoutWeight(1)
        if (data.income > 0) {
          Text(`收入：${data.income.toFixed(2)}`).fontSize(CommonStyle.thirdTextColor).fontSize(12)
        }
        if (data.expenditure > 0) {
          Text(`支出：${data.expenditure.toFixed(2)}`).fontSize(CommonStyle.thirdTextColor).fontSize(12)
        }
      }.width("100%").padding(12)
    }.width("100%")
  }
}

@Component
struct IconWithIconBgAndText {
  backIcon: ResourceStr = ''
  frontIcon: ResourceStr = ''
  content: string = ''

  build() {
    Column({ space: 4 }) {
      Stack() {
        Image(this.backIcon)
        Image(this.frontIcon)
      }.width(28).aspectRatio(1)

      Text(this.content).fontColor(Color.Black).fontSize(12)
    }.width("100%").height("100%").justifyContent(FlexAlign.Center)
  }
}

@Component
struct ItemWidget {
  data: BookKeepingListBean |undefined

  build() {
    Row({ space: 10 }) {
      Stack() {
        if (this.data!!!!.categoryInfo) {
          Image(this.data!!.categoryInfo.bgRes)
          Image(this.data!!.categoryInfo.frontRes)
        }
      }
      .width(40)
      .padding(5)
      .aspectRatio(1)
      .backgroundColor("#FFF4F4F4")
      .borderRadius(20)

      Text(this.data!!.categoryInfo?.text??'').fontColor(Color.Black).fontSize(16).layoutWeight(1)
      Text(`${this.data!!.type === EXPENDITURE_KEY ? '-' : ''}${this.data!!.amount.toFixed(2)}`)
        .fontColor(CommonStyle.thirdTextColor)
        .fontSize(16)
    }.width("100%").padding(12)
  }
}