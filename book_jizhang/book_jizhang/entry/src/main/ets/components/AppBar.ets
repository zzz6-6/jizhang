import router from '@ohos.router'


@Component
export default struct AppBar {
  @Prop title: string
  appBarHeight: number = 56

  build() {
    Row() {
      Stack() {
        Image($r("app.media.arrow_back_ios_24dp_FILL0_wght400_GRAD0_opsz24"))
          .width(24)
          .aspectRatio(1)
          .onClick(() => {
            router.back()
          })
      }
      .width(this.appBarHeight)
      .aspectRatio(1)

      Text(this.title)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Stack() {
      }
      .width(this.appBarHeight)
      .aspectRatio(1)
    }
    .width('100%')
    .height(this.appBarHeight)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
  }
}