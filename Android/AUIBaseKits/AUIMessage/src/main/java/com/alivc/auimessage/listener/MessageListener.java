package com.alivc.auimessage.listener;

import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.message.ExitGroupMessage;
import com.alivc.auimessage.model.message.JoinGroupMessage;
import com.alivc.auimessage.model.message.LeaveGroupMessage;
import com.alivc.auimessage.model.message.MuteGroupMessage;
import com.alivc.auimessage.model.message.UnMuteGroupMessage;

/**
 * @author puke
 * @version 2022/8/31
 * @apiNote 消息服务回调监听者接口
 * @brief 对应iOS实现`AUIMessageListenerProtocol`
 */
public interface MessageListener {

    /**
     * 有人加入群组事件
     *
     * @param message 加入群组消息
     */
    void onJoinGroup(AUIMessageModel<JoinGroupMessage> message);

    /**
     * 有人离开群组事件
     *
     * @param message 离开群组消息
     */
    void onLeaveGroup(AUIMessageModel<LeaveGroupMessage> message);

    /**
     * 群组禁言事件
     *
     * @param message 禁言事件消息
     */
    void onMuteGroup(AUIMessageModel<MuteGroupMessage> message);

    /**
     * 群组取消禁言事件
     *
     * @param message 取消禁言事件消息
     */
    void onUnMuteGroup(AUIMessageModel<UnMuteGroupMessage> message);

    /**
     * 收到消息
     */
    void onMessageReceived(AUIMessageModel<String> message);

    /**
     * 被动离开群组
     *
     * @param message 被动离开群组消息
     */
    void onExitedGroup(AUIMessageModel<ExitGroupMessage> message);
}
