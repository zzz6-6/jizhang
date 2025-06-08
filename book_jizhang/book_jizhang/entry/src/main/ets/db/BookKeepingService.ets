import relationalStore from '@ohos.data.relationalStore'
import { CategoryBen, categoryMap, INCOME_KEY } from '../config/CategoryList'
import { DateUtils } from '../utils/DateUtils'
import PreferencesUtil from '../utils/PreferencesUtil'
import { Rdb } from './Rdb'

export interface BookKeepingBean {
  id: number
  amount: number
  time: number
  createTime: number
  remark: string
  type: number
  userId: number
  categoryId: number
}

export interface BookKeepingListBean extends Omit<BookKeepingBean, 'categoryId'> {
  categoryInfo: CategoryBen | null
}

export interface BookKeepingListWrapperBean {
  infoList: BookKeepingListBean[]
  date: string
  income: number
  expenditure: number
}

export interface BookKeepingWrapperBean {
  data: BookKeepingListWrapperBean[]
  income: number
  expenditure: number
}

const tableName: string = "book_jizhang"

export const bookKeepingSql: string = `
CREATE TABLE IF NOT EXISTS ${tableName}
(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  remark TEXT NOT NULL,
  amount INTEGER NOT NULL,
  createTime INTEGER NOT NULL,
  time INTEGER NOT NULL,
  type INTEGER NOT NULL,
  userId INTEGER NOT NULL,
  categoryId INTEGER NOT NULL
)
`

export class BookKeepingService {
  static async add(remark: string,
                   amount: number,
                   time: number,
                   type: number,
                   categoryId: number,
  ): Promise<boolean> {
    let userInfo = await PreferencesUtil.getInstance().getUserInfo()
    if (!userInfo) {
      throw new Error("请先登录")
    }
    const bucket: relationalStore.ValuesBucket = {
      'remark': remark,
      'amount': amount,
      'createTime': Date.now(),
      'time': time,
      'type': type,
      'categoryId': categoryId,
      'userId': userInfo.id,
    }
    return await Rdb.getInstance().insert(tableName, bucket)
  }

  static async getList(time: number): Promise<BookKeepingWrapperBean | null> {
    let userInfo = await PreferencesUtil.getInstance().getUserInfo()
    if (!userInfo) {
      throw new Error("请先登录")
    }

    const predicates = new relationalStore.RdbPredicates(tableName)
    predicates.equalTo("userId", userInfo.id)
    let bounds:ESObject = DateUtils.getMonthBoundsFromTimestamp(time)
    predicates.and().between('time', bounds.firstDay.getTime(), bounds.lastDay.getTime())
    predicates.orderByDesc("createTime")
    let resultSet = await Rdb.getInstance().query(predicates)

    let list: BookKeepingListBean[] = []
    let rowCount = resultSet.rowCount
    if (rowCount <= 0) {
      return null
    }
    for (let i = 0; i < rowCount; i++) {
      let success = resultSet.goToRow(i)
      if (success) {
        list.push({
          'id': resultSet.getLong(resultSet.getColumnIndex("id")),
          'userId': resultSet.getLong(resultSet.getColumnIndex("userId")),
          'createTime': resultSet.getLong(resultSet.getColumnIndex("createTime")),
          'time': resultSet.getLong(resultSet.getColumnIndex("time")),
          'type': resultSet.getLong(resultSet.getColumnIndex("type")),
          'amount': resultSet.getLong(resultSet.getColumnIndex("amount")),
          'remark': resultSet.getString(resultSet.getColumnIndex("remark")),
          'categoryInfo': categoryMap[resultSet.getLong(resultSet.getColumnIndex("categoryId")) as number]
        })
      }
    }
    let totalIncome = 0
    let totalExpenditure = 0
    let map = new Map<string, BookKeepingListBean[]>()

    list.forEach((el) => {
      let date = new Date(el.time)
      let dateStr = DateUtils.formatDateToChinese(date)
      let res = map.get(dateStr)
      if (res) {
        res.push(el)
      } else {
        res = [el]
      }
      if (el.type === INCOME_KEY) {
        totalIncome += el.amount
      } else {
        totalExpenditure += el.amount
      }
      map.set(dateStr, res)
    })
    let list2: BookKeepingListWrapperBean[] = []
    map.forEach((value, key) => {
      let aa = 0
      let bb = 0
      value.forEach((el) => {
        if (el.type === INCOME_KEY) {
          aa += el.amount
        } else {
          bb += el.amount
        }
      })
      let data: BookKeepingListWrapperBean = {
        date: key,
        income: aa,
        expenditure: bb,
        infoList: value
      }
      list2.push(data)
    })
    return {
      'income': totalIncome,
      'expenditure': totalExpenditure,
      'data': list2
    }
  }

  static async statistics(dateTime: number, type: number): Promise<BookKeepingWrapperBean | null> {
    let userInfo = await PreferencesUtil.getInstance().getUserInfo()
    if (!userInfo) {
      throw new Error("请先登录")
    }
    const predicates = new relationalStore.RdbPredicates(tableName)
    predicates.equalTo("userId", userInfo.id)
    let currentDate = new Date(dateTime)
    if (type === 0) {
      // 月账单
      let startDate = new Date(`${currentDate.getFullYear()}-01-01`)
      let endDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0, 23, 59, 59, 999)
      predicates.and().between('time', startDate.getTime(), endDate.getTime())
    }

    let resultSet = await Rdb.getInstance().query(predicates)

    let list: BookKeepingListBean[] = []
    let rowCount = resultSet.rowCount
    if (rowCount <= 0) {
      return null
    }
    for (let i = 0; i < rowCount; i++) {
      let success = resultSet.goToRow(i)
      if (success) {
        list.push({
          'id': resultSet.getLong(resultSet.getColumnIndex("id")),
          'userId': resultSet.getLong(resultSet.getColumnIndex("userId")),
          'createTime': resultSet.getLong(resultSet.getColumnIndex("createTime")),
          'time': resultSet.getLong(resultSet.getColumnIndex("time")),
          'type': resultSet.getLong(resultSet.getColumnIndex("type")),
          'amount': resultSet.getLong(resultSet.getColumnIndex("amount")),
          'remark': resultSet.getString(resultSet.getColumnIndex("remark")),
          'categoryInfo': categoryMap[resultSet.getLong(resultSet.getColumnIndex("categoryId"))]
        })
      }
    }
    let totalIncome = 0
    let totalExpenditure = 0
    let map = new Map<string, BookKeepingListBean[]>()

    if (type === 0) {
      let mon = currentDate.getMonth() + 1
      if (currentDate.getFullYear() !== new Date().getFullYear()) {
        mon = 12
      }
      for (let i = 0; i < mon; i++) {
        map.set(`${i + 1}`, [])
      }
    }

    list.forEach((el) => {
      let date = new Date(el.time)
      let dateStr = ''
      if (type === 0) {
        dateStr = `${date.getMonth() + 1}`
      } else {
        dateStr = `${date.getFullYear()}`
      }
      let res = map.get(dateStr)
      if (res) {
        res.push(el)
      } else {
        res = [el]
      }
      if (el.type === INCOME_KEY) {
        totalIncome += el.amount
      } else {
        totalExpenditure += el.amount
      }
      map.set(dateStr, res)
    })
    let list2: BookKeepingListWrapperBean[] = []
    map.forEach((value, key) => {
      let aa = 0
      let bb = 0
      value.forEach((el) => {
        if (el.type === INCOME_KEY) {
          aa += el.amount
        } else {
          bb += el.amount
        }
      })
      let data: BookKeepingListWrapperBean = {
        date: key,
        income: aa,
        expenditure: bb,
        infoList: value
      }
      list2.push(data)
    })
    list2.sort((a, b) => {
      let aa = parseInt(a.date)
      let bb = parseInt(b.date)
      if (aa > bb) {
        return 0
      } else {
        return 1
      }
    }
    )
    return {
      'income': totalIncome,
      'expenditure': totalExpenditure,
      'data': list2
    }
  }

  static async statisticsByBudget(type: number): Promise<BookKeepingWrapperBean | null> {
    let userInfo = await PreferencesUtil.getInstance().getUserInfo()
    if (!userInfo) {
      throw new Error("请先登录")
    }
    const predicates = new relationalStore.RdbPredicates(tableName)
    predicates.equalTo("userId", userInfo.id)

    let resultSet = await Rdb.getInstance().query(predicates)

    let list: BookKeepingListBean[] = []
    let rowCount = resultSet.rowCount
    if (rowCount <= 0) {
      return null
    }
    for (let i = 0; i < rowCount; i++) {
      let success = resultSet.goToRow(i)
      if (success) {
        list.push({
          'id': resultSet.getLong(resultSet.getColumnIndex("id")),
          'userId': resultSet.getLong(resultSet.getColumnIndex("userId")),
          'createTime': resultSet.getLong(resultSet.getColumnIndex("createTime")),
          'time': resultSet.getLong(resultSet.getColumnIndex("time")),
          'type': resultSet.getLong(resultSet.getColumnIndex("type")),
          'amount': resultSet.getLong(resultSet.getColumnIndex("amount")),
          'remark': resultSet.getString(resultSet.getColumnIndex("remark")),
          'categoryInfo': categoryMap[resultSet.getLong(resultSet.getColumnIndex("categoryId"))]
        })
      }
    }
    let totalIncome = 0
    let totalExpenditure = 0

    let currentDate = new Date()

    list.forEach((el) => {
      let date = new Date(el.time)
      let dateStr = ''
      if (type === 0) {
        dateStr = `${date.getFullYear()}年${date.getMonth() + 1}月`
        if (dateStr === `${currentDate.getFullYear()}年${currentDate.getMonth() + 1}月`) {
          if (el.type === INCOME_KEY) {
            totalIncome += el.amount
          } else {
            totalExpenditure += el.amount
          }
        }
      } else {
        dateStr = `${date.getFullYear()}年`
        if (dateStr === `${currentDate.getFullYear()}年`) {
          if (el.type === INCOME_KEY) {
            totalIncome += el.amount
          } else {
            totalExpenditure += el.amount
          }
        }
      }
    })
    return {
      'income': totalIncome,
      'expenditure': totalExpenditure,
      'data': []
    }
  }

  static async statisticsByChart(type: number): Promise<BookKeepingChartBean | null> {
    let userInfo = await PreferencesUtil.getInstance().getUserInfo()
    if (!userInfo) {
      throw new Error("请先登录")
    }
    const predicates = new relationalStore.RdbPredicates(tableName)

    predicates.equalTo("userId", userInfo.id)

    let resultSet = await Rdb.getInstance().query(predicates)

    let list: BookKeepingListBean[] = []
    let rowCount = resultSet.rowCount
    if (rowCount <= 0) {
      return null
    }
    for (let i = 0; i < rowCount; i++) {
      let success = resultSet.goToRow(i)
      if (success) {
        list.push({
          'id': resultSet.getLong(resultSet.getColumnIndex("id")),
          'userId': resultSet.getLong(resultSet.getColumnIndex("userId")),
          'createTime': resultSet.getLong(resultSet.getColumnIndex("createTime")),
          'time': resultSet.getLong(resultSet.getColumnIndex("time")),
          'type': resultSet.getLong(resultSet.getColumnIndex("type")),
          'amount': resultSet.getLong(resultSet.getColumnIndex("amount")),
          'remark': resultSet.getString(resultSet.getColumnIndex("remark")),
          'categoryInfo': categoryMap[resultSet.getLong(resultSet.getColumnIndex("categoryId"))]
        })
      }
    }


    let map = new Map<string, BookKeepingListBean[]>()

    if (type === 0) {
      let bounds = DateUtils.getWeekDates()
      bounds.forEach((el) => {
        let aa = el.getFullYear().toString()
        let bb = (el.getMonth() + 1).toString().padStart(2, "0")
        let cc = el.getDate().toString().padStart(2, "0")
        map.set(`${aa}-${bb}-${cc}`, [])
      })
    } else if (type === 1) {
      let currentDate = new Date()
      for (let i = 1; i <= 12; i++) {
        const month = i.toString().padStart(2, '0');
        map.set(`${currentDate.getFullYear()}-${month}`, [])
      }
    } else {
      let currentDate = new Date()
      for (let i = 0; i < 7; i++) {
        map.set(`${currentDate.getFullYear() - i}`, [])
      }
    }

    let totalIncome = 0
    let totalExpenditure = 0

    list.forEach((el) => {
      let date = new Date(el.time)
      let dateStr = ''
      let aa = date.getFullYear().toString()
      let bb = (date.getMonth() + 1).toString().padStart(2, "0")
      let cc = date.getDate().toString().padStart(2, "0")
      if (type === 0) {
        dateStr = `${aa}-${bb}-${cc}`
      } else if (type === 1) {
        dateStr = `${aa}-${bb}`
      } else {
        dateStr = `${aa}`
      }
      let temp = map.get(dateStr)
      if (temp) {
        temp.push(el)
        map.set(dateStr, temp)
        if (el.type === INCOME_KEY) {
          totalIncome += el.amount
        } else {
          totalExpenditure += el.amount
        }
      }
    })

    let list2: BookKeepingListWrapperBean[] = []

    map.forEach((value, key) => {
      let aa = 0
      let bb = 0
      value.forEach((el) => {
        if (el.type === INCOME_KEY) {
          aa += el.amount
        } else {
          bb += el.amount
        }
      })
      let data: BookKeepingListWrapperBean = {
        date: key,
        income: aa,
        expenditure: bb,
        infoList: value
      }
      list2.push(data)
    })

    list2.sort((a, b) => a.date.localeCompare(b.date))

    let dates: string[]
    if (type === 1 || type === 0) {
      let currentDate = new Date()
      dates = list2.map((el) => el.date.replace(`${currentDate.getFullYear()}-`, ''))
    } else {
      dates = list2.map((el) => el.date)
    }

    return {
      'income': totalIncome,
      'expenditure': totalExpenditure,
      'dates': dates,
      'incomeList': list2.map((el) => el.income),
      'expenditureList': list2.map((el) => el.expenditure),
    }
  }
}

export interface BookKeepingChartBean {
  income: number
  expenditure: number
  dates: string[]
  incomeList: number[]
  expenditureList: number[]
}
