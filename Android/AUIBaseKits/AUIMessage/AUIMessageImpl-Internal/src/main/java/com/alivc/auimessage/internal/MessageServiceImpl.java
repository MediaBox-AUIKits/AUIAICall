package com.alivc.auimessage.internal;

import android.text.TextUtils;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.alibaba.dingpaas.base.DPSConnectionStatus;
import com.alibaba.dingpaas.interaction.ImBroadCastStatistics;
import com.alibaba.dingpaas.interaction.ImCancelMuteAllReq;
import com.alibaba.dingpaas.interaction.ImCancelMuteAllRsp;
import com.alibaba.dingpaas.interaction.ImCreateGroupReq;
import com.alibaba.dingpaas.interaction.ImCreateGroupRsp;
import com.alibaba.dingpaas.interaction.ImGetGroupReq;
import com.alibaba.dingpaas.interaction.ImGetGroupRsp;
import com.alibaba.dingpaas.interaction.ImGetGroupStatisticsReq;
import com.alibaba.dingpaas.interaction.ImGetGroupStatisticsRsp;
import com.alibaba.dingpaas.interaction.ImJoinGroupReq;
import com.alibaba.dingpaas.interaction.ImJoinGroupRsp;
import com.alibaba.dingpaas.interaction.ImLeaveGroupReq;
import com.alibaba.dingpaas.interaction.ImMuteAllReq;
import com.alibaba.dingpaas.interaction.ImMuteAllRsp;
import com.alibaba.dingpaas.interaction.ImSendLikeReq;
import com.alibaba.dingpaas.interaction.ImSendLikeRsp;
import com.alibaba.dingpaas.interaction.ImSendMessageToGroupReq;
import com.alibaba.dingpaas.interaction.ImSendMessageToGroupRsp;
import com.alibaba.dingpaas.interaction.ImSendMessageToGroupUsersReq;
import com.alibaba.dingpaas.interaction.ImSendMessageToGroupUsersRsp;
import com.alivc.auicommon.common.base.base.Consumer;
import com.alivc.auicommon.common.base.base.Function;
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
import com.alivc.auimessage.model.message.JoinGroupMessage;
import com.alivc.auimessage.model.message.LeaveGroupMessage;
import com.alivc.auimessage.model.message.MuteGroupMessage;
import com.alivc.auimessage.model.message.UnMuteGroupMessage;
import com.alivc.auimessage.model.token.IMOldToken;
import com.alivc.auimessage.observable.Observable;
import com.aliyun.aliinteraction.EngineConfig;
import com.aliyun.aliinteraction.IToken;
import com.aliyun.aliinteraction.InteractionEngine;
import com.aliyun.aliinteraction.InteractionService;
import com.aliyun.aliinteraction.TokenAccessor;
import com.aliyun.aliinteraction.base.Callback;
import com.aliyun.aliinteraction.base.Error;
import com.aliyun.aliinteraction.enums.BroadcastType;
import com.aliyun.aliinteraction.listener.OnMessageListener;
import com.aliyun.aliinteraction.listener.SimpleEngineListener;
import com.aliyun.aliinteraction.listener.SimpleMessageListener;
import com.aliyun.aliinteraction.model.CancelMuteGroupModel;
import com.aliyun.aliinteraction.model.CancelMuteUserModel;
import com.aliyun.aliinteraction.model.JoinGroupModel;
import com.aliyun.aliinteraction.model.LeaveGroupModel;
import com.aliyun.aliinteraction.model.LikeModel;
import com.aliyun.aliinteraction.model.Message;
import com.aliyun.aliinteraction.model.MuteGroupModel;
import com.aliyun.aliinteraction.model.MuteUserModel;
import com.aliyun.aliinteraction.model.UserInfo;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * @author puke
 * @version 2023/4/23
 */
@Keep
public class MessageServiceImpl extends Observable<MessageListener> implements MessageService {

    private static final String SPLITTER_TOKEN = "_";

    private static boolean mEngineInitialized = false;

    private final InteractionEngine engine;
    private final InteractionService service;
    private final EngineConfig engineConfig;

    private final OnMessageListener sOnMessageListener = new DefaultMessageListener();
    private InteractionCallback<Void> loginCallback;
    private AUIMessageUserInfo userInfo;

    public MessageServiceImpl() {
        engine = InteractionEngine.instance();
        service = engine.getInteractionService();

        engine.register(new SimpleEngineListener() {
            @Override
            public void onConnectionStatusChanged(DPSConnectionStatus status) {
                if (status == DPSConnectionStatus.CS_AUTHED) {
                    // 登录成功
                    doLoginCallbackOnce(new Consumer<InteractionCallback<Void>>() {
                        @Override
                        public void accept(InteractionCallback<Void> callback) {
                            callback.onSuccess(null);
                        }
                    });
                }
            }

            @Override
            public void onError(final Error error) {
                // 登录失败
                doLoginCallbackOnce(new Consumer<InteractionCallback<Void>>() {
                    @Override
                    public void accept(InteractionCallback<Void> callback) {
                        callback.onError(convertError(error));
                    }
                });
            }
        });

        engineConfig = new EngineConfig();
    }

    @NonNull
    private static Error convertError(final InteractionError interactionError) {
        Error error = new Error(interactionError.code, interactionError.msg);
        error.source = interactionError.source;
        return error;
    }

    @NonNull
    private static InteractionError convertError(final Error error) {
        InteractionError interactionError = new InteractionError(error.code, error.msg);
        interactionError.source = error.source;
        return interactionError;
    }

    private static <T> AUIMessageModel<T> covertMessage(Message<?> message, T data) {
        if (message == null) {
            return null;
        }

        AUIMessageModel<T> messageModel = new AUIMessageModel<>();
        messageModel.id = message.messageId;
        messageModel.groupId = message.groupId;
        messageModel.type = message.type;
        messageModel.data = data;

        UserInfo senderInfo = message.senderInfo;
        if (senderInfo != null) {
            AUIMessageUserInfo userInfo = new AUIMessageUserInfo();
            userInfo.userId = senderInfo.userId;
            userInfo.userNick = senderInfo.userNick;
            userInfo.userAvatar = senderInfo.userAvatar;
            userInfo.userExtension = senderInfo.userExtension;
            messageModel.senderInfo = userInfo;
        }

        return messageModel;
    }

    @Override
    public void setConnectionListener(MessageConnectionListener connectionListener) {

    }

    @Override
    public void setUnImplListener(MessageUnImplListener unImplListener) {

    }

    @Override
    public void setConfig(final AUIMessageConfig config) {
        engineConfig.deviceId = config.deviceId;
        engineConfig.tokenAccessor = new TokenAccessor() {
            @Override
            public void getToken(String userId, final com.aliyun.aliinteraction.base.Callback<IToken> callback) {
                IMOldToken oldToken = config.oldToken;
                if (oldToken == null) {
                    callback.onError(new Error("config token is null."));
                    return;
                }
                if (TextUtils.isEmpty(oldToken.access_token) || TextUtils.isEmpty(oldToken.refresh_token)) {
                    callback.onError(new Error("config token is empty."));
                    return;
                }
                callback.onSuccess(new Token(oldToken.access_token, oldToken.refresh_token));
            }
        };

        // TODO: 兼容IM SDK逻辑，如果在重复init engine，会导致IM SDK抛出错误
        // 在此层兼容，全局默认只调用一次init engine，因为IM Engine全局单例，且没有destroy方法，伴随app生命周期
        // 可能导致的问题：用户退出房间后，不再使用IM功能，但是IM Engine还在后台工作。。
        if (!mEngineInitialized) {
            mEngineInitialized = true;
            engine.init(engineConfig);
        }
    }

    @Override
    public void login(AUIMessageUserInfo userInfo, InteractionCallback<Void> callback) {
        loginCallback = callback;
        this.userInfo = userInfo;
        engine.login(userInfo.userId);
    }

    private void doLoginCallbackOnce(Consumer<InteractionCallback<Void>> consumer) {
        if (loginCallback != null) {
            consumer.accept(loginCallback);
            loginCallback = null;
        }
    }

    @Override
    public void logout(InteractionCallback<Void> callback) {
        loginCallback = null;
        engine.logout(CallbackAdapter.sameType(callback));
    }

    @Override
    public boolean isLogin() {
        return engine.isLogin();
    }

    @Override
    public AUIMessageUserInfo getCurrentUserInfo() {
        return this.userInfo;
    }

    @Override
    public void createGroup(final CreateGroupRequest req, InteractionCallback<CreateGroupResponse> callback) {
        HashMap<String, String> extension = new HashMap<>();
        extension.put("groupName", req.groupName != null ? req.groupName : "");
        extension.put("groupExtension", req.groupExtension);

        ImCreateGroupReq createGroupReq = new ImCreateGroupReq();
        createGroupReq.extension = extension;
        final Function<ImCreateGroupRsp, CreateGroupResponse> responseConverter = new Function<ImCreateGroupRsp, CreateGroupResponse>() {
            @Override
            public CreateGroupResponse apply(ImCreateGroupRsp rsp) {
                CreateGroupResponse createGroupResponse = new CreateGroupResponse();
                createGroupResponse.groupId = rsp.groupId;
                return createGroupResponse;
            }
        };
        // TODO keria 客户反馈，这地方engine.setMessageListener需要从回调里面拿出来，才能在进房时，收到回调并及时更新pv
        service.createGroup(createGroupReq, new CallbackAdapter<ImCreateGroupRsp, CreateGroupResponse>(callback, responseConverter) {
            @Override
            public void onSuccess(ImCreateGroupRsp rsp) {
                super.onSuccess(rsp);
                engine.setMessageListener(rsp.groupId, sOnMessageListener);
            }
        });
    }

    @Override
    public void joinGroup(final JoinGroupRequest req, final InteractionCallback<JoinGroupResponse> callback) {
        ImJoinGroupReq joinGroupReq = new ImJoinGroupReq();
        joinGroupReq.groupId = req.groupId;
        joinGroupReq.userNick = userInfo != null ? userInfo.userNick : "";
        joinGroupReq.broadCastStatistics = true;
        joinGroupReq.broadCastType = BroadcastType.ALL.getValue();
        Function<ImJoinGroupRsp, JoinGroupResponse> responseConverter = new Function<ImJoinGroupRsp, JoinGroupResponse>() {
            @Override
            public JoinGroupResponse apply(ImJoinGroupRsp rsp) {
                return new JoinGroupResponse();
            }
        };
        // TODO keria 客户反馈，这地方engine.setMessageListener需要从回调里面拿出来，才能在进房时，收到回调并及时更新pv
        service.joinGroup(joinGroupReq, new CallbackAdapter<ImJoinGroupRsp, JoinGroupResponse>(callback, responseConverter) {
            @Override
            public void onSuccess(ImJoinGroupRsp rsp) {
                super.onSuccess(rsp);
                engine.setMessageListener(req.groupId, sOnMessageListener);
            }
        });
    }

    @Override
    public void leaveGroup(final LeaveGroupRequest req, final InteractionCallback<LeaveGroupResponse> callback) {
        // TODO: 兼容IM SDK逻辑，如果在logout异步回调内部将群聊回调置空，会导致IM SDK内部NPE崩溃；
        // 在此层兼容，默认调用leaveGroup后，返回leaveGroup成功，不再关心IM SDK内部leaveGroup的异步请求结果。
        // 可能导致的问题：如果退房失败，此时进入其它房间，导致IM SDK内部依然会监听上个房间的消息；
        engine.setMessageListener(req.groupId, null);
        if (callback != null) {
            callback.onSuccess(new LeaveGroupResponse());
        }

        ImLeaveGroupReq leaveGroupReq = new ImLeaveGroupReq();
        leaveGroupReq.groupId = req.groupId;
        leaveGroupReq.broadCastType = BroadcastType.ALL.getValue();
        service.leaveGroup(leaveGroupReq, null);
    }

    @Override
    public void sendMessageToGroup(SendMessageToGroupRequest req, InteractionCallback<SendMessageToGroupResponse> callback) {
        ImSendMessageToGroupReq sendMessageToGroupReq = new ImSendMessageToGroupReq();
        sendMessageToGroupReq.groupId = req.groupId;
        sendMessageToGroupReq.type = req.msgType;
        sendMessageToGroupReq.data = req.data;
        sendMessageToGroupReq.skipAudit = req.skipAudit;
        sendMessageToGroupReq.skipMuteCheck = true;
        service.sendMessageToGroup(sendMessageToGroupReq, new CallbackAdapter<>(callback, new Function<ImSendMessageToGroupRsp, SendMessageToGroupResponse>() {
            @Override
            public SendMessageToGroupResponse apply(ImSendMessageToGroupRsp rsp) {
                SendMessageToGroupResponse response = new SendMessageToGroupResponse();
                response.messageId = rsp.messageId;
                return response;
            }
        }));
    }

    @Override
    public void sendMessageToGroupUser(SendMessageToGroupUserRequest req, InteractionCallback<SendMessageToGroupUserResponse> callback) {
        ImSendMessageToGroupUsersReq sendMessageToGroupUsersReq = new ImSendMessageToGroupUsersReq();
        sendMessageToGroupUsersReq.groupId = req.groupId;
        sendMessageToGroupUsersReq.type = req.msgType;
//        sendMessageToGroupUsersReq.level = MessageLevel.HIGH.value;
        sendMessageToGroupUsersReq.data = req.data;
        sendMessageToGroupUsersReq.skipAudit = req.skipAudit;
        sendMessageToGroupUsersReq.skipMuteCheck = true;

        ArrayList<String> receiverIds = new ArrayList<>();
        receiverIds.add(req.receiverId);
        sendMessageToGroupUsersReq.receiverIdList = receiverIds;
        service.sendMessageToGroupUsers(sendMessageToGroupUsersReq, new CallbackAdapter<>(callback, new Function<ImSendMessageToGroupUsersRsp, SendMessageToGroupUserResponse>() {
            @Override
            public SendMessageToGroupUserResponse apply(ImSendMessageToGroupUsersRsp rsp) {
                SendMessageToGroupUserResponse response = new SendMessageToGroupUserResponse();
                response.messageId = rsp.messageId;
                return response;
            }
        }));
    }

    @Override
    public void getGroupInfo(final GetGroupInfoRequest req, InteractionCallback<GetGroupInfoResponse> callback) {
        ImGetGroupStatisticsReq sendMessageToGroupUsersReq = new ImGetGroupStatisticsReq();
        sendMessageToGroupUsersReq.groupId = req.groupId;
        service.getGroupStatistics(sendMessageToGroupUsersReq, new CallbackAdapter<>(callback, new Function<ImGetGroupStatisticsRsp, GetGroupInfoResponse>() {
            @Override
            public GetGroupInfoResponse apply(ImGetGroupStatisticsRsp rsp) {
                GetGroupInfoResponse response = new GetGroupInfoResponse();
                response.groupId = req.groupId;
                response.onlineCount = rsp.onlineCount;
                return response;
            }
        }));
    }

    @Override
    public void muteGroup(MuteGroupRequest req, final InteractionCallback<GroupMuteStatusResponse> callback) {
        ImMuteAllReq request = new ImMuteAllReq();
        request.groupId = req.groupId;
        request.broadCastType = BroadcastType.ALL.getValue();
        service.muteAll(request, new Callback<ImMuteAllRsp>() {
            @Override
            public void onSuccess(ImMuteAllRsp rsp) {
                if (callback == null) {
                    return;
                }
                if (rsp == null) {
                    callback.onError(new InteractionError("操作失败"));
                    return;
                }
                GroupMuteStatusResponse response = new GroupMuteStatusResponse();
                response.groupId = req.groupId;
                response.isMuteAll = true;
                callback.onSuccess(response);
            }

            @Override
            public void onError(Error error) {
                if (callback == null) {
                    return;
                }
                callback.onError(new InteractionError("全员禁言失败，" + error.msg));
            }
        });
    }

    @Override
    public void cancelMuteGroup(CancelMuteGroupRequest req, final InteractionCallback<GroupMuteStatusResponse> callback) {
        ImCancelMuteAllReq request = new ImCancelMuteAllReq();
        request.groupId = req.groupId;
        request.broadCastType = BroadcastType.ALL.getValue();
        service.cancelMuteAll(request, new Callback<ImCancelMuteAllRsp>() {
            @Override
            public void onSuccess(ImCancelMuteAllRsp rsp) {
                if (callback == null) {
                    return;
                }
                if (rsp == null) {
                    callback.onError(new InteractionError("操作失败"));
                    return;
                }
                GroupMuteStatusResponse response = new GroupMuteStatusResponse();
                response.groupId = req.groupId;
                response.isMuteAll = false;
                callback.onSuccess(response);
            }

            @Override
            public void onError(Error error) {
                if (callback == null) {
                    return;
                }
                callback.onError(new InteractionError("取消全员禁言失败，" + error.msg));
            }
        });
    }

    @Override
    public void queryMuteGroup(GroupMuteStatusRequest req, final InteractionCallback<GroupMuteStatusResponse> callback) {
        ImGetGroupReq request = new ImGetGroupReq();
        request.groupId = req.groupId;
        service.getGroup(request, new Callback<ImGetGroupRsp>() {
            @Override
            public void onSuccess(ImGetGroupRsp rsp) {
                if (callback == null) {
                    return;
                }
                if (rsp == null) {
                    callback.onError(new InteractionError("操作失败"));
                    return;
                }
                GroupMuteStatusResponse response = new GroupMuteStatusResponse();
                response.groupId = rsp.groupId;
                response.isMuteAll = rsp.getIsMuteAll();
                callback.onSuccess(response);
            }

            @Override
            public void onError(Error error) {
                if (callback != null) {
                    callback.onError(new InteractionError(error != null ? error.msg : ""));
                }
            }
        });
    }

    @Override
    public void sendLike(SendLikeRequest req, final InteractionCallback<SendLikeResponse> callback) {
        ImSendLikeReq request = new ImSendLikeReq();
        request.groupId = req.groupId;
        request.count = req.likeCount;
        request.broadCastType = BroadcastType.ALL.getValue();
        service.sendLike(request, new Callback<ImSendLikeRsp>() {
            @Override
            public void onSuccess(ImSendLikeRsp rsp) {
                if (callback == null) {
                    return;
                }
                if (rsp == null) {
                    callback.onError(new InteractionError("操作失败"));
                    return;
                }
                SendLikeResponse response = new SendLikeResponse();
                response.intervalSecond = rsp.intervalSecond;
                response.likeCount = rsp.likeCount;
                callback.onSuccess(response);
            }

            @Override
            public void onError(Error error) {
                if (callback != null) {
                    callback.onError(new InteractionError(error != null ? error.msg : ""));
                }
            }
        });
    }

    @Override
    public Object getNativeEngine() {
        return this.engine;
    }

    @Override
    public AUIMessageServiceImplType getImplType() {
        return AUIMessageServiceImplType.ALIVC;
    }

    private static class CallbackAdapter<T, R> implements Callback<T> {

        final InteractionCallback<R> callback;
        final Function<T, R> converter;

        CallbackAdapter(InteractionCallback<R> callback, Function<T, R> converter) {
            this.callback = callback;
            this.converter = converter;
        }

        static <T> CallbackAdapter<T, T> sameType(InteractionCallback<T> callback) {
            return new CallbackAdapter<>(callback, new Function<T, T>() {
                @Override
                public T apply(T rsp) {
                    return rsp;
                }
            });
        }

        @Override
        public void onSuccess(T rsp) {
            if (callback != null) {
                R response = converter.apply(rsp);
                callback.onSuccess(response);
            }
        }

        @Override
        public void onError(Error error) {
            if (callback != null) {
                callback.onError(convertError(error));
            }
        }
    }

    private static class Token implements IToken {

        final String accessToken;
        final String refreshToken;

        public Token(String accessToken, String refreshToken) {
            this.accessToken = accessToken;
            this.refreshToken = refreshToken;
        }

        @Override
        public String getAccessToken() {
            return accessToken;
        }

        @Override
        public String getRefreshToken() {
            return refreshToken;
        }
    }

    private class DefaultMessageListener extends SimpleMessageListener {
        @Override
        public void onJoinGroup(Message<JoinGroupModel> message) {
            final JoinGroupMessage joinGroupMessage = new JoinGroupMessage();
            joinGroupMessage.userId = message.senderId;
            joinGroupMessage.userNick = message.senderInfo.userNick;
            ImBroadCastStatistics statistics = message.data.statistics;
            if (statistics != null) {
                joinGroupMessage.likeCount = statistics.likeCount;
                joinGroupMessage.pv = statistics.pv;
                joinGroupMessage.uv = statistics.uv;
                joinGroupMessage.onlineCount = statistics.onlineCount;
                joinGroupMessage.isMuteAll = statistics.isMuteAll;
            }
            final AUIMessageModel<JoinGroupMessage> messageModel = covertMessage(message, joinGroupMessage);
            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener listener) {
                    listener.onJoinGroup(messageModel);
                }
            });
        }

        @Override
        public void onLeaveGroup(Message<LeaveGroupModel> message) {
            final LeaveGroupMessage leaveGroupMessage = new LeaveGroupMessage();
            leaveGroupMessage.userId = message.senderId;
            final AUIMessageModel<LeaveGroupMessage> messageModel = covertMessage(message, leaveGroupMessage);
            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener listener) {
                    listener.onLeaveGroup(messageModel);
                }
            });
        }

        @Override
        public void onCustomMessageReceived(Message<String> message) {
            final AUIMessageModel<String> apiMessage = covertMessage(message, message.data);
            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener listener) {
                    listener.onMessageReceived(apiMessage);
                }
            });
        }

        @Override
        public void onMuteGroup(Message<MuteGroupModel> message) {
            super.onMuteGroup(message);
            MuteGroupMessage muteGroupMessage = new MuteGroupMessage();
            final AUIMessageModel<MuteGroupMessage> messageModel = covertMessage(message, muteGroupMessage);
            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener listener) {
                    listener.onMuteGroup(messageModel);
                }
            });
        }

        @Override
        public void onCancelMuteGroup(Message<CancelMuteGroupModel> message) {
            super.onCancelMuteGroup(message);
            UnMuteGroupMessage unMuteGroupMessage = new UnMuteGroupMessage();
            final AUIMessageModel<UnMuteGroupMessage> messageModel = covertMessage(message, unMuteGroupMessage);
            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener listener) {
                    listener.onUnMuteGroup(messageModel);
                }
            });
        }

        @Override
        public void onMuteUser(Message<MuteUserModel> message) {
            super.onMuteUser(message);
        }

        @Override
        public void onCancelMuteUser(Message<CancelMuteUserModel> message) {
            super.onCancelMuteUser(message);
        }

        @Override
        public void onLikeReceived(Message<LikeModel> message) {
            super.onLikeReceived(message);
            final AUIMessageModel<String> apiMessage = covertMessage(message, message.data.toString());
            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener listener) {
                    listener.onMessageReceived(apiMessage);
                }
            });
        }
    }
}
