import relationalStore from '@ohos.data.relationalStore'
import { LoggerUtils } from '../utils/LoggerUtils'
import { bookKeepingSql } from './BookKeepingService'
import { budgetSql } from './BudgetService'
import { userSql } from './UserApiService'


//
// https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/js-apis-data-relationalstore-0000001493744128-V2
//
export class Rdb {
  private static instance: Rdb
  private STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'RdbTest.db', // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全级别
  };

  private constructor() {
  }

  public static getInstance(): Rdb {
    if (!Rdb.instance) {
      Rdb.instance = new Rdb();
    }
    return Rdb.instance;
  }

  store: relationalStore.RdbStore|undefined;

  async init(context: Context) {
    try {
      this.store = await this.getRdbStore(context);
      await this.store.executeSql(userSql)
      this.store.executeSql(bookKeepingSql)
      this.store.executeSql(budgetSql)
     // await this.store.executeSql('DROP TABLE IF EXISTS user_budget;')
    } catch (e) {
      LoggerUtils.error(`Rdb init error:${JSON.stringify(e)}`)
    }
  }

  private async getRdbStore(context: Context): Promise<relationalStore.RdbStore> {
    return await relationalStore.getRdbStore(context, this.STORE_CONFIG)
  }


  async insert(tableName: string, values: relationalStore.ValuesBucket): Promise<boolean> {
    const res = await this.store?.insert(tableName, values)
    return res !== -1
  }

  /**
   * https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/js-apis-data-relationalstore-0000001493744128-V2#ZH-CN_TOPIC_0000001523648806__update-1
   *
   * @param predicates
   * @param values
   * @returns
   */
  async update(predicates: relationalStore.RdbPredicates, values: relationalStore.ValuesBucket): Promise<boolean> {
    const res = await this.store!!.update(values, predicates)
    return res > 0
  }

  async delete(predicates: relationalStore.RdbPredicates): Promise<boolean> {
    const res = await this.store!!.delete(predicates)
    return res > 0
  }

  async query(predicates: relationalStore.RdbPredicates, columns?: Array<string>): Promise<relationalStore.ResultSet> {
    const res = await this.store!!.query(predicates, columns)
    return res
  }
}