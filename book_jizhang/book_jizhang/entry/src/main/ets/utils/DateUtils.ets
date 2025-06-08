export class DateUtils {
  static subtractYear(year: number): Date {
    let currentDate = new Date()
    let currentYear = currentDate.getFullYear()
    currentDate.setFullYear(currentYear - year)
    return currentDate
  }

  static formatDate1(timestamp: number) {
    return DateUtils.formatDate(timestamp, 'YYYY/MM/dd')
  }

  static formatDate2(timestamp: number) {
    return DateUtils.formatDate(timestamp, 'YYYY-MM-dd HH:mm')
  }

  static formatDate3(timestamp: number, defaultText?: string) {
    return DateUtils.formatDate(timestamp, 'YYYY/MM', defaultText)
  }

  static formatDate(timestamp: number, format: 'YYYY/MM/dd' | 'YYYY-MM-dd HH:mm' | 'YYYY/MM', defaultText?: string): string {
    if (!timestamp) {
      return defaultText??''
    }
    const date = new Date(timestamp);

    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');

    switch (format) {
      case 'YYYY/MM/dd':
        return `${year}/${month}/${day}`;
      case 'YYYY/MM':
        return `${year}/${month}`;
      case 'YYYY-MM-dd HH:mm':
        return `${year}-${month}-${day} ${hours}:${minutes}`;
      default:
        throw new Error('Unsupported format');
    }
  }

  static addDay(date: Date, day: number = 1): Date {
    const newDate = new Date(date);
    newDate.setDate(newDate.getDate() + day);
    return newDate;
  }

  static getMonthStartAndEndTimestamps(timestamp: number):ESObject {
    const date = new Date(timestamp);

    const startOfMonth = new Date(date.getFullYear(), date.getMonth(), 1);

    const endOfMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59, 999);

    return {
      startOfMonth: startOfMonth.getTime(),
      endOfMonth: endOfMonth.getTime()
    };
  }

  static areSameDay(timestamp1: number, timestamp2: number): boolean {
    const date1 = new Date(timestamp1)
    const date2 = new Date(timestamp2)

    return date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  }

  static getMonthBoundsFromTimestamp(timestamp: number): ESObject {
    // 从时间戳创建日期对象
    const date = new Date(timestamp);

    // 获取年份和月份
    const year = date.getFullYear();
    const month = date.getMonth(); // getMonth() 返回的月份是从0开始的，0代表1月

    // 第一天日期对象
    const firstDay = new Date(year, month, 1);

    // 最后一天日期对象
    const lastDay = new Date(year, month + 1, 0, 23, 59, 59, 999);

    return { firstDay, lastDay } as ESObject;
  }

  static formatDateToChinese(date: Date): string {
    const months = date.getMonth() + 1 // getMonth() 是从 0 开始的，+1 转换为常规月份
    const days = date.getDate()
    const dayOfWeek = date.getDay() // getDay() 返回一个 0 (周日) 到 6 (周六) 之间的整数

    // 中文星期数组，使星期日为第一元素
    const chineseWeekdays = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
    const formattedWeekday = chineseWeekdays[dayOfWeek];

    // 格式化月和日，确保它们为两位数字
    const formattedMonth = months < 10 ? `0${months}` : `${months}`
    const formattedDay = days < 10 ? `0${days}` : `${days}`

    // 构造最终的格式化字符串
    return `${formattedMonth}月${formattedDay}日 ${formattedWeekday}`
  }

  static getWeekDates(date: Date = new Date()): Date[] {
    // 根据需要，你可以通过修改offset来改变一周的第一天是周几
    const weekStartOffset = date.getDay() === 0 ? -6 : 1; // 当天是周日时，视为上周的周一

    // 获取本周第一天（周一）
    date.setDate(date.getDate() - date.getDay() + weekStartOffset);

    // 创建一个新数组来存储一周的日期
    const weekDates: Date[] = [];

    // 添加一周的每一天到数组
    for (let i = 0; i < 7; i++) {
      // 使用 new Date(date) 来复制当前日期对象
      weekDates.push(new Date(date));
      // 移动到下一天
      date.setDate(date.getDate() + 1);
    }

    return weekDates;
  }
}

