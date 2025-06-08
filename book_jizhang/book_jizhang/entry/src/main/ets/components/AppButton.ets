import CommonStyle from '../config/CommonStyle'

@Preview
@Component
export default struct AppButton {
  @Prop
  btnText: string

  build() {
    Row() {
      Text(this.btnText).fontColor(CommonStyle.mainTextColor)
    }
    .width('100%')
    .backgroundColor(CommonStyle.appPrimaryColor)
    .justifyContent(FlexAlign.Center)
    .height(46)
    .borderRadius(8)
  }
}