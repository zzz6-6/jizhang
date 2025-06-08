export class LoggerUtils {
  static log(data: string) {
    console.log("----------------------")
    console.log(data)
    console.log("----------------------")
  }

  static error(data: string) {
    console.error("----------------------")
    console.error(data)
    console.error("----------------------")
  }
}
