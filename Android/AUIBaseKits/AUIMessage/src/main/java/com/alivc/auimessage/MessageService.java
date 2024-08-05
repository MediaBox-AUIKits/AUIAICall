package com.alivc.auimessage;

import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.listener.MessageConnectionListener;
import com.alivc.auimessage.listener.MessageListener;
import com.alivc.auimessage.listener.MessageUnImplListener;
import com.alivc.auimessage.model.base.AUIMessageUserInfo;
import com.alivc.auimessage.model.lwp.CancelMuteGroupRequest;
import com.alivc.auimessage.model.lwp.CreateGroupRequest;
import com.alivc.auimessage.model.lwp.CreateGroupResponse;
import com.alivc.auimessage.model.lwp.GetGroupInfoRequest;
import com.alivc.auimessage.model.lwp.GetGroupInfoResponse;
import com.alivc.auimessage.model.lwp.GroupMuteStatusRequest;
import com.alivc.auimessage.model.lwp.GroupMuteStatusResponse;
import com.alivc.auimessage.model.lwp.JoinGroupRequest;
import com.alivc.auimessage.model.lwp.JoinGroupResponse;
import com.alivc.auimessage.model.lwp.LeaveGroupRequest;
import com.alivc.auimessage.model.lwp.LeaveGroupResponse;
import com.alivc.auimessage.model.lwp.MuteGroupRequest;
import com.alivc.auimessage.model.lwp.SendLikeRequest;
import com.alivc.auimessage.model.lwp.SendLikeResponse;
import com.alivc.auimessage.model.lwp.SendMessageToGroupRequest;
import com.alivc.auimessage.model.lwp.SendMessageToGroupResponse;
import com.alivc.auimessage.model.lwp.SendMessageToGroupUserRequest;
import com.alivc.auimessage.model.lwp.SendMessageToGroupUserResponse;
import com.alivc.auimessage.observable.IObservable;

/**
 * @author puke
 * @version 2023/4/19
 */
public interface MessageService extends IObservable<MessageListener> {

    /**
     * 设置连接回调
     *
     * @param connectionListener 连接回调
     */
    void setConnectionListener(MessageConnectionListener connectionListener);

    /**
     * 设置IM SDK无法实现的接口回调
     *
     * @param unImplListener 回调
     */
    void setUnImplListener(MessageUnImplListener unImplListener);

    /**
     * 设置配置
     *
     * @param config 配置参数
     */
    void setConfig(AUIMessageConfig config);

    /**
     * 登录 (支持重复登录和切换账号)
     *
     * @param userInfo 登录的用户ID
     */
    void login(AUIMessageUserInfo userInfo, InteractionCallback<Void> callback);

    /**
     * 登出
     *
     * @param callback 回调函数
     */
    void logout(InteractionCallback<Void> callback);

    /**
     * @return 当前是否登录
     */
    boolean isLogin();

    /**
     * 获取当前登录的用户
     *
     * @return 当前登录的用户
     */
    AUIMessageUserInfo getCurrentUserInfo();

    /**
     * 创建群组
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void createGroup(CreateGroupRequest req, InteractionCallback<CreateGroupResponse> callback);

    /**
     * 加入群组
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void joinGroup(JoinGroupRequest req, InteractionCallback<JoinGroupResponse> callback);

    /**
     * 离开群组
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void leaveGroup(LeaveGroupRequest req, InteractionCallback<LeaveGroupResponse> callback);

    /**
     * 发消息给群组全员
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void sendMessageToGroup(SendMessageToGroupRequest req, InteractionCallback<SendMessageToGroupResponse> callback);

    /**
     * 发消息给群组指定成员
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void sendMessageToGroupUser(SendMessageToGroupUserRequest req, InteractionCallback<SendMessageToGroupUserResponse> callback);

    /**
     * 查询群信息
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void getGroupInfo(GetGroupInfoRequest req, InteractionCallback<GetGroupInfoResponse> callback);

    /**
     * 群组禁言
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void muteGroup(MuteGroupRequest req, InteractionCallback<GroupMuteStatusResponse> callback);

    /**
     * 取消群组禁言
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void cancelMuteGroup(CancelMuteGroupRequest req, InteractionCallback<GroupMuteStatusResponse> callback);

    /**
     * 获取群组禁言状态
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void queryMuteGroup(GroupMuteStatusRequest req, InteractionCallback<GroupMuteStatusResponse> callback);

    /**
     * 点赞
     *
     * @param req      请求实体
     * @param callback 接口回调
     */
    void sendLike(SendLikeRequest req, InteractionCallback<SendLikeResponse> callback);

    /**
     * 获取SDK的操作引擎
     *
     * @return SDK引擎
     */
    Object getNativeEngine();

    /**
     * AUIMessage接口的实现类型
     *
     * @return 实现类型
     */
    AUIMessageServiceImplType getImplType();
}
