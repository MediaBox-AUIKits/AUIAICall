import { AICallErrorCode } from 'aliyun-auikit-aicall';

const i18n = {
  'login.tokenExpired': '登录态失效，请重新登录！',

  'agent.voice': '语音通话',
  'agent.avatar': '数字人通话',

  'setting.voiceInterruptTitle': '智能打断',
  'setting.voiceInterruptHelp': '根据声音和环境智能体打断AI智能体',

  'setting.voiceIdTitle': '选择音色',
  'setting.voiceIdHelp': '切换音色后，AI将在下一次回答中使用新的音色',

  'status.listeningToStart': '请开始说话',
  'status.listening': '你说，我在听...',
  'status.thinking': '思考中...',
  'status.speaking': '我正在回复中，可以点击“tab”键或说话打断我',
  'status.speakingNoInterrupt': '我正在回复中，可以点击“tab”键打断我',

  'error.localDeviceException': '通话失败，本地设备出现了错误',
  'error.tokenExpired': '通话失败，当前授权已过期',
  'error.connectionFailed': '通话失败，当前网络连接出现问题',
  'error.kickedByUserReplace': '通话失败，当前用户可能登录了其他设备',
  'error.kickedBySystem': '通话失败，被系统结束通话',
  'error.agentLeaveChannel': '通话失败，智能体停止通话了',
  'error.agentPullFailed': '通话失败，智能体拉流失败',
  'error.agentASRFailed': '第三方ASR服务不可用',
  'error.avatarServiceFailed': '数字人服务不可用',
  'error.avatarRoutesExhausted': '数字人通话火爆，请稍后尝试或先享AI音频通话新体验。',
  'error.unknown': '通话失败，发生未知错误',

  'avatar.timeLimit': '通话结束，数字人通话仅可以体验5分钟。',
};

const ErrorCodeMessageMap: { [key: number]: string } = {
  [AICallErrorCode.ConnectionFailed]: i18n['error.connectionFailed'],
  [AICallErrorCode.KickedByUserReplace]: i18n['error.kickedByUserReplace'],
  [AICallErrorCode.KickedBySystem]: i18n['error.kickedBySystem'],
  [AICallErrorCode.LocalDeviceException]: i18n['error.localDeviceException'],
  [AICallErrorCode.AgentLeaveChannel]: i18n['error.agentLeaveChannel'],
  [AICallErrorCode.AgentPullFailed]: i18n['error.agentPullFailed'],
  [AICallErrorCode.AgentASRFailed]: i18n['error.agentASRFailed'],
  [AICallErrorCode.AvatarServiceFailed]: i18n['error.avatarServiceFailed'],
  [AICallErrorCode.AvatarRoutesExhausted]: i18n['error.avatarRoutesExhausted'],
};

export const getErrorMessage = (errorCode?: number) => {
  if (!errorCode) {
    return i18n['error.unknown'];
  }
  return ErrorCodeMessageMap[errorCode] || i18n['error.unknown'];
};

export default i18n;
