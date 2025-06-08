import CommonStyle from '../config/CommonStyle'

@CustomDialog
export default struct DatePickDialog {
  controller?: CustomDialogController
  selectedDate: Date = new Date()
  @Consume("selectedTime")
  selectedTime: number

  build() {
    Column({ space: 12 }) {
      DatePicker({
        selected: this.selectedDate
      })
        .onChange((value: DatePickerResult) => {
          this.selectedDate.setFullYear(value.year!!, value.month, value.day)
        })
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#b5b5b7')
          .onClick(() => this.controller?.close())
        Button('确定')
          .layoutWeight(1)
          .backgroundColor(CommonStyle.appPrimaryColor)
          .onClick(() => {
            this.selectedTime = this.selectedDate.getTime()
            this.controller?.close()
          })
      }
    }
    .padding(12)
  }
}
