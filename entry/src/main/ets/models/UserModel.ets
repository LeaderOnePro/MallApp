// 用户信息模型
export interface UserInfo {
  id: string;
  account: string;
  mobile: string;
  token: string;
  avatar: string;
  nickname?: string;
  gender?: string;
  birthday?: string;
  cityCode?: string;
  provinceCode?: string;
  profession?: string;
}

// 登录请求参数
export interface LoginParams {
  account: string;
  password: string;
}
