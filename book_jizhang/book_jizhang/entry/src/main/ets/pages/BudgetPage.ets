import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import AppButton from '../components/AppButton'
import NoDataComponent from '../components/NoData'
import CommonStyle from '../config/CommonStyle'
import { BookKeepingService } from '../db/BookKeepingService'
import BudgetService, { BudgetBean } from '../db/BudgetService'

@Entry
@Component
struct BudgetPage {
  @State
  income: number = 0
  @State
  expenditure: number = 0
  @State
  currentDate: number = Date.now()
  @Provide
  currentType: number = 0
  @State
  currentTypeTex: string = "月预算"
  @Provide
  budget: number = 0
  @Provide
  budgetInfo: BudgetBean | null = null
  private dialogController: CustomDialogController | null = new CustomDialogController({
    builder: AddBudgetDialog({
      onSuccess: () => {
        this.getList()
      }
    })
  })

  aboutToAppear() {
    this.getList()
  }

  aboutToDisappear() {
    this.dialogController = null
  }

  async getList() {
    try {
      let res = await BookKeepingService.statisticsByBudget(this.currentType)
      let dataList = await BudgetService.getCurrentBudget(this.currentType)
      if (res) {
        this.income = res.income
        this.expenditure = res.expenditure
      } else {
        this.income = 0
        this.expenditure = 0
      }
      if (dataList.length > 0) {
        this.budgetInfo = dataList[0]
        this.budget = dataList[0].amount
      } else {
        this.budgetInfo = null
        this.budget = 0
      }
    } catch (e) {
      this.income = 0
      this.budget = 0
      this.expenditure = 0
      this.budgetInfo = null
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Stack() {
            Image($r('app.media.arrow_back_ios_24dp_FILL0_wght400_GRAD0_opsz24')).width(24).aspectRatio(1)
          }.width(56).aspectRatio(1).onClick(() => {
            router.back()
          })

          Stack() {

            Select([
              { value: "月预算" },
              { value: "年预算" },
            ])
              .selected(this.currentType)
              .value(this.currentTypeTex)
              .selectedOptionBgColor(CommonStyle.appPrimaryColor)
              .selectedOptionFontColor(Color.Black)
              .optionFontColor(Color.Black)
              .backgroundColor(Color.Transparent)
              .onSelect((index,value) => {
                this.currentType = index
                this.currentTypeTex = value
                this.getList()
              })

          }.layoutWeight(1)

          Stack().width(56).aspectRatio(1)
        }.height(56)
        .width("100%")
        .backgroundColor(CommonStyle.appPrimaryColor)

        if (this.budget > 0) {
          Column() {
            Row() {
              Text(`${this.currentType == 0 ? `${this.budgetInfo?.month}月` : `${this.budgetInfo?.year}年`}总预算`)
                .fontSize(18)
                .fontColor(Color.Black)
              Blank()
              Text(`编辑`).fontSize(18).fontColor("#ff6d6d6d").height("100%").onClick(() => {
                this.dialogController?.open()
              })
            }.width("100%").height(44)

            Row({ space: 15 }) {
              Stack() {
                Progress({
                  value: this.expenditure <= 0 ? this.budget : this.expenditure,
                  total: this.budget,
                  type: ProgressType.Ring
                })
                  .backgroundColor(CommonStyle.appPrimaryColor)
                  .color("#F2F2F2").width("100%")
                  .style({ strokeWidth: 15, })
                if (this.expenditure > this.budget) {
                  Text("已超支").fontColor(Color.Red)
                } else {
                  Text(`剩余\n${Math.round(((this.budget - this.expenditure) / this.budget) * 100)}%`)
                    .textAlign(TextAlign.Center)
                    .fontColor(Color.Black)
                }
              }.width(100).aspectRatio(1)

              Column() {

                Column() {
                  Row() {
                    Text(`剩余预算`).fontSize(18).fontColor(Color.Black)
                    Blank()
                    Text(`${(this.budget - this.expenditure).toFixed(2)}`)
                      .fontSize(18)
                      .fontColor(Color.Black)
                  }.width("100%").height(40)

                  Row().width("100%").height(1).backgroundColor("#ffeeeeee")
                }.width("100%")

                Row() {
                  Text(`${this.currentType === 0 ? '本月' : '年度'}预算`).fontColor("#ff5b5b5b")
                  Blank()
                  Text(`${this.budget.toFixed(2)}`).fontColor("#ff5b5b5b")
                }.width("100%")

                Row() {
                  Text(`${this.currentType === 0 ? '本月' : '年度'}支出`).fontColor("#ff5b5b5b")
                  Blank()
                  Text(`${this.expenditure.toFixed(2)}`).fontColor("#ff5b5b5b")
                }.width("100%")

              }.layoutWeight(1).height(100).justifyContent(FlexAlign.SpaceBetween)

            }.width("100%")
          }.width("100%").padding(15)
        }

      }
      .width('100%')
      .height('100%')


      if (this.budget <= 0) {
        Column({ space: 20 }) {
          NoDataComponent({ content: "暂无预算" })
          Button("+ 添加预算")
            .fontColor(Color.Black)
            .backgroundColor(CommonStyle.appPrimaryColor)
            .onClick(() => {
              this.dialogController?.open()
            })
        }
        .backgroundColor(Color.White)
        .onClick(() => {
        })
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}

@CustomDialog
struct AddBudgetDialog {
  private controller?: CustomDialogController
  @State
  amount: string = ''
  @Consume
  currentType: number
  @Consume
  budgetInfo: BudgetBean | null
  onSuccess: () => void = () => {
  }

  aboutToAppear() {
    if (this.budgetInfo) {
      this.amount = `${this.budgetInfo.amount}`
    }
  }

  async submitData() {
    if (this.amount.length === 0) {
      promptAction.showDialog({ message: "请输入金额" })
      return
    }
    let aa = parseInt(this.amount)
    if (aa <= 0) {
      promptAction.showDialog({ message: "金额必须大于0" })
      return
    }
    try {
      await BudgetService.addBudget(aa, this.currentType, this.budgetInfo?.id??0)
      this.onSuccess()
      this.controller?.close()
    } catch (e) {
      promptAction.showDialog({ message: `添加预算失败:${JSON.stringify(e)}` })
    }
  }

  build() {
    Column({ space: 12 }) {

      Row({ space: 10 }) {
        Text() {
          Span("金额")
          Span("*").fontColor(Color.Red)
        }

        TextInput({ placeholder: "请输入金额", text: this.amount })
          .type(InputType.Number)
          .onChange((content) => {
            this.amount = content
          })
          .layoutWeight(1)
          .placeholderColor(CommonStyle.thirdTextColor)
          .caretColor(CommonStyle.appPrimaryColor)
          .fontColor(Color.Black)
      }

      AppButton({ btnText: "完成" }).onClick(() => {
        this.submitData()
      })
    }
    .backgroundColor(Color.White)
    .width("100%")
    .padding(15)
    .alignItems(HorizontalAlign.Start)
  }
}