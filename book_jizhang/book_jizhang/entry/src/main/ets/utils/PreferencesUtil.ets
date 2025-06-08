import dataPreferences from '@ohos.data.preferences'
import { UserBean } from '../db/UserApiService'
import { LoggerUtils } from './LoggerUtils'


const PREFERENCES_NAME = 'myPreferences'
const KEY_USER_INFO = 'user_info_key'

/**
 * 用户首选项
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/js-apis-data-preferences-0000001427745052-V2
 */
export default class PreferencesUtil {
  private static instance: PreferencesUtil;
  preferences: dataPreferences.Preferences|undefined

  public static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.instance) {
      PreferencesUtil.instance = new PreferencesUtil();
    }
    return PreferencesUtil.instance;
  }

  async init(context: Context) {
    this.preferences = await dataPreferences.getPreferences(
      context,
      PREFERENCES_NAME
    )
  }

  async setUserInfo(userInfo: UserBean | null | undefined) {
    try {
      if (userInfo) {
        this.preferences?.put(KEY_USER_INFO, JSON.stringify(userInfo))
      } else {
        this.preferences?.put(KEY_USER_INFO, "")
      }
      await this.preferences?.flush()
    } catch (e) {
      LoggerUtils.error(JSON.stringify(e))
    }
  }

  async getUserInfo(): Promise<UserBean | null> {
    try {
      const res = await this.preferences!!.get(KEY_USER_INFO, "")
      if (typeof res === 'string' && res.trim() !== "") {
        return JSON.parse(res) as UserBean
      }
    } catch (e) {
      LoggerUtils.error(JSON.stringify(e))
    }
    return null
  }
}