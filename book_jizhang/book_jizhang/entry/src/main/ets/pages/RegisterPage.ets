import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import AppButton from '../components/AppButton'
import CommonStyle from '../config/CommonStyle'
import { UserApiService } from '../db/UserApiService'
import AppBar from '../components/AppBar'
import { LoginOrRegisterLogo } from './LoginPage'

@Entry
@Component
struct RegisterPage {
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
      const res = await UserApiService.register(this.mobile, this.password)
      if (res) {
        promptAction.showToast({ message: "注册成功" })
        router.back()
      } else {
        promptAction.showDialog({ message: "注册失败" })
      }
    } catch (e) {
      promptAction.showDialog({ message: `注册失败：${JSON.stringify(e)}` })
    }

  }

  build() {
    Column() {
      AppBar({ title: "" })
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
            .maxLength(11)
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
            .onChange((content) => {
              this.password = content
            })
          Row().height(5)

          AppButton({ btnText: "注册" })
            .onClick(() => {
              this.submitData()
            })

        }.width('100%').padding(15)

      }.width('100%').layoutWeight(1)

    }.height('100%').backgroundColor(Color.White)
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