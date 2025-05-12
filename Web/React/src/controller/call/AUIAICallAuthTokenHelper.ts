import { v4 as uuidv4 } from 'uuid';
import standardService from '../../service/standard';

export default class AUIAICallAuthTokenHelper {
  static shared = new AUIAICallAuthTokenHelper();

  private authToken: string = '';
  private requestTime: number = 0;
  private userId: string = '';
  private requestPromise: Promise<string> | null = null;

  isAuthTokenValid(): boolean {
    // Token 24小时有效，超过23小时则需要重新获取，避免在使用过程中失效
    return this.authToken.length > 0 && Date.now() - this.requestTime < 23 * 60 * 60 * 1000;
  }

  async fetchAuthToken(userId: string): Promise<string> {
    if (this.isAuthTokenValid() && this.userId === userId) {
      return this.authToken;
    }
    if (this.requestPromise && this.userId === userId) {
      return this.requestPromise;
    }
    this.userId = userId;
    this.requestPromise = this.requestNewAuthToken();
    return this.requestPromise;
  }

  async requestNewAuthToken(): Promise<string> {
    this.authToken = '';
    this.authToken = await standardService.getRtcAuthToken(this.userId, uuidv4());
    this.requestTime = Date.now();
    this.requestPromise = null;
    return this.authToken;
  }
}
