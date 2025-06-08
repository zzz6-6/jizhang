import promptAction from '@ohos.promptAction'
import AppButton from '../../components/AppButton'
import {
  CategoryBen,
  expenditureCategoryList,
  EXPENDITURE_KEY,
  incomeCategoryList,
  INCOME_KEY
} from '../../config/CategoryList'
import CommonStyle from '../../config/CommonStyle'
import { BookKeepingService } from '../../db/BookKeepingService'
import DatePickDialog from '../../dialogs/DatePickDialog'
import { DateUtils } from '../../utils/DateUtils'

@Preview
@Component
export struct AddFragment {
  @State
  currentIndex: number = 0

  @Builder MyTabBuilder(content: string, index: number) {
    Stack({ alignContent: Alignment.Bottom }) {
      Text(content).height("100%").fontSize(16).fontColor(Color.Black)
      Row()
        .width(32)
        .height(2)
        .borderRadius(1)
        .backgroundColor(this.currentIndex === index ? Color.Black : Color.Transparent)
    }.padding({ left: 15, right: 15 })
    .onClick(() => {
      if (this.currentIndex !== index) {
        this.currentIndex = index
      }
    })
  }

  build() {
    Column() {
      Row() {
        this.MyTabBuilder("支出", EXPENDITURE_KEY)
        this.MyTabBuilder("收入", INCOME_KEY)
      }.width("100%").height(56)
      .backgroundColor(CommonStyle.appPrimaryColor)
      .justifyContent(FlexAlign.Center)

      if (this.currentIndex === EXPENDITURE_KEY) {
        CategoryFragment({ type: 0 })
      } else {
        CategoryFragment({ type: 1 })
      }

    }.width("100%").height("100%")
  }
}

@Component
struct CategoryFragment {
  @Prop
  type: number
  @State
  currentList: CategoryBen[] = []
  @State
  selectIndex: number = -1
  private dialogController: CustomDialogController | null = new CustomDialogController({
    builder: AddDialog({ data: this.currentList[this.selectIndex], type: this.type })
  })

  aboutToAppear() {
    if (this.type === EXPENDITURE_KEY) {
      this.currentList = expenditureCategoryList
    } else {
      this.currentList = incomeCategoryList
    }
  }

  aboutToDisappear() {
    this.dialogController = null
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Grid() {
        ForEach(this.currentList, (item: CategoryBen, index) => {
          GridItem() {
            ItemWidget({ data: item, checked: this.selectIndex === index })
          }.aspectRatio(1).onClick(() => {
            if (this.selectIndex !== index) {
              this.selectIndex = index
              this.dialogController?.open()
            }
          })
        })
      }
      .width("100%")
      .columnsTemplate("1fr 1fr 1fr 1fr")
      .rowsGap(12)
      .layoutWeight(1)
      .padding({ top: 15, bottom: 15 })

    }.width("100%").layoutWeight(1)
  }
}


@Component
struct ItemWidget {
  data: CategoryBen | null = null
  @Prop
  checked: boolean

  build() {
    Column({ space: 10 }) {
      Stack() {
        Image(this.data?.frontRes).width(50).aspectRatio(1)
      }
      .backgroundColor(this.checked ? CommonStyle.appPrimaryColor : "#F5F5F5")
      .width(60)
      .aspectRatio(1)
      .borderRadius(30)

      Text(this.data?.text).fontSize(16).fontColor(Color.Black)
    }.width("100%")
  }
}

@CustomDialog
struct AddDialog {
  private controller?: CustomDialogController
  data: CategoryBen|undefined
  type: number|undefined
  @State
  amount: string = ""
  @State
  remark: string = ""
  @Provide("selectedTime")
  createTime: number = Date.now()
  private dateDialogController: CustomDialogController | null = new CustomDialogController({
    builder: DatePickDialog({ selectedDate: new Date() }),
    autoCancel: false
  })

  aboutToDisappear() {
    this.dateDialogController = null
  }

  getDateText(): string {
    if (DateUtils.areSameDay(this.createTime, Date.now())) {
      return "今天"
    } else {
      return DateUtils.formatDate1(this.createTime)
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
      let res = await BookKeepingService.add(this.remark, aa, this.createTime, this.type??0, this.data?.id??0)
      if (res) {
        promptAction.showToast({ message: `提交成功` })
        this.controller?.close()
        AppStorage.SetOrCreate("addBookKeepingSuccess", Date.now())
      } else {
        promptAction.showDialog({ message: `提交失败` })
      }
    } catch (e) {
      promptAction.showDialog({ message: `提交失败:${JSON.stringify(e)}` })
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Stack() {
          Image(this.data?.bgRes)
          Image(this.data?.frontRes)
        }.width(30).aspectRatio(1)

        Text(this.data?.text).fontSize(16).fontColor(Color.Black)
      }

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

      Row({ space: 10 }) {
        Text() {
          Span("备注")
          Span("*").fontColor(Color.Transparent)
        }

        TextInput({ placeholder: "请输入备注", text: this.remark })
          .onChange((content) => {
            this.remark = content
          })
          .layoutWeight(1)
          .placeholderColor(CommonStyle.thirdTextColor)
          .caretColor(CommonStyle.appPrimaryColor)
          .fontColor(Color.Black)
      }

      Row({ space: 10 }) {
        Text() {
          Span("日期")
          Span("*").fontColor(Color.Transparent)
        }

        Text(this.getDateText()).layoutWeight(1).height(36).onClick(() => {
          this.dateDialogController?.open()
        })
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