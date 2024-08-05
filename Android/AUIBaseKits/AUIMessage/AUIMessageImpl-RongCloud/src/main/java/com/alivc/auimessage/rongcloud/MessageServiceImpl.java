package com.alivc.auimessage.rongcloud;

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
import com.alivc.auicommon.common.base.util.ThreadUtil;
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
import com.alivc.auimessage.observable.Observable;

import java.util.List;
import java.util.UUID;

import io.rong.imlib.IRongCoreCallback;
import io.rong.imlib.IRongCoreEnum;
import io.rong.imlib.IRongCoreListener;
import io.rong.imlib.RongCoreClient;
import io.rong.imlib.chatroom.base.RongChatRoomClient;
import io.rong.imlib.listener.OnReceiveMessageWrapperListener;
import io.rong.imlib.model.ChatRoomInfo;
import io.rong.imlib.model.ChatRoomMemberAction;
import io.rong.imlib.model.ChatRoomMemberBanEvent;
import io.rong.imlib.model.ChatRoomMemberBlockEvent;
import io.rong.imlib.model.ChatRoomSyncEvent;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.ReceivedProfile;
import io.rong.message.TextMessage;

/**
 * @author puke
 * @version 2023/4/23
 */
@Keep
public class MessageServiceImpl extends Observable<MessageListener> implements MessageService {

    private static final String TAG = "MessageServiceImpl";
    private static final String SOURCE_ERROR = "rongcloud";

    private MessageConnectionListener mMessageConnectionListener;
    private MessageUnImplListener mMessageUnImplListener;

    private final ConnectionStatusListener sConnectionStatusListener = new ConnectionStatusListener();
    private final ReceiveMessageListener sReceiveMessageListener = new ReceiveMessageListener();
    private final ChatRoomMemberActionListener sChatRoomMemberActionListener = new ChatRoomMemberActionListener();
    private final ChatRoomNotifyEventListener sChatRoomNotifyEventListener = new ChatRoomNotifyEventListener();
    private AUIMessageConfig config;
    private AUIMessageUserInfo userInfo;

    @NonNull
    private static InteractionError generateError(final int errorCode, final String errorMsg) {
        InteractionError error = new InteractionError();
        error.source = SOURCE_ERROR;
        error.code = String.valueOf(errorCode);
        error.msg = errorMsg;
        return error;
    }

    @Override
    public void setConnectionListener(MessageConnectionListener connectionListener) {
        mMessageConnectionListener = connectionListener;
    }

    @Override
    public void setUnImplListener(MessageUnImplListener unImplListener) {
        mMessageUnImplListener = unImplListener;
    }

    @Override
    public void setConfig(AUIMessageConfig config) {
        this.config = config;
        RongCoreClient.init(AppContext.getContext(), RongCloudConsts.APP_KEY, false);
        // 监听连接状态
        RongCoreClient.addConnectionStatusListener(sConnectionStatusListener);
        // 监听消息
        RongCoreClient.addOnReceiveMessageListener(sReceiveMessageListener);
        // 监听进出聊天室
        RongChatRoomClient.setChatRoomMemberListener(sChatRoomMemberActionListener);
        // 监听聊天室事件（SDK 从 5.4.5 版本开始支持 RCChatRoomNotifyEventDelegate 监听器）
        RongChatRoomClient.addChatRoomNotifyEventListener(sChatRoomNotifyEventListener);
    }

    @Override
    public void login(final AUIMessageUserInfo userInfo, final InteractionCallback<Void> callback) {
        Logger.i(TAG, "login, userInfo=" + userInfo);
        if (isLogin()) {
            if (callback != null) {
                callback.onSuccess(null);
            }
            return;
        }

        if (userInfo == null) {
            if (callback != null) {
                callback.onError(generateError(-1, "userInfo is null."));
            }
            return;
        }
        if (TextUtils.isEmpty(userInfo.userId)) {
            if (callback != null) {
                callback.onError(generateError(-1, "userId is empty."));
            }
            return;
        }

        if (config == null || config.oldToken == null || TextUtils.isEmpty(config.oldToken.access_token)) {
            if (callback != null) {
                callback.onError(generateError(-1, "config or token is empty."));
            }
            return;
        }

        this.userInfo = userInfo;
        RongCoreClient.connect(config.oldToken.access_token, new io.rong.imlib.IRongCoreCallback.ConnectCallback() {
            /**
             * 数据库回调
             *
             * @param status 数据库打开状态. DATABASE_OPEN_SUCCESS 数据库打开成功; DATABASE_OPEN_ERROR 数据库打开失败
             */
            @Override
            public void onDatabaseOpened(IRongCoreEnum.DatabaseOpenStatus status) {

            }

            /**
             * 成功回调
             *
             * @param userId 当前用户 ID
             */
            @Override
            public void onSuccess(String userId) {
                if (callback != null) {
                    callback.onSuccess(null);
                }
            }

            /**
             * 错误回调
             *
             * @param errorCode 错误码
             */
            @Override
            public void onError(final IRongCoreEnum.ConnectionErrorCode errorCode) {
                if (callback != null) {
                    callback.onError(generateError(errorCode.getValue(), "connected error."));
                }
            }
        });
    }

    @Override
    public void logout(InteractionCallback<Void> callback) {
        RongCoreClient.removeConnectionStatusListener(sConnectionStatusListener);
        RongCoreClient.removeOnReceiveMessageListener(sReceiveMessageListener);
        RongChatRoomClient.setChatRoomActionListener(null);
        RongChatRoomClient.removeChatRoomNotifyEventListener(sChatRoomNotifyEventListener);

        RongCoreClient.getInstance().disconnect(false);
        if (callback != null) {
            callback.onSuccess(null);
        }
    }

    @Override
    public boolean isLogin() {
        return RongCoreClient.getInstance().getCurrentConnectionStatus()
                == IRongCoreListener.ConnectionStatusListener.ConnectionStatus.CONNECTED;
    }

    @Override
    public AUIMessageUserInfo getCurrentUserInfo() {
        return this.userInfo;
    }

    @Override
    public void createGroup(CreateGroupRequest req, final InteractionCallback<CreateGroupResponse> callback) {
        // 注意：1、聊天室id不存在情况下会进行创建并自动加入
        // 2、聊天室存在自动销毁机制，需要服务端加入保活列表，建议创建聊天室由服务端来做
        final String groupId = UUID.randomUUID().toString();
        RongChatRoomClient.getInstance().joinChatRoom(
                groupId, -1,
                new OperationCallbackAdapter<>(callback, new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            CreateGroupResponse response = new CreateGroupResponse();
                            response.groupId = groupId;
                            callback.onSuccess(response);
                        }
                    }
                }));
    }

    @Override
    public void joinGroup(JoinGroupRequest req, final InteractionCallback<JoinGroupResponse> callback) {
        RongChatRoomClient.getInstance().joinExistChatRoom(
                req.groupId, -1,
                new OperationCallbackAdapter<>(callback, new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            JoinGroupResponse response = new JoinGroupResponse();
                            callback.onSuccess(response);
                        }
                    }
                })
        );
    }

    @Override
    public void leaveGroup(LeaveGroupRequest req, final InteractionCallback<LeaveGroupResponse> callback) {
        String chatroomId = req.groupId;
        RongChatRoomClient.getInstance().quitChatRoom(
                chatroomId,
                new OperationCallbackAdapter<>(callback, new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onSuccess(new LeaveGroupResponse());
                        }
                    }
                })
        );
    }

    @Override
    public void sendMessageToGroup(SendMessageToGroupRequest req, InteractionCallback<SendMessageToGroupResponse> callback) {
        doSendMessage(
                req.groupId, req.msgType, req.data, req.skipAudit, req.groupId, Conversation.ConversationType.CHATROOM, callback,
                new Function<Message, SendMessageToGroupResponse>() {
                    @Override
                    public SendMessageToGroupResponse apply(Message message) {
                        SendMessageToGroupResponse response = new SendMessageToGroupResponse();
                        response.messageId = String.valueOf(message.getMessageId());
                        return response;
                    }
                }
        );
    }

    @Override
    public void sendMessageToGroupUser(SendMessageToGroupUserRequest req, final InteractionCallback<SendMessageToGroupUserResponse> callback) {
        doSendMessage(
                req.groupId, req.msgType, req.data, false, req.receiverId, Conversation.ConversationType.PRIVATE, callback,
                new Function<Message, SendMessageToGroupUserResponse>() {
                    @Override
                    public SendMessageToGroupUserResponse apply(Message message) {
                        SendMessageToGroupUserResponse response = new SendMessageToGroupUserResponse();
                        response.messageId = String.valueOf(message.getMessageId());
                        return response;
                    }
                }
        );
    }

    private <T> void doSendMessage(
            String groupId, int type, String data, boolean skipAudit, String targetId,
            Conversation.ConversationType conversationType,
            final InteractionCallback<T> callback,
            final Function<Message, T> resultConverter
    ) {
        JSONObject body = new JSONObject();
        // 全局点对点，groupId若为空表示全局消息
        body.put("groupId", TextUtils.isEmpty(groupId) ? "" : groupId);
        body.put("nick", userInfo != null ? userInfo.userNick : "");
        body.put("avatar", userInfo != null ? userInfo.userAvatar : "");
        body.put("type", type);
        body.put("data", data);
        body.put("skipAudit", skipAudit);

        String content = body.toJSONString();
        // 构建消息
        TextMessage messageContent = TextMessage.obtain(content);
        Message message = Message.obtain(targetId, conversationType, messageContent);

        // 发送消息
        RongCoreClient.getInstance().sendMessage(message, null, null, new IRongCoreCallback.ISendMessageCallback() {
            @Override
            public void onAttached(Message message) {

            }

            @Override
            public void onSuccess(final Message message) {
                ThreadUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            T result = resultConverter.apply(message);
                            callback.onSuccess(result);
                        }
                    }
                });
            }

            @Override
            public void onError(Message message, final IRongCoreEnum.CoreErrorCode errorCode) {
                ThreadUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onError(generateError(errorCode.code, null));
                        }
                    }
                });
            }
        });
    }

    @Override
    public void getGroupInfo(GetGroupInfoRequest req, final InteractionCallback<GetGroupInfoResponse> callback) {
        final String chatroomId = req.groupId;
        RongChatRoomClient.getInstance().getChatRoomInfo(chatroomId, 0,
                ChatRoomInfo.ChatRoomMemberOrder.RC_CHAT_ROOM_MEMBER_DESC,
                new IRongCoreCallback.ResultCallback<ChatRoomInfo>() {
                    @Override
                    public void onSuccess(final ChatRoomInfo chatRoomInfo) {
                        ThreadUtil.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    GetGroupInfoResponse response = new GetGroupInfoResponse();
                                    response.groupId = chatRoomInfo.getChatRoomId();
                                    response.onlineCount = chatRoomInfo.getTotalMemberCount();
                                    callback.onSuccess(response);
                                }
                            }
                        });
                    }

                    @Override
                    public void onError(final IRongCoreEnum.CoreErrorCode errorCode) {
                        ThreadUtil.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (callback != null) {
                                    callback.onError(generateError(errorCode.code, "get group info error"));
                                }
                            }
                        });
                    }
                }
        );
    }

    @Override
    public void muteGroup(MuteGroupRequest req, InteractionCallback<GroupMuteStatusResponse> callback) {
        if (mMessageUnImplListener != null) {
            mMessageUnImplListener.muteAll(req, callback);
        } else {
            if (callback != null) {
                callback.onError(new InteractionError("unimpl"));
            }
        }
    }

    @Override
    public void cancelMuteGroup(CancelMuteGroupRequest req, InteractionCallback<GroupMuteStatusResponse> callback) {
        if (mMessageUnImplListener != null) {
            mMessageUnImplListener.cancelMuteAll(req, callback);
        } else {
            if (callback != null) {
                callback.onError(new InteractionError("unimpl"));
            }
        }
    }

    @Override
    public void queryMuteGroup(GroupMuteStatusRequest req, InteractionCallback<GroupMuteStatusResponse> callback) {
        if (mMessageUnImplListener != null) {
            mMessageUnImplListener.queryMuteAll(req, callback);
        } else {
            if (callback != null) {
                callback.onError(new InteractionError("unimpl"));
            }
        }
    }

    @Override
    public void sendLike(SendLikeRequest req, InteractionCallback<SendLikeResponse> callback) {
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
        return null;
    }

    @Override
    public AUIMessageServiceImplType getImplType() {
        return AUIMessageServiceImplType.RC_CHAT_ROOM;
    }

    private static class OperationCallbackAdapter<T> extends IRongCoreCallback.OperationCallback {

        final InteractionCallback<T> callback;
        final Runnable successFunc;

        private OperationCallbackAdapter(InteractionCallback<T> callback, Runnable successFunc) {
            this.callback = callback;
            this.successFunc = successFunc;
        }

        @Override
        public void onSuccess() {
            ThreadUtil.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (callback != null) {
                        successFunc.run();
                    }
                }
            });
        }

        @Override
        public void onError(final IRongCoreEnum.CoreErrorCode errorCode) {
            ThreadUtil.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (callback != null) {
                        callback.onError(generateError(errorCode.code, null));
                    }
                }
            });
        }
    }

    private class ConnectionStatusListener implements IRongCoreListener.ConnectionStatusListener {

        @Override
        public void onChanged(ConnectionStatus status) {
            Logger.i(TAG, "ConnectionStatusListener.onChanged, status=" + status);
            if (status == ConnectionStatus.TOKEN_INCORRECT) {
                dispatchOnUiThread(new Consumer<MessageListener>() {
                    @Override
                    public void accept(MessageListener messageListener) {
                        if (mMessageConnectionListener != null) {
                            mMessageConnectionListener.onTokenExpire();
                        }
                    }
                });
            }
        }
    }

    private class ReceiveMessageListener extends OnReceiveMessageWrapperListener {

        @Override
        public void onReceivedMessage(final Message message, ReceivedProfile profile) {
            // 针对接收离线消息时，服务端会将 200 条消息打成一个包发到客户端，客户端对这包数据进行解析。该参数表示每个数据包数据逐条上抛后，还剩余的条数
            int left = profile.getLeft();
            // 消息是否离线消息
            boolean isOffline = profile.isOffline();
            // 是否在服务端还存在未下发的消息包
            boolean hasPackage = profile.hasPackage();

            MessageContent messageContent = message.getContent();
            if (!(messageContent instanceof TextMessage)) {
                return;
            }

            TextMessage textMessage = (TextMessage) messageContent;

            AUIMessageUserInfo senderInfo = new AUIMessageUserInfo();
            senderInfo.userId = message.getSenderUserId();

            final AUIMessageModel<String> messageModel = new AUIMessageModel<>();
            messageModel.id = String.valueOf(message.getMessageId());

            String content = textMessage.getContent();
            try {
                JSONObject jsonObject = JSON.parseObject(content);

                messageModel.type = jsonObject.getIntValue("type");
                messageModel.data = jsonObject.getString("data");
                messageModel.groupId = jsonObject.getString("groupId");
                messageModel.type = jsonObject.getIntValue("type");

                senderInfo.userNick = jsonObject.getString("nick");
                senderInfo.userAvatar = jsonObject.getString("avatar");
            } catch (JSONException e) {
                Logger.e(TAG, "ReceiveMessageListener.onReceivedMessage parse json error", e);
            }

            messageModel.senderInfo = senderInfo;

            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener messageListener) {
                    messageListener.onMessageReceived(messageModel);
                }
            });
        }
    }

    private class ChatRoomMemberActionListener implements RongChatRoomClient.ChatRoomMemberActionListener {

        @Override
        public void onMemberChange(List<ChatRoomMemberAction> actions, final String roomId) {
            for (final ChatRoomMemberAction action : actions) {
                final AUIMessageUserInfo senderUserInfo = new AUIMessageUserInfo();
                senderUserInfo.userId = action.getUserId();

                dispatchOnUiThread(new Consumer<MessageListener>() {
                    @Override
                    public void accept(MessageListener listener) {
                        switch (action.getChatRoomMemberAction()) {
                            case CHAT_ROOM_MEMBER_JOIN: {
                                JoinGroupMessage joinGroupMessage = new JoinGroupMessage();
                                joinGroupMessage.userId = senderUserInfo.userId;

                                AUIMessageModel<JoinGroupMessage> messageModel = new AUIMessageModel<>();
                                messageModel.groupId = roomId;
                                messageModel.senderInfo = senderUserInfo;
                                messageModel.data = joinGroupMessage;

                                listener.onJoinGroup(messageModel);
                                break;
                            }
                            case CHAT_ROOM_MEMBER_QUIT: {
                                LeaveGroupMessage leaveGroupMessage = new LeaveGroupMessage();
                                leaveGroupMessage.userId = senderUserInfo.userId;

                                AUIMessageModel<LeaveGroupMessage> messageModel = new AUIMessageModel<>();
                                messageModel.groupId = roomId;
                                messageModel.senderInfo = senderUserInfo;
                                messageModel.data = leaveGroupMessage;

                                listener.onLeaveGroup(messageModel);
                                break;
                            }
                        }
                    }
                });
            }
        }
    }

    private class ChatRoomNotifyEventListener implements RongChatRoomClient.ChatRoomNotifyEventListener {
        @Override
        public void onChatRoomNotifyMultiLoginSync(ChatRoomSyncEvent event) {

        }

        @Override
        public void onChatRoomNotifyBlock(ChatRoomMemberBlockEvent event) {

        }

        @Override
        public void onChatRoomNotifyBan(final ChatRoomMemberBanEvent event) {
            dispatchOnUiThread(new Consumer<MessageListener>() {
                @Override
                public void accept(MessageListener listener) {
                    if (event == null) {
                        return;
                    }
                    ChatRoomMemberBanEvent.ChatRoomMemberBanType banType = event.getBanType();
                    if (banType == ChatRoomMemberBanEvent.ChatRoomMemberBanType.MuteAll) {
                        AUIMessageModel<MuteGroupMessage> messageModel = new AUIMessageModel<>();
                        messageModel.groupId = event.getChatroomId();
                        messageModel.type = 1004;
                        messageModel.data = new MuteGroupMessage();
                        listener.onMuteGroup(messageModel);
                    } else if (banType == ChatRoomMemberBanEvent.ChatRoomMemberBanType.UnmuteAll) {
                        AUIMessageModel<UnMuteGroupMessage> messageModel = new AUIMessageModel<>();
                        messageModel.groupId = event.getChatroomId();
                        messageModel.type = 1005;
                        messageModel.data = new UnMuteGroupMessage();
                        listener.onUnMuteGroup(messageModel);
                    } else if (banType == ChatRoomMemberBanEvent.ChatRoomMemberBanType.MuteUsers) {
                        // 当前不做点对点禁言
                    } else if (banType == ChatRoomMemberBanEvent.ChatRoomMemberBanType.UnmuteUsers) {
                        // 当前不做点对点禁言
                    }
                }
            });
        }
    }
}
