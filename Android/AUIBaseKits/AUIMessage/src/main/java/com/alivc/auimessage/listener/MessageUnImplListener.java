package com.alivc.auimessage.listener;

import com.alivc.auimessage.model.lwp.CancelMuteGroupRequest;
import com.alivc.auimessage.model.lwp.GroupMuteStatusRequest;
import com.alivc.auimessage.model.lwp.GroupMuteStatusResponse;
import com.alivc.auimessage.model.lwp.MuteGroupRequest;
import com.alivc.auimessage.model.lwp.SendLikeRequest;
import com.alivc.auimessage.model.lwp.SendLikeResponse;
import com.alivc.auimessage.model.lwp.SendMessageToGroupRequest;

/**
 * @author keria
 * @date 2023/11/8
 * @brief AUIMessage未实现的能力，需要回调到外层供业务APPServer处理的方法
 * @note 对应iOS实现`AUIMessageServiceUnImplDelegate`
 */
public abstract class MessageUnImplListener {

    /**
     * 获取全局禁言状态
     *
     * @param req      全局禁言状态请求
     * @param callback 回调函数
     */
    public abstract void queryMuteAll(GroupMuteStatusRequest req, InteractionCallback<GroupMuteStatusResponse> callback);

    /**
     * 全局禁言
     *
     * @param req      全局禁言请求
     * @param callback 回调函数
     */
    public abstract void muteAll(MuteGroupRequest req, InteractionCallback<GroupMuteStatusResponse> callback);

    /**
     * 取消全局禁言
     *
     * @param req      取消全局禁言请求
     * @param callback 回调函数
     */
    public abstract void cancelMuteAll(CancelMuteGroupRequest req, InteractionCallback<GroupMuteStatusResponse> callback);

    /**
     * 点赞
     *
     * @param req      点赞请求
     * @param callback 回调函数
     */
    public abstract void sendLike(SendLikeRequest req, InteractionCallback<SendLikeResponse> callback);

    /**
     * 发送系统消息
     *
     * @param req      群消息请求
     * @param callback 回调函数
     * @apiNote 当在群禁言时无法跳过禁言检测（即禁言时无法发送消息），且由于业务需要还需要发送群组消息，可以在业务层进行实现（通过服务端接口实现）
     * @apiNote 如果接入模式是RCChatRoom时，需要实现该接口
     */
    public abstract void sendSysMessageToGroup(SendMessageToGroupRequest req, InteractionCallback<String> callback);

}
