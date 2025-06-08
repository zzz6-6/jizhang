import relationalStore from '@ohos.data.relationalStore'
import PreferencesUtil from '../utils/PreferencesUtil'
import { Rdb } from './Rdb'

export interface BudgetBean {
  id: number
  year: number
  month: number
  userId: number
  type: number
  amount: number
  createTime: number
}

const tableName: string = "user_budget"

export const budgetSql: string = `
CREATE TABLE IF NOT EXISTS ${tableName}
(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount INTEGER NOT NULL,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL,
  createTime INTEGER NOT NULL,
  type INTEGER NOT NULL,
  userId INTEGER NOT NULL
)
`

export default class BudgetService {
  static async addBudget(amount: number, type: number, id: number) {
    let userInfo = await PreferencesUtil.getInstance().getUserInfo()
    if (!userInfo) {
      throw new Error("请先登录")
    }
    if (id > 0) {
      return await BudgetService.updateBudget(amount, id)
    }
    let currentDate = new Date()
    const bucket: relationalStore.ValuesBucket = {
      'amount': amount,
      'year': currentDate.getFullYear(),
      'month': currentDate.getMonth() + 1,
      'type': type,
      'userId': userInfo.id,
      'createTime': Date.now(),
    }
    return await Rdb.getInstance().insert(tableName, bucket)
  }

  static async updateBudget(amount: number, id: number): Promise<boolean> {
    const bucket: relationalStore.ValuesBucket = {
      'amount': amount,
      'createTime': Date.now(),
    }
    const predicates = new relationalStore.RdbPredicates(tableName)
    predicates.equalTo("id", id)
    return await Rdb.getInstance().update(predicates, bucket)
  }

  static async getCurrentBudget(type: number): Promise<BudgetBean[]> {
    let userInfo = await PreferencesUtil.getInstance().getUserInfo()
    if (!userInfo) {
      throw new Error("请先登录")
    }

    const predicates = new relationalStore.RdbPredicates(tableName)
    predicates.equalTo("userId", userInfo.id)
    predicates
      .and()
      .equalTo('type', type)
    predicates.orderByDesc("createTime").limitAs(1)
    let resultSet = await Rdb.getInstance().query(predicates)
    let rowCount = resultSet.rowCount
    let list: BudgetBean[] = []

    if (rowCount <= 0) {
      return list
    }
    for (let i = 0; i < rowCount; i++) {
      let success = resultSet.goToRow(i)
      if (success) {
        list.push({
          'id': resultSet.getLong(resultSet.getColumnIndex("id")),
          'userId': resultSet.getLong(resultSet.getColumnIndex("userId")),
          'type': resultSet.getLong(resultSet.getColumnIndex("type")),
          'amount': resultSet.getLong(resultSet.getColumnIndex("amount")),
          'year': resultSet.getLong(resultSet.getColumnIndex("year")),
          'month': resultSet.getLong(resultSet.getColumnIndex("month")),
          'createTime': resultSet.getLong(resultSet.getColumnIndex("createTime")),
        })
      }
    }

    return list
  }
}