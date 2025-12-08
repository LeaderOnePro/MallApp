// 购物车商品模型
export interface CartItem {
  id: string;
  skuId: string;
  name: string;
  attrsText: string;
  specs: string[];
  picture: string;
  price: string;
  nowPrice: string;
  nowOriginalPrice: string;
  selected: boolean;
  stock: number;
  count: number;
  isEffective: boolean;
  discount?: number | null;
  isCollect: boolean;
  postFee: number;
}

// 购物车修改参数
export interface CartUpdateParams {
  selected?: boolean;
  count?: number;
}
