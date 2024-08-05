package com.alivc.auimessage.alivcim;

import android.text.TextUtils;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONException;
import com.alibaba.fastjson.JSONObject;
import com.alivc.auicommon.common.base.AppContext;
import com.alivc.auicommon.common.base.base.Consumer;
import com.alivc.auicommon.common.base.base.Function;
import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auimessage.AUIMessageConfig;
import com.alivc.auimessage.AUIMessageServiceImplType;
import com.alivc.auimessage.MessageService;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.listener.MessageConnectionListener;
import com.alivc.auimessage.listener.MessageListener;
import com.alivc.auimessage.listener.MessageUnImplListener;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.base.AUIMessageUserInfo;
import com.alivc.auimessage.model.base.InteractionError;
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
import com.alivc.auimessage.model.message.ExitGroupMessage;
import com.alivc.auimessage.model.message.JoinGroupMessage;
import com.alivc.auimessage.model.message.LeaveGroupMessage;
import com.alivc.auimessage.model.message.MuteGroupMessage;
import com.alivc.auimessage.model.message.UnMuteGroupMessage;
import com.alivc.auimessage.model.token.IMNewToken;
import com.alivc.auimessage.observable.Observable;
import com.aliyun.im.AliVCIMEngine;
import com.aliyun.im.AliVCIMGroupInterface;
import com.aliyun.im.AliVCIMInterface;
import com.aliyun.im.AliVCIMMessageInterface;
import com.aliyun.im.common.Error;
import com.aliyun.im.interaction.ImAuth;
import com.aliyun.im.interaction.ImCancelMuteAllReq;
import com.aliyun.im.interaction.ImCreateGroupReq;
import com.aliyun.im.interaction.ImCreateGroupRsp;
import com.aliyun.im.interaction.ImGroupInfo;
import com.aliyun.im.interaction.ImGroupInfoStatus;
import com.aliyun.im.interaction.ImGroupListener;
import com.aliyun.im.interaction.ImGroupMuteStatus;
import com.aliyun.im.interaction.ImJoinGroupReq;
import com.aliyun.im.interaction.ImJoinGroupRsp;
import com.aliyun.im.interaction.ImLeaveGroupReq;
import com.aliyun.im.interaction.ImLogLevel;
import com.aliyun.im.interaction.ImLoginReq;
import com.aliyun.im.interaction.ImMessage;
import com.aliyun.im.interaction.ImMessageLevel;
import com.aliyun.im.interaction.ImMessageListener;
import com.aliyun.im.interaction.ImMuteAllReq;
import com.aliyun.im.interaction.ImQueryGroupReq;
import com.aliyun.im.interaction.ImQueryGroupRsp;
import com.aliyun.im.interaction.ImSdkCallback;
import com.aliyun.im.interaction.ImSdkConfig;
import com.aliyun.im.interaction.ImSdkListener;
import com.aliyun.im.interaction.ImSdkValueCallback;
import com.aliyun.im.interaction.ImSendMessageToGroupReq;
import com.aliyun.im.interaction.ImSendMessageToGroupRsp;
import com.aliyun.im.interaction.ImSendMessageToUserReq;
import com.aliyun.im.interaction.ImSendMessageToUserRsp;
import com.aliyun.im.interaction.ImTokenCallback;
import com.aliyun.im.interaction.ImUser;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * @author keria
 * @date 2023/10/20
 * @brief AliVCIM实现类
 */
@Keep
public class MessageServiceImpl extends Observable<MessageListener> implements MessageService, ImSdkListener, ImGroupListener, ImMessageListener {

    private static final String TAG = "MessageServiceImpl-AliVCIM";

    private static final String MESSAGE_KEY_USER_AVATAR = "userAvatar";
    private static final String MESSAGE_KEY_USER_NICK = "userNick";
    private static final String MESSAGE_KEY_GROUP_ID = "groupId";
    private static final String MESSAGE_KEY_DATA = "data";

    private AliVCIMInterface engine = AliVCIMEngine.instance();
    private AliVCIMMessageInterface messageInterface;
    private AliVCIMGroupInterface groupInterface;

    private AUIMessageConfig mMessageConfig;

    private AUIMessageUserInfo mUserInfo;

    private MessageConnectionListener mMessageConnectionListener;
    private MessageUnImplListener mMessageUnImplListener;

    // 管理当前所在群组的全局禁言状态
    private final HashMap<String, ImGroupMuteStatus> mGroupMuteStatus = new HashMap<>();

    @Override
    public void setConnectionListener(MessageConnectionListener connectionListener) {
        mMessageConnectionListener = connectionListener;
    }

    @Override
    public void setUnImplListener(MessageUnImplListener unImplListener) {
        mMessageUnImplListener = unImplListener;
    }

    /**
     * MessageService
     */

    @Override
    public void setConfig(AUIMessageConfig config) {
        Logger.i(TAG, "[API] setConfig: " + config);

        if (config == null) {
            Logger.e(TAG, "config is null");
            return;
        }

        IMNewToken newToken = config.newToken;
        if (newToken == null) {
            Logger.e(TAG, "config token is null");
            return;
        }

        mMessageConfig = config;
        ImSdkConfig imSdkConfig = new ImSdkConfig();
        imSdkConfig.deviceId = mMessageConfig.deviceId;
        imSdkConfig.appId = newToken.app_id;
        imSdkConfig.appSign = newToken.app_sign;
        imSdkConfig.logLevel = ImLogLevel.DEBUG;

        int ret = engine.init(AppContext.getContext(), imSdkConfig);
        engine.addSdkListener(this);

        messageInterface = engine.getMessageManager();
        groupInterface = engine.getGroupManager();
        messageInterface.addMessageListener(this);
        groupInterface.addGroupListener(this);

        Logger.i(TAG, "setConfig: [end][" + ret + "]");

        if (ret != 0) {
            Logger.w(TAG, "already initialized!");
        }
    }

    @Override
    public void login(AUIMessageUserInfo userInfo, InteractionCallback<Void> callback) {
        Logger.i(TAG, "[API] login: [" + userInfo + "][" + callback + "]");

        if (callback == null) {
            return;
        }

        if (isLogin()) {
            callback.onError(new InteractionError("already logged in!"));
            return;
        }

        IMNewToken newToken = mMessageConfig.newToken;
        if (newToken == null) {
            callback.onError(new InteractionError("token is null or empty!"));
            return;
        }

        if (userInfo == null) {
            callback.onError(new InteractionError("user info is null!"));
            return;
        }
        if (TextUtils.isEmpty(userInfo.userId)) {
            callback.onError(new InteractionError("user id is null or empty!"));
            return;
        }

        mUserInfo = userInfo;

        ImLoginReq loginReq = new ImLoginReq();
        loginReq.user.userId = userInfo.userId;
        Map<String, Object> data = new HashMap<>();
        data.put(MESSAGE_KEY_USER_NICK, userInfo.userNick);
        data.put(MESSAGE_KEY_USER_AVATAR, userInfo.userAvatar);
        loginReq.user.userExtension = JSON.toJSONString(data);

        loginReq.userAuth = new ImAuth(newToken.auth.nonce, newToken.auth.timestamp, newToken.auth.role, newToken.app_token);
        engine.login(loginReq, new ImSdkCallback() {
            @Override
            public void onSuccess() {
                Logger.i(TAG, "[Callback] login onSuccess: ");
                callback.onSuccess(null);
            }

            @Override
            public void onFailure(Error error) {
                Logger.e(TAG, "[Callback] login onFailure: " + error);
                callback.onError(convertError(error));
            }
        });
        Logger.i(TAG, "[API] login: [end]");
    }

    @Override
    public void logout(InteractionCallback<Void> callback) {
        Logger.i(TAG, "[API] logout: ");

        mGroupMuteStatus.clear();

        engine.logout(new ImSdkCallback() {
            @Override
            public void onSuccess() {
                Logger.i(TAG, "[Callback] logout onSuccess: ");
                if (callback != null) {
                    callback.onSuccess(null);
                }
            }

            @Override
            public void onFailure(Error error) {
                Logger.e(TAG, "[Callback] logout onFailure: " + error);
                if (callback != null) {
                    callback.onError(convertError(error));
                }
            }
        });

        messageInterface.removeMessageListener(this);
        groupInterface.removeGroupListener(this);
        engine.removeSdkListener(this);
    }

    @Override
    public boolean isLogin() {
        return engine != null && engine.isLogin();
    }

    @Override
    public AUIMessageUserInfo getCurrentUserInfo() {
        return mUserInfo;
    }

    @Override
    public void createGroup(CreateGroupRequest req, InteractionCallback<CreateGroupResponse> callback) {
        Logger.i(TAG, "[API] createGroup: " + req);

        if (callback == null) {
            return;
        }

        if (!isLogin()) {
            callback.onError(new InteractionError("need login"));
            return;
        }

        ImCreateGroupReq imCreateGroupReq = new ImCreateGroupReq();
        imCreateGroupReq.groupId = TextUtils.isEmpty(req.groupId) ? UUID.randomUUID().toString().toLowerCase() : req.groupId;
        imCreateGroupReq.groupName = TextUtils.isEmpty(req.groupName) ? "default" : req.groupName;
        imCreateGroupReq.groupMeta = TextUtils.isEmpty(req.groupExtension) ? "" : req.groupExtension;

        groupInterface.createGroup(imCreateGroupReq, new ValueCallbackAdapter<>(callback, new Function<ImCreateGroupRsp, CreateGroupResponse>() {
            @Override
            public CreateGroupResponse apply(ImCreateGroupRsp imCreateGroupRsp) {
                CreateGroupResponse createGroupResponse = new CreateGroupResponse();
                createGroupResponse.groupId = imCreateGroupReq.groupId;
                return createGroupResponse;
            }
        }));
    }

    @Override
    public void joinGroup(JoinGroupRequest req, InteractionCallback<JoinGroupResponse> callback) {
        Logger.i(TAG, "[API] joinGroup: " + req);

        if (callback == null) {
            return;
        }

        if (req == null || TextUtils.isEmpty(req.groupId)) {
            callback.onError(new InteractionError("joinGroup failure, invalid req!"));
            return;
        }

        if (!isLogin()) {
            callback.onError(new InteractionError("joinGroup failure, need login!"));
            return;
        }

        ImJoinGroupReq joinGroupReq = new ImJoinGroupReq();
        joinGroupReq.groupId = req.groupId;

        groupInterface.joinGroup(joinGroupReq, new ValueCallbackAdapter<>(callback, new Function<ImJoinGroupRsp, JoinGroupResponse>() {
            @Override
            public JoinGroupResponse apply(ImJoinGroupRsp imJoinGroupRsp) {
                // C++结构体，有初始值，通过JNI一一映射到Java对象，因此无需判空
                mGroupMuteStatus.put(imJoinGroupRsp.groupInfo.groupId, imJoinGroupRsp.groupInfo.muteStatus);

                return new JoinGroupResponse();
            }
        }));
    }

    @Override
    public void leaveGroup(LeaveGroupRequest req, InteractionCallback<LeaveGroupResponse> callback) {
        Logger.i(TAG, "[API] leaveGroup: " + req);

        if (!isLogin()) {
            if (callback != null) {
                callback.onError(new InteractionError("need login!"));
            }
            return;
        }

        ImLeaveGroupReq leaveGroupReq = new ImLeaveGroupReq();
        leaveGroupReq.groupId = req.groupId;

        groupInterface.leaveGroup(leaveGroupReq, new ImSdkCallback() {
            @Override
            public void onSuccess() {
                Logger.i(TAG, "[Callback] leaveGroup onSuccess: " + req.groupId);

                mGroupMuteStatus.remove(req.groupId);

                if (callback != null) {
                    callback.onSuccess(new LeaveGroupResponse());
                }
            }

            @Override
            public void onFailure(Error error) {
                Logger.e(TAG, "[Callback] leaveGroup onFailure: " + req.groupId + ", " + error);
                if (callback != null) {
                    callback.onError(convertError(error));
                }
            }
        });
    }

    @Override
    public void sendMessageToGroup(SendMessageToGroupRequest req, InteractionCallback<SendMessageToGroupResponse> callback) {
        Logger.i(TAG, "[API] sendMessageToGroup: " + req);

        if (!isLogin()) {
            if (callback != null) {
                callback.onError(new InteractionError("need login!"));
            }
            return;
        }

        ImSendMessageToGroupReq sendMessageToGroupReq = new ImSendMessageToGroupReq();
        sendMessageToGroupReq.groupId = req.groupId;
        sendMessageToGroupReq.type = req.msgType;
        sendMessageToGroupReq.level = ImMessageLevel.forValue(req.msgLevel);
        sendMessageToGroupReq.skipMuteCheck = req.skipMuteCheck;
        sendMessageToGroupReq.skipAudit = req.skipAudit;
        sendMessageToGroupReq.data = req.data;
        sendMessageToGroupReq.noStorage = req.noStorage;

        messageInterface.sendGroupMessage(sendMessageToGroupReq, new ValueCallbackAdapter<>(callback, new Function<ImSendMessageToGroupRsp, SendMessageToGroupResponse>() {
            @Override
            public SendMessageToGroupResponse apply(ImSendMessageToGroupRsp imSendMessageToGroupRsp) {
                SendMessageToGroupResponse response = new SendMessageToGroupResponse();
                response.messageId = imSendMessageToGroupRsp.messageId;
                return response;
            }
        }));
    }

    @Override
    public void sendMessageToGroupUser(SendMessageToGroupUserRequest req, InteractionCallback<SendMessageToGroupUserResponse> callback) {
        Logger.i(TAG, "[API] sendMessageToGroupUser: " + req);

        if (!isLogin()) {
            if (callback != null) {
                callback.onError(new InteractionError("need login!"));
            }
            return;
        }

        ImSendMessageToUserReq sendMessageToUserReq = new ImSendMessageToUserReq();
        sendMessageToUserReq.receiverId = req.receiverId;
        sendMessageToUserReq.type = req.msgType;
        sendMessageToUserReq.skipAudit = req.skipAudit;
        sendMessageToUserReq.level = ImMessageLevel.forValue(req.msgLevel);

        HashMap<String, String> sendData = new HashMap<>();
        sendData.put(MESSAGE_KEY_DATA, req.data);
        sendData.put(MESSAGE_KEY_GROUP_ID, req.groupId);
        sendMessageToUserReq.data = JSON.toJSONString(sendData);

        messageInterface.sendC2cMessage(sendMessageToUserReq, new ValueCallbackAdapter<>(callback, new Function<ImSendMessageToUserRsp, SendMessageToGroupUserResponse>() {
            @Override
            public SendMessageToGroupUserResponse apply(ImSendMessageToUserRsp imSendMessageToUserRsp) {
                SendMessageToGroupUserResponse response = new SendMessageToGroupUserResponse();
                response.messageId = imSendMessageToUserRsp.messageId;
                return response;
            }
        }));
    }

    @Override
    public void getGroupInfo(GetGroupInfoRequest req, InteractionCallback<GetGroupInfoResponse> callback) {
        Logger.i(TAG, "[API] getGroupInfo: " + req);

        if (callback == null) {
            return;
        }

        if (!isLogin()) {
            callback.onError(new InteractionError("need login!"));
            return;
        }

        ImQueryGroupReq queryGroupReq = new ImQueryGroupReq();
        queryGroupReq.groupId = req.groupId;

        groupInterface.queryGroup(queryGroupReq, new ValueCallbackAdapter<>(callback, new Function<ImQueryGroupRsp, GetGroupInfoResponse>() {
            @Override
            public GetGroupInfoResponse apply(ImQueryGroupRsp queryGroupRsp) {
                // C++结构体，有初始值，通过JNI一一映射到Java对象，因此无需判空
                mGroupMuteStatus.put(queryGroupRsp.groupInfo.groupId, queryGroupRsp.groupInfo.muteStatus);

                GetGroupInfoResponse getGroupInfoResponse = new GetGroupInfoResponse();
                ImGroupInfo groupInfo = queryGroupRsp.groupInfo;
                getGroupInfoResponse.groupId = groupInfo.groupId;
                getGroupInfoResponse.pv = groupInfo.statistics.pv;
                getGroupInfoResponse.onlineCount = groupInfo.statistics.onlineCount;
                return getGroupInfoResponse;
            }
        }));
    }

    @Override
    public void muteGroup(MuteGroupRequest req, InteractionCallback<GroupMuteStatusResponse> callback) {
        Logger.i(TAG, "[API] muteGroup: " + req);

        if (!isLogin()) {
            if (callback != null) {
                callback.onError(new InteractionError("need login!"));
            }
            return;
        }

        ImMuteAllReq muteAllReq = new ImMuteAllReq();
        muteAllReq.groupId = req.groupId;

        groupInterface.muteAll(muteAllReq, new ImSdkCallback() {
            @Override
            public void onSuccess() {
                Logger.i(TAG, "[Callback] muteGroup onSuccess: ");
                if (callback != null) {
                    GroupMuteStatusResponse response = new GroupMuteStatusResponse();
                    response.groupId = muteAllReq.groupId;
                    response.isMuteAll = true;
                    callback.onSuccess(response);
                }
            }

            @Override
            public void onFailure(Error error) {
                Logger.e(TAG, "[Callback] muteGroup onFailure: " + error);
                if (callback != null) {
                    callback.onError(convertError(error));
                }
            }
        });
    }

    @Override
    public void cancelMuteGroup(CancelMuteGroupRequest req, InteractionCallback<GroupMuteStatusResponse> callback) {
        Logger.i(TAG, "[API] cancelMuteGroup: " + req);

        if (!isLogin()) {
            if (callback != null) {
                callback.onError(new InteractionError("need login!"));
            }
            return;
        }

        ImCancelMuteAllReq cancelMuteAllReq = new ImCancelMuteAllReq();
        cancelMuteAllReq.groupId = req.groupId;

        groupInterface.cancelMuteAll(cancelMuteAllReq, new ImSdkCallback() {
            @Override
            public void onSuccess() {
                Logger.i(TAG, "[Callback] cancelMuteGroup onSuccess: ");
                if (callback != null) {
                    GroupMuteStatusResponse response = new GroupMuteStatusResponse();
                    response.groupId = cancelMuteAllReq.groupId;
                    response.isMuteAll = false;
                    callback.onSuccess(response);
                }
            }

            @Override
            public void onFailure(Error error) {
                Logger.e(TAG, "[Callback] cancelMuteGroup onFailure: " + error);
                if (callback != null) {
                    callback.onError(convertError(error));
                }
            }
        });
    }

    @Override
    public void queryMuteGroup(GroupMuteStatusRequest req, InteractionCallback<GroupMuteStatusResponse> callback) {
        Logger.i(TAG, "[API] queryMuteGroup: " + req);

        if (!isLogin()) {
            if (callback != null) {
                callback.onError(new InteractionError("need login!"));
            }
            return;
        }

        ImQueryGroupReq queryGroupReq = new ImQueryGroupReq();
        queryGroupReq.groupId = req.groupId;
        groupInterface.queryGroup(queryGroupReq, new ValueCallbackAdapter<>(callback, new Function<ImQueryGroupRsp, GroupMuteStatusResponse>() {
            @Override
            public GroupMuteStatusResponse apply(ImQueryGroupRsp queryGroupRsp) {
                // C++结构体，有初始值，通过JNI一一映射到Java对象，因此无需判空
                mGroupMuteStatus.put(queryGroupReq.groupId, queryGroupRsp.groupInfo.muteStatus);

                GroupMuteStatusResponse muteStatusResponse = new GroupMuteStatusResponse();
                muteStatusResponse.groupId = queryGroupRsp.groupInfo.groupId;
                muteStatusResponse.isMuteAll = queryGroupRsp.groupInfo.muteStatus.muteAll;
                return muteStatusResponse;
            }
        }));
    }

    @Override
    public void sendLike(SendLikeRequest req, InteractionCallback<SendLikeResponse> callback) {
        Logger.i(TAG, "[API] sendLike: " + req);

        if (mMessageUnImplListener != null) {
            mMessageUnImplListener.sendLike(req, callback);
        } else {
            if (callback != null) {
                callback.onError(new InteractionError("unimpl"));
            }
        }
    }

    @Override
    public Object getNativeEngine() {
        return engine;
    }

    @Override
    public AUIMessageServiceImplType getImplType() {
        return AUIMessageServiceImplType.ALIVC_IM;
    }

    /***
     * ImSdkListener
     */
    @Override
    public void onConnecting() {
        Logger.i(TAG, "[Callback] onConnecting");
    }

    @Override
    public void onConnectSuccess() {
        Logger.i(TAG, "[Callback] onConnectSuccess");
    }

    @Override
    public void onConnectFailed(Error error) {
        Logger.e(TAG, "[Callback] onConnectFailed: " + error);
    }

    @Override
    public void onDisconnect(int code) {
        Logger.e(TAG, "[Callback] onDisconnect: " + code);
        // IM SDK内部会自动leaveGroup，无需外部再次调用

        // 1:主动退出， 2:被踢出 3：超时等其他原因 4:在其他端上登录
        if (code == 1) {
            return;
        }

        // 向每一个群组发送已退出的消息
        for (Map.Entry<String, ImGroupMuteStatus> entry : mGroupMuteStatus.entrySet()) {
            ExitGroupMessage exitGroupMessage = new ExitGroupMessage();
            exitGroupMessage.groupId = entry.getKey();
            if (code == 2) {
                exitGroupMessage.reason = "Be kicked out";
            } else if (code == 3) {
                exitGroupMessage.reason = "Timeout";
            } else if (code == 4) {
                exitGroupMessage.reason = "Logged on another device";
            } else {
                exitGroupMessage.reason = "Unknown reason";
            }

            AUIMessageModel<ExitGroupMessage> messageModel = new AUIMessageModel<>();
            messageModel.groupId = entry.getKey();
            messageModel.data = exitGroupMessage;

            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener messageListener) {
                    messageListener.onExitedGroup(messageModel);
                }
            });
        }

        mGroupMuteStatus.clear();
    }

    @Override
    public void onTokenExpired(ImTokenCallback callback) {
        Logger.e(TAG, "[Callback] onTokenExpired");
        if (mMessageConnectionListener != null) {
            mMessageConnectionListener.onTokenExpire();
        }
    }

    @Override
    public void onReconnectSuccess(ArrayList<ImGroupInfo> groupStatus) {
        Logger.i(TAG, "[Callback] onReconnectSuccess");
        for (ImGroupInfo imGroupInfo : groupStatus) {
            onMuteChange(imGroupInfo.groupId, imGroupInfo.muteStatus);
        }
    }

    /**
     * ImGroupListener
     */

    @Override
    public void onMemberChange(String groupId, int memberCount, ArrayList<ImUser> joinUsers, ArrayList<ImUser> leaveUsers) {
        Logger.i(TAG, "[Callback] onMemberChange: " + groupId + ", " + memberCount);

        for (ImUser joinUser : joinUsers) {
            Logger.i(TAG, "[Callback] onMemberChange: [join] " + joinUser);

            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener listener) {
                    JoinGroupMessage joinGroupMessage = new JoinGroupMessage();
                    joinGroupMessage.userId = joinUser.userId;
                    joinGroupMessage.onlineCount = memberCount;

                    AUIMessageUserInfo userInfo = new AUIMessageUserInfo();
                    userInfo.userId = joinUser.userId;
                    JSONObject jsonObject = parseUserExtension(joinUser.userExtension);
                    userInfo.userNick = parseJsonObjectWithKey(jsonObject, MESSAGE_KEY_USER_NICK);
                    userInfo.userAvatar = parseJsonObjectWithKey(jsonObject, MESSAGE_KEY_USER_AVATAR);
                    userInfo.userExtension = joinUser.userExtension;

                    AUIMessageModel<JoinGroupMessage> messageModel = new AUIMessageModel<>();
                    messageModel.groupId = groupId;
                    messageModel.senderInfo = userInfo;
                    messageModel.type = 1002;
                    messageModel.data = joinGroupMessage;

                    listener.onJoinGroup(messageModel);
                }
            });
        }

        for (ImUser leaveUser : leaveUsers) {
            Logger.i(TAG, "[Callback] onMemberChange: [leave] " + leaveUser);

            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener listener) {
                    LeaveGroupMessage leaveGroupMessage = new LeaveGroupMessage();
                    leaveGroupMessage.userId = leaveUser.userId;

                    AUIMessageUserInfo userInfo = new AUIMessageUserInfo();
                    userInfo.userId = leaveUser.userId;
                    JSONObject jsonObject = parseUserExtension(leaveUser.userExtension);
                    userInfo.userNick = parseJsonObjectWithKey(jsonObject, MESSAGE_KEY_USER_NICK);
                    userInfo.userAvatar = parseJsonObjectWithKey(jsonObject, MESSAGE_KEY_USER_AVATAR);
                    userInfo.userExtension = leaveUser.userExtension;

                    AUIMessageModel<LeaveGroupMessage> messageModel = new AUIMessageModel<>();
                    messageModel.groupId = groupId;
                    messageModel.senderInfo = userInfo;
                    messageModel.type = 1003;
                    messageModel.data = leaveGroupMessage;

                    listener.onLeaveGroup(messageModel);
                }
            });
        }
    }

    @Override
    public void onExit(String groupId, int reason) {
        Logger.i(TAG, "[Callback] onExit: " + groupId + ", " + reason);

        mGroupMuteStatus.remove(groupId);

        dispatchOnUiThread(new Consumer<MessageListener>() {
            @Override
            public void accept(MessageListener messageListener) {
                ExitGroupMessage exitGroupMessage = new ExitGroupMessage();
                exitGroupMessage.groupId = groupId;

                if (reason == 1) {
                    exitGroupMessage.reason = "Group is disbanded";
                } else if (reason == 2) {
                    exitGroupMessage.reason = "Be kicked out";
                } else {
                    exitGroupMessage.reason = "Unknown reason";
                }

                AUIMessageModel<ExitGroupMessage> messageModel = new AUIMessageModel<>();
                messageModel.groupId = groupId;
                messageModel.data = exitGroupMessage;

                messageListener.onExitedGroup(messageModel);
            }
        });
    }

    @Override
    public void onMuteChange(String groupId, ImGroupMuteStatus status) {
        Logger.i(TAG, "[Callback] onMuteChange: " + groupId + ", " + status);

        ImGroupMuteStatus oldStatus = mGroupMuteStatus.get(groupId);
        if (status.muteAll && (oldStatus == null || !oldStatus.muteAll)) {
            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener messageListener) {
                    AUIMessageModel<MuteGroupMessage> messageModel = new AUIMessageModel<>();
                    messageModel.groupId = groupId;
                    messageModel.type = 1004;
                    messageModel.data = new MuteGroupMessage();
                    messageListener.onMuteGroup(messageModel);
                }
            });
        } else if (!status.muteAll && (oldStatus == null || oldStatus.muteAll)) {
            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener messageListener) {
                    AUIMessageModel<UnMuteGroupMessage> messageModel = new AUIMessageModel<>();
                    messageModel.groupId = groupId;
                    messageModel.type = 1005;
                    messageModel.data = new UnMuteGroupMessage();
                    messageListener.onUnMuteGroup(messageModel);
                }
            });
        }

        mGroupMuteStatus.put(groupId, status);
    }

    @Override
    public void onInfoChange(String groupId, ImGroupInfoStatus info) {
        Logger.i(TAG, "[Callback] onInfoChange: " + groupId + ", " + info);
    }

    /**
     * ImMessageListener
     */

    @Override
    public void onRecvC2cMessage(ImMessage msg) {
        Logger.i(TAG, "[Callback] onRecvC2cMessage: " + msg);

        final AUIMessageModel<String> messageModel = new AUIMessageModel<>();
        messageModel.id = msg.messageId;
        messageModel.groupId = msg.groupId;
        messageModel.msgLevel = msg.level.getValue();
        messageModel.type = msg.type;
        messageModel.data = msg.data;

        if (!TextUtils.isEmpty(msg.data)) {
            try {
                JSONObject dataJson = JSON.parseObject(msg.data);
                if (dataJson != null) {
                    if (dataJson.containsKey(MESSAGE_KEY_GROUP_ID)) {
                        messageModel.groupId = dataJson.getString(MESSAGE_KEY_GROUP_ID);
                    }
                    if (dataJson.containsKey(MESSAGE_KEY_DATA)) {
                        messageModel.data = dataJson.getString(MESSAGE_KEY_DATA);
                    }
                }
            } catch (JSONException e) {
                Logger.e(TAG, "onRecvC2cMessage parse error: ", e);
            }
        }

        AUIMessageUserInfo userInfo = new AUIMessageUserInfo();
        userInfo.userId = msg.sender.userId;
        JSONObject jsonObject = parseUserExtension(msg.sender.userExtension);
        userInfo.userNick = parseJsonObjectWithKey(jsonObject, MESSAGE_KEY_USER_NICK);
        userInfo.userAvatar = parseJsonObjectWithKey(jsonObject, MESSAGE_KEY_USER_AVATAR);
        userInfo.userExtension = msg.sender.userExtension;

        messageModel.senderInfo = userInfo;

        dispatchOnUiThread(new Consumer<MessageListener>() {
            @Override
            public void accept(MessageListener messageListener) {
                messageListener.onMessageReceived(messageModel);
            }
        });
    }

    @Override
    public void onRecvGroupMessage(ImMessage msg, String groupId) {
        Logger.i(TAG, "[Callback] onRecvGroupMessage: " + msg + ", " + groupId);

        final AUIMessageModel<String> messageModel = new AUIMessageModel<>();
        messageModel.id = msg.messageId;
        messageModel.groupId = msg.groupId;
        messageModel.msgLevel = msg.level.getValue();
        messageModel.type = msg.type;
        messageModel.data = msg.data;

        AUIMessageUserInfo userInfo = new AUIMessageUserInfo();
        userInfo.userId = msg.sender.userId;
        JSONObject jsonObject = parseUserExtension(msg.sender.userExtension);
        userInfo.userNick = parseJsonObjectWithKey(jsonObject, MESSAGE_KEY_USER_NICK);
        userInfo.userAvatar = parseJsonObjectWithKey(jsonObject, MESSAGE_KEY_USER_AVATAR);
        userInfo.userExtension = msg.sender.userExtension;

        messageModel.senderInfo = userInfo;

        dispatchOnUiThread(new Consumer<MessageListener>() {
            @Override
            public void accept(MessageListener messageListener) {
                messageListener.onMessageReceived(messageModel);
            }
        });
    }

    @Override
    public void onDeleteGroupMessage(String msgId, String groupId) {
        Logger.i(TAG, "[Callback] onDeleteGroupMessage: " + msgId + ", " + groupId);
    }

    private static class ValueCallbackAdapter<T, R> implements ImSdkValueCallback<T> {

        final InteractionCallback<R> callback;
        final Function<T, R> converter;

        ValueCallbackAdapter(InteractionCallback<R> callback, Function<T, R> converter) {
            this.callback = callback;
            this.converter = converter;
        }

        static <T> ValueCallbackAdapter<T, T> sameType(InteractionCallback<T> callback) {
            return new ValueCallbackAdapter<>(callback, new Function<T, T>() {
                @Override
                public T apply(T rsp) {
                    return rsp;
                }
            });
        }

        @Override
        public void onSuccess(T rsp) {
            Logger.i(TAG, "[Callback] onSuccess: " + rsp);
            if (callback != null) {
                R response = converter.apply(rsp);
                callback.onSuccess(response);
            }
        }

        @Override
        public void onFailure(Error error) {
            Logger.e(TAG, "[Callback] onFailure: " + error);
            if (callback != null) {
                callback.onError(convertError(error));
            }
        }
    }

    @NonNull
    private static InteractionError convertError(Error error) {
        return new InteractionError(String.valueOf(error.code), error.msg);
    }

    private static JSONObject parseUserExtension(String userExtension) {
        if (TextUtils.isEmpty(userExtension)) {
            return null;
        }

        try {
            return JSON.parseObject(userExtension);
        } catch (JSONException e) {
            Logger.e(TAG, "parseUserExtension error: ", e);
        }

        return null;
    }

    private static String parseJsonObjectWithKey(JSONObject jsonObject, String key) {
        if (jsonObject == null) {
            return "";
        }

        if (!jsonObject.containsKey(key)) {
            return "";
        }

        return jsonObject.getString(key);
    }

}
