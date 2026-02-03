/**
 * @description AI电话请求传参
 * **/


interface OutboundCallReqModel {
  user_id: string,
  ai_agent_id?: string,
  region?: string,
  called_number?: string,
  config?: string,
  user_data?: string,
  session_id?: string,
}

interface OutboundCallRspModel {
  code: number,
  request_id?: string,
  instance_id?: string,
  error_code?: string,
  message?: string
}

interface InboundCallReqModel {
  user_id: string,
  ai_agent_id?: string,
  region?: string,
}


interface InboundCallRsqModel {
  code: number,
  ai_agent: string
}

interface InboundCallAIAgentInfo {
  InboundPhoneNumbers?: string[];
}



export { OutboundCallReqModel, OutboundCallRspModel, InboundCallReqModel, InboundCallRsqModel, InboundCallAIAgentInfo }