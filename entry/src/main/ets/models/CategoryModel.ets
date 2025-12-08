import { GoodsItem } from './HomeModel';

// 分类页面的主分类模型
export interface MainCategory {
  id: string;
  name: string;
  picture: string;
  children: SubCategoryItem[];
  goods: GoodsItem[];
}

// 分类页面的子分类模型
export interface SubCategoryItem {
  id: string;
  name: string;
  picture: string;
  children: null;
  goods: null;
}

// 二级分类内容模型
export interface CategoryContent {
  id: string;
  name: string;
  picture: string;
  children?: CategoryContentChild[];
  brands?: Brand[];
}

export interface CategoryContentChild {
  id: string;
  name: string;
  picture: string;
}

export interface Brand {
  id: string;
  name: string;
  logo: string;
}
