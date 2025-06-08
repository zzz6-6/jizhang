import router from '@ohos.router'
import CommonStyle from '../config/CommonStyle'
import PreferencesUtil from '../utils/PreferencesUtil'

@Entry
@Component
struct Splash {
  aboutToAppear() {
    setTimeout(() => {
      this.jump()
    }, 1500)
  }

  async jump() {
    let userInfo = await PreferencesUtil.getInstance().getUserInfo()
    if (userInfo) {
      router.replaceUrl({ url: "pages/home/HomePage" })
    } else {
      router.replaceUrl({ url: "pages/LoginPage" })
    }
  }

  build() {
    Stack() {
      Column({ space: 15 }) {
        Image($r('app.media.app_icon')).width(57).aspectRatio(1)
        Text($r('app.string.app_name')).fontSize(20).fontColor(Color.Black).fontWeight(FontWeight.Bold)
      }
    }.width('100%')
    .height('100%').backgroundColor(CommonStyle.appPrimaryColor)
  }
}