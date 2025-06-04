export default {
  login: {
    tokenExpired: '登录态失效，请重新登录！',
    uid: {
      title: '请确定你的UID',
      holder: '这里输入UID，最少8个数字，最多16个数字',
    },
    btn: '确定',
    logging: '登录中...',
    failed: '登录失败',

    agreement: {
      prefix: '我已详细阅读并同意',
      suffix: '',
      userAggreement: '用户协议',
      privacyPolicy: '隐私政策',
      and: '和',
      required: '请先阅读并同意隐私政策',
    },

    phone: {
      title: '手机号码登录',
      holder: '请输入手机号码',
      errorMessage: '请输入正确的手机号码',

      verification: {
        title: '获取短信验证码',
        btn: '发送',
        getting: '获取验证码中...',
        holder: '输入验证码',
        success: '验证码已发送至 {phone}',
        resend: '重新获取验证码',
        wait: '{count}秒',
        failed: '获取短信验证码失败',
        errorMessage: '短信验证码格式不正确',
        exceeded: '获取短信验证码超出限制，请在1小时候后再试',
      },
      captcha: {
        holder: '请输入图片校验码',
        failed: '获取图片校验码失败',
        refresh: '点击图片切换校验码',
        errorMessage: '图片校验码不正确',
      },
    },
  },

  welcome: {
    title: 'AI智能体',
    btn: '开始体验',
    optionsTitle: '配置项',

    options: {
      emotion: {
        title: '情绪音色',
        help: '用于选择智能体的音色是否包含情绪',
        options: {
          unemotional: '不含情绪',
          emotional: '包含情绪',
        },
      },
    },
  },

  system: {
    notSupported: '当前浏览器不支持WebRTC，建议您使用钉钉或微信打开',
    generateByAI: '内容由 AI 生成，仅供参考',
    connecting: '接通中，请稍后',
  },

  agent: {
    voice: '语音通话',
    avatar: '数字人通话',
    vision: '视觉理解通话',
    chatbot: '消息对话',
    video: '视频通话',

    ended: '通话已经结束',
    endedByInactivity: '由于你长时间未进行通话，该通话已经结束',
    endedByAgent: '该通话已经结束',

    receivedCustomMessage: '收到智能体自定义消息：{msg}',
    visionCustomCaptureState: '视觉自定义截图：{enabled}',
    interrupted: '当前讲话已被打断: {reason}',

    voiceprintIgnored: '（声纹）识别到不是常用对话人，暂未响应您的问题',
    aivadIgnored: '（AIVad）识别到不是常用对话人，暂未响应您的问题',
  },

  hero: {
    name: '小云',
  },

  actions: {
    clickToCall: '点击拨打，开始进行通话',
    call: '拨打',
    handup: '挂断',
  },

  resume: {
    title: '音视频自动播放失败',
    content: '请点击“确认”按钮恢复播放',
    btn: '确认',
  },

  subtitleList: {
    btn: '字幕',
  },

  settings: {
    title: '设置',
    mode: {
      title: '通话模式',
      pushToTalk: '对讲机模式',
      natural: '自然对话模式',
    },

    failed: '操作失败了',
    interrupt: {
      title: '智能打断',
      help: '根据声音和环境智能打断AI智能体',
      enabled: '智能打断已开启',
      disabled: '智能打断已关闭',
    },
    voiceId: {
      title: '选择音色',
      help: '切换音色后，AI将在下一次回答中使用新的音色',
      success: '音色切换成功',
    },

    pushToTalk: {
      failed: '打开/关闭对讲机模式失败',
      enabled: '对讲机模式已打开',
      disabled: '对讲机模式已关闭',
      spaceTip: '已开启对讲机模式，长按空格开始讲话，对讲机状态下，麦克风默认开启。',
    },
  },

  pushToTalk: {
    push: '按住讲话',
    releaseToSend: '松开发送',
    tip: '按下按钮后讲话，松开按钮后结束讲话',
    spaceTip: '长按空格，开始讲话',
    tooShort: '按住时间太短，已取消发送',
    canceled: '已取消发送',
  },

  microphone: {
    open: '开麦克风',
    close: '关麦克风',
    closed: '麦克风已关',
    opened: '麦克风已开',
  },

  camera: {
    switch: '镜头翻转',
    open: '开摄像头',
    close: '关摄像头',
    closed: '摄像头已关',
    opened: '摄像头已开',
  },

  status: {
    listeningToStart: '请开始说话',
    listening: '你说，我在听...',
    thinking: '思考中...',
    speaking: '我正在回复中，可以点击“tab”键或说话打断我',
    speakingNoInterrupt: '我正在回复中，可以点击“tab”键打断我',
    interrupted: '当前讲话已被打断',

    mobile: {
      speaking: '我正在回复中，可以轻触屏幕或说话打断我',
      speakingNoInterrupt: '我正在回复中，可以轻触屏幕打断我',
    },
  },

  error: {
    localDeviceException: '通话失败，本地设备出现了错误',
    tokenExpired: '通话失败，当前授权已过期',
    connectionFailed: '通话失败，当前网络连接出现问题',
    kickedByUserReplace: '通话失败，当前用户可能登录了其他设备',
    kickedBySystem: '通话失败，被系统结束通话',
    agentLeaveChannel: '通话失败，智能体停止通话了',
    agentPullFailed: '通话失败，智能体拉流失败',
    agentASRFailed: '第三方ASR服务不可用',
    avatarServiceFailed: '数字人服务不可用',
    avatarRoutesExhausted: '数字人通话火爆，请稍后尝试或先享AI音频通话新体验。',
    subscriptionRequired: '接通失败，请检查您账号是否正确订购套餐',
    agentNotFound: '接通失败，请检查智能体ID是否正确',
    unknown: '通话失败，发生未知错误',
  },

  avatar: {
    timeLimit: '通话结束，数字人通话仅可以体验5分钟。',
  },

  vision: {
    customCapture: {
      enabled: '已开启自定义截帧送检模式，语音输入将不起作用',
      disabled: '已退出自定义截帧送检模式',
    },
  },

  humanTakeover: {
    willStart: '当前通话即将被真人接管',
    connected: '当前通话已经被真人接管',
  },

  share: {
    tokenExpired: 'Token已过期',
    tokenInvalid: '请使用正确的Token',
  },

  issue: {
    title: '问题反馈',
    type: '问题类型',
    requiredTip: '请选择问题类型',
    submit: '提交',
    options: {
      multipleSelected: '(多选)',
      notAvaliable: '功能不可用',
      hasBugs: '可用但有BUG',
      tooSlow: 'AI响应太慢',
      notAccurate: 'AI响应内容不准确',
      quality: '音质/画面有问题',
      other: '其他问题',
      description: '请描述您遇到的其他问题',
      descriptionMax: '问题描述不能超过100个字符',
    },
    result: {
      title: '已提交',
      message: '感谢您的支持，你的反馈Id是：{reqId}',
    },
  },

  common: {
    cancel: '取消',
    confirm: '确定',
    ok: '确定',
    copy: '复制',
    copySuccess: '复制成功',
    copyFailed: '复制失败',
    use: '使用',
    close: '关闭',
    exit: '退出',
    back: '返回',
    delete: '删除',
  },

  chat: {
    connecting: '接通中...',
    disconnected: '连接已断开',

    history: {
      failed: '获取历史消息失败',
      noMore: '没有更多历史消息',

      pullingText: '下拉加载历史消息',
      canReleaseText: '松手加载',
      completeText: '加载完成',
      refreshingText: '加载中...',
    },

    message: {
      copied: '消息已复制',
      copyFailed: '消息复制失败',
      deleteConfirm: '确定删除该消息？',
      deleteHelp: '消息删除后，不可恢复',
      deleteFailed: '删除失败',

      customReceived: '接收到自定义消息：{msg}',

      tableTitle: '表格',
    },

    actions: {
      album: '相册',
      toVoice: '音频通话',
      toAvatar: '数字人通话',
      toVision: '视觉理解通话',
      toVideo: '视频通话',
    },

    send: {
      textHolder: '请输入内容',
      voice: {
        tip: '按住说话',
        releaseToSend: '松开发送，上滑取消',
        releaseToCancel: '松开取消',
        failed: '发送语音消息失败',
        noText: '未识别到文字',
        noPermission: '启动麦克风失败，请检查设备和权限',
        tooShort: '按住时间太短，已取消发送',
      },
    },

    uploader: {
      imageFailed: '上传图片失败',
      notReady: '部分图片上传中或上传失败',

      countLimit: '最多上传 {count} 个文件',
      sizeLimit: '文件大小不能超过 {size}',
      noSVG: '当前不支持SVG文件',
    },

    response: {
      interrupted: '用户终止本次回答',
      reasoninging: '思考中...',
      reasoningCompleted: '思考完成',
      reasoningInterrupted: '思考停止',
    },

    playback: {
      failed: '播放失败',
      generating: '语音朗读生成中',
    },
  },
};
