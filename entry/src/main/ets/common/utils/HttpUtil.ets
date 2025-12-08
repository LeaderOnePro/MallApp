import { http } from '@kit.NetworkKit';

// API响应基础接口
export interface ApiResponse<T> {
  code: string;
  msg: string;
  result: T;
}

// HTTP请求工具类
class HttpUtil {
  // 发起GET请求
  async get<T>(url: string, token?: string): Promise<ApiResponse<T>> {
    return this.request<T>(url, http.RequestMethod.GET, undefined, token);
  }

  // 发起POST请求
  async post<T>(url: string, data?: object, token?: string): Promise<ApiResponse<T>> {
    return this.request<T>(url, http.RequestMethod.POST, data, token);
  }

  // 发起PUT请求
  async put<T>(url: string, data?: object, token?: string): Promise<ApiResponse<T>> {
    return this.request<T>(url, http.RequestMethod.PUT, data, token);
  }

  // 发起DELETE请求
  async delete<T>(url: string, data?: object, token?: string): Promise<ApiResponse<T>> {
    return this.request<T>(url, http.RequestMethod.DELETE, data, token);
  }

  // 通用请求方法
  private async request<T>(
    url: string,
    method: http.RequestMethod,
    data?: object,
    token?: string
  ): Promise<ApiResponse<T>> {
    const httpRequest = http.createHttp();

    try {
      const headers: Record<string, string> = {
        'Content-Type': 'application/json'
      };

      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }

      const response = await httpRequest.request(url, {
        method: method,
        header: headers,
        extraData: data ? JSON.stringify(data) : undefined,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 30000,
        readTimeout: 30000
      });

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ApiResponse<T>;
        return result;
      } else {
        const errorMsg = `HTTP Error: ${response.responseCode}`;
        console.error(errorMsg);
        return Promise.reject(errorMsg);
      }
    } catch (error) {
      const errorStr = JSON.stringify(error);
      console.error('HttpUtil request error:', errorStr);
      return Promise.reject(errorStr);
    } finally {
      httpRequest.destroy();
    }
  }
}

// 导出单例
const httpUtil = new HttpUtil();
export default httpUtil;
