import { ARTCAICallRTCTokenHelper, ARTCAICallUtils } from '@aliyun_video_cloud/alivcsdk_artc';
import { LogUtil } from '@pura/harmony-utils';
import { AppServer } from './AppServer';
import json from '@ohos.util.json';

interface FetchTokenInfo {
  token: string,
  channelId: string,
  time: number
}


class TokenHelper {

  private constructor() {
  }
  static readonly shared: TokenHelper = new TokenHelper();


  // 开启开发模式的话，需要填入ARTC_APP_ID、ARTC_APP_KEY
  // NOTE: 开发模式不可以用于发布
  private static readonly DEVELOP_MODE: boolean = false;
  private static readonly ARTC_APP_ID: string = '';
  private static readonly ARTC_APP_KEY: string = '';

  private tokenInfo: FetchTokenInfo = {token: '', channelId: '', time: 0};
  private completed?: (token: string | undefined)=>void;
  private isRequesting: boolean = false;

  private isValid() {
    if (this.tokenInfo.token.length > 0) {
      if (Date.now() - this.tokenInfo.time < 23 * 60 * 60 * 1000) {
        return true;
      }
    }
    return false;
  }

  public fetchAuthToken(completed: (token: string | undefined)=>void) {
    if (this.isValid()) {
      LogUtil.debug(`use the saved AuthToken: ${json.stringify(this.tokenInfo)}`);
      completed?.(this.tokenInfo.token);
      this.resetAuthToken();
      this.requestNewAuthToken();
      return;
    }
    this.completed = completed;
    this.requestNewAuthToken();
  }

  public async requestNewAuthToken() {
    if (this.isRequesting === true) {
      return;
    }
    this.isRequesting = true;
    const userId = AppServer.USER_ID;
    const channelId = ARTCAICallUtils.random();
    let joinToken: string = '';
    if (TokenHelper.DEVELOP_MODE === true) {
      ARTCAICallRTCTokenHelper.AppId = TokenHelper.ARTC_APP_ID;
      ARTCAICallRTCTokenHelper.AppKey = TokenHelper.ARTC_APP_KEY;
      joinToken = await ARTCAICallRTCTokenHelper.GenerateJoinToken(channelId, userId, '');
    }
    else {
      joinToken = await AppServer.getJoinToken();
    }

    this.isRequesting = false;
    const tokenInfo: FetchTokenInfo = {
      token: joinToken,
      channelId: channelId,
      time: Date.now()
    }

    if (this.completed) {
      LogUtil.debug(`fetch and use the AuthToken: ${json.stringify(tokenInfo)}`);
      this.completed(joinToken);
      this.completed = undefined;

      this.requestNewAuthToken();
    }
    else {
      LogUtil.debug(`fetch and save AuthToken: ${json.stringify(tokenInfo)}`);
      this.tokenInfo = tokenInfo;
    }
  }

  resetAuthToken() {
    this.tokenInfo = {token: '', channelId: '', time: 0};
  }

}

export { TokenHelper }