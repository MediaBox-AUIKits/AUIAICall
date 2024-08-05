package com.alivc.auicommon.core.base;

/**
 * @author puke
 * @version 2021/7/30
 */
public interface Actions {

    /* 信息面板添加消息 */
    String SHOW_MESSAGE = "ShowMessage";

    /* 进入页面后, 查询消息群组成功回调 */
    String GET_GROUP_STATISTICS_SUCCESS = "GetGroupStatisticsSuccess";

    /* 上麦 */
    String JOIN_LINK_MIC = "JoinLinMic";

    /* 下麦 */
    String LEAVE_LINK_MIC = "LeaveLinkMic";

    /* 被踢下麦 */
    String KICK_LINK_MIC = "KickLinkMic";

    /* 申请上麦 */
    String APPLY_JOIN_LINK_MIC = "ApplyJoinLinMic";

    /* 取消申请上麦 */
    String CANCEL_APPLY_JOIN_LINK_MIC = "CancelApplyJoinLinMic";

    /* 主播同意申请后, 观众拒绝上麦 */
    String REJECT_JOIN_LINK_MIC_WHEN_ANCHOR_AGREE = "RejectJoinLinMicWhenAnchorAgree";

    /* 主播同意申请后, 要上麦但已达到最大人数限制 */
    String JOIN_BUT_MAX_LIMIT_WHEN_ANCHOR_AGREE = "JoinButMaxLimitWhenAnchorAgree";

    /* 主播同意申请后, 查询麦上成员列表失败 */
    String GET_MEMBERS_FAIL_WHEN_ANCHOR_AGREE = "GetMembersFailWhenAnchorAgree";

    /* 点击连麦管理 */
    String LINK_MIC_MANAGE_CLICK = "LinkMicManageClick";

    /* 主播推流成功 */
    String ANCHOR_PUSH_SUCCESS = "AnchorPushSuccess";

    /* 点击美颜 */
    String BEAUTY_CLICKED = "BeautyClicked";

    /* 更新连麦管理计数器 */
    String UPDATE_MANAGE_COUNTER = "UpdateManageCounter";

    /* 显示直播面板 */
    String SHOW_LIVE_MENU = "ShowLiveMenu";

    /* 显示企业聊天面板 */
    String SHOW_ENTERPRISE_CHAT = "ShowEnterpriseChat";

    /* 显示企业简介面板 */
    String SHOW_ENTERPRISE_INTRO = "ShowEnterpriseIntro";

    /* 小屏切换 */
    String CHANGE_SMALL_MODE = "ChangeSmallMode";

    /* 大屏切换 */
    String CHANGE_FULL_MODE = "ChangeFullMode";

    /* 消息提示 */
    String SHOW_MESSAGE_TIPS = "ShowMessageTips";

    /* 进入企业直播间 */
    String ENTER_ENTERPRISE = "EnterEnterprise";

    /* 沉浸式播放 */
    String IMMERSIVE_PLAYER = "ImmersivePlayer";

    /* 回放消息 */
    String PLAYBACK_MESSAGE = "PlayBackMessage";
}
