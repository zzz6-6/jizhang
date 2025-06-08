import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import AppButton from '../components/AppButton'
import CommonStyle from '../config/CommonStyle'
import { UserApiService } from '../db/UserApiService'
import PreferencesUtil from '../utils/PreferencesUtil'

@Entry
@Component
struct LoginPage {
  @State
  mobile: string = ""
  @State
  password: string = ""

  @Styles pressedStyles() {
    .backgroundColor("#F6F7F8")
  }

  async submitData() {
    if (this.mobile.length === 0) {
      promptAction.showDialog({ message: "请输入手机号" })
      return
    }

    if (this.password.length === 0) {
      promptAction.showDialog({ message: "请输入密码" })
      return
    }

    try {
      const res = await UserApiService.login(this.mobile, this.password)
      if (res) {
        await PreferencesUtil.getInstance().setUserInfo(res)
        router.replaceUrl({ url: "pages/home/HomePage" })
      } else {
        promptAction.showDialog({ message: "登录失败" })
      }
    } catch (e) {
      promptAction.showDialog({ message: `登录失败：${JSON.stringify(e)}` })
    }

  }

  build() {
    Stack() {
      Column({ space: 15 }) {
        LoginOrRegisterLogo()
        Row().height(5)

        TextInput({ placeholder: "请输入手机号", text: this.mobile })
          .textTextInputStyle()
          .stateStyles({
            pressed: this.pressedStyles,
            normal: this.pressedStyles,
            disabled: this.pressedStyles,
            focused: this.pressedStyles,
            clicked: this.pressedStyles,
          })
          .type(InputType.PhoneNumber)
          .onChange((content) => {
            this.mobile = content
          })

        TextInput({ placeholder: "请输入密码", text: this.password })
          .textTextInputStyle()
          .stateStyles({
            pressed: this.pressedStyles,
            normal: this.pressedStyles,
            disabled: this.pressedStyles,
            focused: this.pressedStyles,
            clicked: this.pressedStyles,
          })
          .type(InputType.Password)
          .maxLength(11)
          .onChange((content) => {
            this.password = content
          })
        Row().height(5)

        AppButton({ btnText: "登录" })
          .onClick(() => {
            this.submitData()
          })

        Row() {
          Text("找回密码").fontSize(16).fontColor(Color.Gray).padding(15)
          Row().width(1).height(16).backgroundColor(Color.Gray)
          Text("注册账号").fontSize(16).fontColor(Color.Gray).padding(15).onClick(() => {
            router.pushUrl({ url: "pages/RegisterPage" })
          })
        }.width("100%").justifyContent(FlexAlign.Center)
      }.width('100%').padding(15)

    }.width('100%')
    .height('100%').backgroundColor(Color.White)
  }
}


@Extend(TextInput) function textTextInputStyle() {
  .height(40)
  .borderRadius(8)
  .fontSize(16)
  .fontColor(CommonStyle.mainTextColor)
  .placeholderColor(CommonStyle.thirdTextColor)
  .caretColor(CommonStyle.appPrimaryColor)
  .width("100%")
}

@Component
export struct LoginOrRegisterLogo {
  build() {
    Row({ space: 15 }) {
      Image($r('app.media.app_icon')).width(40).aspectRatio(1)
      Text($r('app.string.app_name')).fontSize(30).fontColor(Color.Black).fontWeight(FontWeight.Bold)
    }.width('100%')
  }
}