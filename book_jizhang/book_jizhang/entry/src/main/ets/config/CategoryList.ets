import { HashMap } from "@kit.ArkTS"

export interface CategoryBen {
  bgRes: ResourceStr
  frontRes: ResourceStr
  text: string
  id: number
  type: number
}

// 收入
export const INCOME_KEY: number = 1
// 支出
export const EXPENDITURE_KEY: number = 0

export const  CategoryDictionary = new HashMap<number,CategoryBen>()

const categoryList: CategoryBen[] = [
  {
    bgRes: $r('app.media.category_e_catering_fill'),
    frontRes: $r('app.media.category_e_catering_stroke'),
    text: "餐饮",
    id: 1,
    type: EXPENDITURE_KEY
  },
  {
    bgRes: $r('app.media.category_e_shopping_fill'),
    frontRes: $r('app.media.category_e_shopping_stroke'),
    text: "购物",
    id: 2,
    type: EXPENDITURE_KEY
  },
  {
    bgRes: $r('app.media.category_e_traffic_fill'),
    frontRes: $r('app.media.category_e_traffic_stroke'),
    text: "交通",
    id: 3,
    type: EXPENDITURE_KEY
  },
  {
    bgRes: $r('app.media.category_e_vegetable_fill'),
    frontRes: $r('app.media.category_e_vegetable_stroke'),
    text: "蔬菜",
    id: 4,
    type: EXPENDITURE_KEY
  },
  {
    bgRes: $r('app.media.category_e_snack_fill'),
    frontRes: $r('app.media.category_e_snack_stroke'),
    text: "零食",
    id: 5,
    type: EXPENDITURE_KEY
  },
  {
    bgRes: $r('app.media.category_e_sport_fill'),
    frontRes: $r('app.media.category_e_sport_stroke'),
    text: "运动",
    id: 6,
    type: EXPENDITURE_KEY
  },
  {
    bgRes: $r('app.media.category_i_wage_fill'),
    frontRes: $r('app.media.category_i_wage_stroke'),
    text: "工资",
    id: 7,
    type: INCOME_KEY
  },
  {
    bgRes: $r('app.media.category_i_parttimework_fill'),
    frontRes: $r('app.media.category_i_parttimework_stroke'),
    text: "兼职",
    id: 8,
    type: INCOME_KEY
  },
  {
    bgRes: $r('app.media.category_i_finance_fill'),
    frontRes: $r('app.media.category_i_finance_stroke'),
    text: "理财",
    id: 9,
    type: INCOME_KEY
  },
  {
    bgRes: $r('app.media.category_i_money_fill'),
    frontRes: $r('app.media.category_i_money_stroke'),
    text: "礼金",
    id: 10,
    type: INCOME_KEY
  },
  {
    bgRes: $r('app.media.category_i_other_fill'),
    frontRes: $r('app.media.category_i_other_stroke'),
    text: "其他",
    id: 11,
    type: INCOME_KEY
  }
]

export const incomeCategoryList: CategoryBen[] = categoryList.filter((el) => el.type === INCOME_KEY)

export const expenditureCategoryList: CategoryBen[] = categoryList.filter((el) => el.type === EXPENDITURE_KEY)

export const categoryMap = categoryList.reduce((acc: HashMap<number,CategoryBen>, item: CategoryBen) => {
  acc[item.id] = item
  return acc
},{} as HashMap<number, CategoryBen>);