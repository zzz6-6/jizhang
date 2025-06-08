import relationalStore from '@ohos.data.relationalStore'
import { Rdb } from './Rdb';
import { LoggerUtils } from '../utils/LoggerUtils'
import PreferencesUtil from '../utils/PreferencesUtil';

export interface UserBean {
  id: number,
  mobile: string,
  password: string
}

const userTableName: string = 'users'

export const userSql: string = `
CREATE TABLE IF NOT EXISTS ${userTableName}
(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  mobile TEXT NOT NULL,
  password TEXT NOT NULL
)
`

export class UserApiService {
  static async login(mobile: string, password: string): Promise<UserBean | undefined> {
    let predicates = new relationalStore.RdbPredicates(userTableName)
    predicates.equalTo("mobile", mobile).and().equalTo("password", password)
    let res = await Rdb.getInstance().query(predicates)
    let success = res.goToFirstRow()
    let userInfo: UserBean |undefined
    if (success) {
      const id = res.getLong(res.getColumnIndex("id"))
      if (id) {
        userInfo = {
          'id': id,
          'mobile': mobile,
          'password': password
        }
        LoggerUtils.log(`login success:${JSON.stringify(userInfo)}`)
      }
    }
    res.close()
    return userInfo
  }

  static async register(mobile: string,
                        password: string
  ): Promise<boolean> {
    const temp = await UserApiService.checkUserExistent(mobile)
    if (temp) {
      LoggerUtils.error(`register error because ${mobile} existent`)
      return false
    }

    const userInfo: relationalStore.ValuesBucket = {
      'mobile': mobile,
      'password': password,
    }
    return await Rdb.getInstance().insert(userTableName, userInfo)
  }

  private static async checkUserExistent(mobile: string): Promise<boolean> {
    const predicates = new relationalStore.RdbPredicates(userTableName)
    predicates.equalTo("mobile", mobile)
    const res = await Rdb.getInstance().query(predicates)
    const state = res.rowCount > 0
    res.close()
    return state
  }

  private static async queryUser(userId: number): Promise<boolean> {
    const predicates = new relationalStore.RdbPredicates(userTableName)
    predicates.equalTo("id", userId)
    const res = await Rdb.getInstance().query(predicates)
    const state = res.rowCount > 0
    res.close()
    return state
  }

  static async update(
    userId: number,
    mobile: string,
    password: string,
    email: string,
    province: string,
    birthday: Date,
  ): Promise<boolean> {
    let temp = await UserApiService.queryUser(userId)
    if (!temp) {
      LoggerUtils.error(`update error because ${userId} non-existent`)
      return false
    }

    const userInfo: relationalStore.ValuesBucket = {
      'mobile': mobile,
      'password': password,
      'email': email,
      'province': province,
      'birthday': birthday.getTime(),
    }
    const predicates = new relationalStore.RdbPredicates(userTableName)
    predicates.equalTo("id", userId)

    const res = await Rdb.getInstance().update(predicates, userInfo)

    await PreferencesUtil.getInstance().setUserInfo({
      'id': userId,
      'mobile': mobile,
      'password': password
    })
    return res
  }
}