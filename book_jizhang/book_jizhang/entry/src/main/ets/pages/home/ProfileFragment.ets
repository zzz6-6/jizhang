import router from '@ohos.router'
import CommonStyle from '../../config/CommonStyle'
import { UserBean } from '../../db/UserApiService'
import PreferencesUtil from '../../utils/PreferencesUtil'

@Preview
@Component
export struct ProfileFragment {
  @State
  user: UserBean | null = null

  aboutToAppear() {
    this.getUserInfo()
  }

  async getUserInfo() {
    this.user = await PreferencesUtil.getInstance().getUserInfo()
  }

  async logout() {
    await PreferencesUtil.getInstance().setUserInfo(null)
    router.replaceUrl({ url: "pages/LoginPage" })
  }

  build() {
    Stack() {
      Column() {
        Text('我的').fontWeight(FontWeight.Bold).fontSize(25).padding(16).width('100%')
        Row() {
          Image($r('app.media.icon')).width(87).aspectRatio(1)
          Text(`${this.user?.mobile}`).margin({ left: 16 })
          Blank().layoutWeight(1)
        }
        .justifyContent(FlexAlign.Start)
        .margin({ left: 16, right: 16 })
        .borderRadius(20)
        .padding(16)
        .backgroundImageSize(ImageSize.FILL)
        .backgroundImage($r('app.media.icon'))
        .backgroundBlurStyle(BlurStyle.Regular)

        Column() {
          Row() {
            Image($r('app.media.sk_icon_detail_op_zhangdan'))
              .width(20).height(20)
            Text('我的账单').layoutWeight(1).margin({left:16})
            Image($r('app.media.right_grey')).width(12).height(24)
          }.onClick(() => {
            router.pushUrl({ url: "pages/BillPage" })
          })

          Divider().margin({top:16,bottom:16}).color('#eeeeee').strokeWidth(1)
          Row() {
            Image($r('app.media.sk_icon_detail_op_yusuan'))
              .width(20).height(20)
            Text('我的预算').layoutWeight(1).margin({left:16})
            Image($r('app.media.right_grey')).width(12).height(24)
          }.onClick(() => {
            router.pushUrl({ url: "pages/BudgetPage" })
          })

        }.padding(16).backgroundColor(Color.White).borderRadius(16).margin(16)

        Blank().layoutWeight(1)
        if (this.user) {
          Button("退出登录", { type: ButtonType.Capsule })// 创建一个按钮
            .width('70%')// 设置按钮宽度
            .height(50)// 设置按钮高度
            .fontSize(18)// 设置字号
            .fontColor(Color.White)// 设置字体颜色
            .fontWeight(FontWeight.Medium)// 设置字体权重
            .backgroundColor(CommonStyle.appPrimaryColor)// 设置背景颜色
            .margin({ bottom: 20 })// 设置外边距
            .onClick(() => {
              //登录跳转
              this.logout()
            })
        }
      }
    }.width("100%").height("100%")
  }
}