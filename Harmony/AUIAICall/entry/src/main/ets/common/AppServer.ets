import axios, { AxiosRequestConfig, AxiosResponse } from '@ohos/axios';
import {
  InboundCallAIAgentInfo,
  InboundCallReqModel,
  InboundCallRsqModel, OutboundCallReqModel, OutboundCallRspModel } from '../model/PhoneCallModel';
import json from '@ohos.util.json';

interface TokenRequestModel {
  user_id?: string;
}
interface TokenResponseModel {
  rtc_auth_token: string;
  code: number
  timestamp: number
}

class AppServer {

  static USER_ID: string = '123';
  static TOKEN: string = '';

  //AppServer基地址
  static readonly BASE_URL: string = '你的AppServer线上域名';

  static readonly GET_RTC_AUTH_TOKEN_PATH: string = '/api/v2/aiagent/getRtcAuthToken';
  static readonly START_OUTBOUND_PATH: string = '/api/v2/aiagent/startAIAgentOutboundCall';
  static readonly DESCRIBE_AGENT_PATH: string = '/api/v2/aiagent/describeAIAgent';

  static async getJoinToken(): Promise<string> {
    const url = AppServer.BASE_URL + AppServer.GET_RTC_AUTH_TOKEN_PATH;
    const req: TokenRequestModel = {user_id: AppServer.USER_ID};
    const config: AxiosRequestConfig<TokenRequestModel> = { headers: { 'Authorization': AppServer.TOKEN } };
    const rsp: AxiosResponse<TokenResponseModel> = await axios.post<string, AxiosResponse<TokenResponseModel>, TokenRequestModel>(url, req, config);
    return rsp.data.rtc_auth_token;
  }

  static async startOutbound(req: OutboundCallReqModel): Promise<string | undefined> {
    const url = AppServer.BASE_URL + AppServer.START_OUTBOUND_PATH;
    const config: AxiosRequestConfig<OutboundCallReqModel> = { headers: { 'Authorization': AppServer.TOKEN } };
    const rsp: AxiosResponse<OutboundCallRspModel> = await axios.post<string, AxiosResponse<OutboundCallRspModel>, OutboundCallReqModel>(url, req, config);
    return rsp.data.instance_id;
  }

  static async getInboundPhoneNumber(agentId: string, region: string): Promise<string | undefined> {
    const url = AppServer.BASE_URL + AppServer.DESCRIBE_AGENT_PATH;
    const req: InboundCallReqModel = {user_id: AppServer.USER_ID, ai_agent_id: agentId, region: region};
    const config: AxiosRequestConfig<OutboundCallReqModel> = { headers: { 'Authorization': AppServer.TOKEN } };
    const rsp: AxiosResponse<InboundCallRsqModel> = await axios.post<string, AxiosResponse<InboundCallRsqModel>, InboundCallReqModel>(url, req, config);
    try {
      let agent: InboundCallAIAgentInfo = json.parse(rsp.data.ai_agent) as InboundCallAIAgentInfo;
      if (agent.InboundPhoneNumbers !== undefined && agent.InboundPhoneNumbers?.length > 0) {
        return agent.InboundPhoneNumbers![0];
      }
    } catch (e) {
    }
    return undefined;
  }
}

export { AppServer }