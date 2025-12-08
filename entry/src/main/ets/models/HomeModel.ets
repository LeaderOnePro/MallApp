// Banner项模型
export interface BannerItem {
  id: string;
  imgUrl: string;
  hrefUrl: string;
  type: string;
}

// 商品简要模型（用于列表展示）
export interface GoodsItem {
  id: string;
  name: string;
  desc: string;
  price: string;
  picture: string;
  orderNum?: number;
}

// 子分类模型
export interface SubCategory {
  id: string;
  name: string;
  picture: string;
  children?: SubCategory[] | null;
  goods?: GoodsItem[] | null;
}

// 首页分类模型
export interface CategoryItem {
  id: string;
  name: string;
  picture: string;
  children?: SubCategory[] | null;
  goods?: GoodsItem[] | null;
}

// 推荐商品模型
export interface RecommendGoods extends GoodsItem {
  discount?: number;
  sellNum?: number;
}
