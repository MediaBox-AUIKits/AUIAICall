import { AICallErrorCode } from 'aliyun-auikit-aicall';

const i18n = {
  'login.tokenExpired': '登录态失效，请重新登录！',

  'agent.voice': '语音通话',
  'agent.avatar': '数字人通话',
  'agent.vision': '视觉理解通话',
  'agent.chatbot': '消息对话',

  'push.pushtoTalk': '按住讲话',
  'push.releaseToSend': '松开发送',
  'push.pushToTalkMode': '对讲机模式',
  'push.pushtoTalk_releaseToSend': '按下按钮后讲话，松开按钮后结束讲话 ',
  'push.openFail': '打开/关闭对讲机模式失败',
  'push.turnedOn': '对讲机模式已打开',
  'push.turnedOff': '对讲机模式已关闭',

  'setting.modeTitle': '通话模式',

  'setting.voiceInterruptTitle': '智能打断',
  'setting.voiceInterruptHelp': '根据声音和环境智能打断AI智能体',

  'setting.voiceIdTitle': '选择音色',
  'setting.voiceIdHelp': '切换音色后，AI将在下一次回答中使用新的音色',

  'status.listeningToStart': '请开始说话',
  'status.listening': '你说，我在听...',
  'status.thinking': '思考中...',
  'status.speaking': '我正在回复中，可以点击“tab”键或说话打断我',
  'status.speakingNoInterrupt': '我正在回复中，可以点击“tab”键打断我',

  'status.mobile.speaking': '我正在回复中，可以轻触屏幕或说话打断我',
  'status.mobile.speakingNoInterrupt': '我正在回复中，可以轻触屏幕打断我',

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
  'error.subscriptionRequired': '接通失败，请检查您账号是否正确订购套餐',
  'error.agentNotFound': '接通失败，请检查智能体ID是否正确',
  'error.unknown': '通话失败，发生未知错误',

  'avatar.timeLimit': '通话结束，数字人通话仅可以体验5分钟。',

  'humanTakeover.willStart': '当前通话即将被真人接管',
  'humanTakeover.connected': '当前通话已经被真人接管',

  'vision.customCapture.enabled': '已开启自定义截帧送检模式，语音输入将不起作用',
  'vision.customCapture.disabled': '已退出自定义截帧送检模式',

  'speaking.interrupt': '当前讲话已被打断',
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
  [AICallErrorCode.TokenExpired]: i18n['error.tokenExpired'],
  [AICallErrorCode.AgentSubscriptionRequired]: i18n['error.subscriptionRequired'],
  [AICallErrorCode.AgentNotFound]: i18n['error.agentNotFound'],
};

export const getErrorMessage = (errorCode?: number) => {
  if (!errorCode) {
    return i18n['error.unknown'];
  }
  return ErrorCodeMessageMap[errorCode] || i18n['error.unknown'];
};

export default i18n;
