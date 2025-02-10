package com.aliyun.auikits.aicall;

import static com.aliyun.auikits.aiagent.ARTCAIChatEngine.ARTCAIChatAgentState.Listening;
import static com.aliyun.auikits.aiagent.ARTCAIChatEngine.ARTCAIChatAgentState.Thinking;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_REGION;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_IS_SHARED_AGENT;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_TOKEN_EXPIRE_TIMESTAMP;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.ScrollingMovementMethod;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aiagent.ARTCAIChatEngineImpl;
import com.aliyun.auikits.aiagent.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;
import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.card.CardListAdapter;
import com.aliyun.auikits.aicall.base.card.DefaultCardViewFactory;
import com.aliyun.auikits.aicall.base.feed.ContentViewModel;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.model.ChatBotChatMsgContentModel;
import com.aliyun.auikits.aicall.util.AUIAIChatMessageCacheHelper;
import com.aliyun.auikits.aicall.util.AppServiceConst;
import com.aliyun.auikits.aicall.util.BizStatHelper;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.TimeUtil;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.AICallNoticeDialog;
import com.aliyun.auikits.aicall.widget.AICallReportingDialog;
import com.aliyun.auikits.aicall.widget.AIChatBotSettingDialog;
import com.aliyun.auikits.aicall.widget.PlayMessageAnimationView;
import com.aliyun.auikits.aicall.widget.VoiceInputEditText;
import com.aliyun.auikits.aicall.widget.card.CardTypeDef;
import com.aliyun.auikits.aicall.widget.card.ChatBotReceiveTextMessageCard;
import com.aliyun.auikits.aicall.widget.card.ChatBotSendTextMessageCard;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemChildClickListener;
import com.chad.library.adapter.base.listener.OnItemChildLongClickListener;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;
import com.aliyun.auikits.aicall.bean.ChatBotChatMessage;
import com.scwang.smart.refresh.layout.SmartRefreshLayout;
import com.scwang.smart.refresh.layout.api.RefreshLayout;
import com.scwang.smart.refresh.layout.listener.OnRefreshListener;

import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Route(path = "/aicall/AUIAIChatInChatActivity")
public class AUIAIChatInChatActivity extends AppCompatActivity {


    public enum AUIAIChatType {
        /** 初始状态 */
        Init,
        /** 文本 */
        Text,
        /** 按键语音 */
        Voice
    };

    public enum AUIAIChatPushVoiceAction {
        /** 开始按键语音 */
        Start,
        /** 结束按键语音 */
        Stop,
        /** 上滑 */
        UpperSlip,
        /** 下滑回来*/
        SlipBack

    };

    private LayoutHolder mLayoutHolder = new LayoutHolder();
    private ARTCAIChatEngine mChatEngine = null;
    private String mCurrentRequestId = null;
    private String mAgentId = null;
    private String mUserId = null;
    private String mSessionId = null;
    private String mUserLoginAuthorization = null;
    private boolean mPushingToTalking = false;
    private AUIAIChatType mCurrentChatType = AUIAIChatType.Init;
    private ARTCAIChatEngine.ARTCAIChatAgentState mCurrentAgentState = ARTCAIChatEngine.ARTCAIChatAgentState.Listening;
    protected List<AudioToneData> mAgentVoiceIdList = new ArrayList<AudioToneData>();
    private ARTCAIChatEngine.ARTCAIChatMessagePlayState playState = ARTCAIChatEngine.ARTCAIChatMessagePlayState.Init;

    private Handler mHandler = null;
    private boolean mUIProgressing = false;
    private long mStartPressVoiceMillis = 0;
    private boolean mIsSharedAgent = false;
    private String mAppServer = null;
    private String mAgentRegion = null;
    private long mLastBackButtonExitMillis = 0;
    private ARTCAIChatEngine.ARTCAIChatAgentShareConfig mShareConfig = null;
    private ARTCAICallServiceImpl.AppServerService mAppServerService = null;

    private ARTCAIChatEngine.IARTCAIChatEngineCallback mAIChatEngineCallback = new ARTCAIChatEngine.IARTCAIChatEngineCallback(){

        @Override
        public void onErrorOccurs(ARTCAIChatEngine.ARTCAIChatError error, String requestId) {
            Logger.e("Chat Bot onErrorOccurs: error " + error.errorCode + ", errorMsg "+ error.errorMsg + ", requestId " + requestId);
            mLayoutHolder.onErrorOcuurs(error, requestId);
        }

        @Override
        public void onEngineStateChange(ARTCAIChatEngine.ARTCAIChatEngineState oldState, ARTCAIChatEngine.ARTCAIChatEngineState newState) {
            Logger.i("onEngineStateChange: oldState " + oldState + ", newState " + newState);
            mLayoutHolder.changeConnectionStatusText(newState);
        }

        @Override
        public void onRequestAuthToken(String userId, ARTCAIChatEngine.IARTCAIChatAuthTokenCallback callback) {
            boolean shareBootUseDemoAppServer = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHARE_BOOT_USE_DEMO_APP_SERVER, SettingStorage.DEFAULT_SHARE_BOOT_USE_DEMO_APP_SERVER);
            if(!mIsSharedAgent || shareBootUseDemoAppServer) {
                featchAuthToken(mUserId, new IARTCAICallService.IARTCAICallServiceCallback() {
                    @Override
                    public void onSuccess(JSONObject jsonObject) {
                        ARTCAIChatEngine.ARTCAIChatAuthToken auth = new ARTCAIChatEngine.ARTCAIChatAuthToken(jsonObject);
                        if(auth != null) {
                            callback.onSuccess(auth);
                        }
                    }
                    @Override
                    public void onFail(int errorCode, String errorMsg) {
                        Logger.e("onRequestAuthToken failed: " + errorMsg);}
                });
            }else {
                if(mChatEngine != null) {
                    mChatEngine.generateShareAgentChat(mShareConfig, mUserId, new ARTCAIChatEngine.IARTCAIChatGenerateShareAgentCallback(){
                        @Override
                        public void onSuccess(ARTCAIChatEngine.ARTCAIChatAgentInfo agentInfo, ARTCAIChatEngine.ARTCAIChatAuthToken auth){
                            callback.onSuccess(auth);
                        }

                        @Override
                        public void onFailed(ARTCAIChatEngine.ARTCAIChatError error) {
                            Logger.e("onRequestAuthToken failed: " + error.errorMsg);
                        }
                    });
                }
            }
        }

        @Override
        public void onReceivedMessage(ARTCAIChatEngine.ARTCAIChatMessage message) {
            if(message.messageType == ARTCAIChatEngine.ARTCAIChatMessageType.Text) {
                mLayoutHolder.handleAIChatMessage(message, true);
            }
        }

        @Override
        public void onUserMessageUpdated(ARTCAIChatEngine.ARTCAIChatMessage message) {
            if(message.messageType == ARTCAIChatEngine.ARTCAIChatMessageType.Text) {
                mLayoutHolder.handleAIChatMessage(message, false);
            }
        }

        @Override
        public void onAgentResponseStateChange(ARTCAIChatEngine.ARTCAIChatAgentState agentState, String requestId) {
            mCurrentAgentState = agentState;
            mLayoutHolder.changeChatActionButtonState();
        }

        @Override
        public void onMessagePlayStateChange(ARTCAIChatEngine.ARTCAIChatMessage message, ARTCAIChatEngine.ARTCAIChatMessagePlayState state) {
            Logger.i("onMessagePlayStateChange: " + message.dialogueId + ", state " + state);
            playState = state;
            mLayoutHolder.messagePlayStateChaneged();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(com.chad.library.R.style.Theme_AppCompat_Light_NoActionBar);
        setContentView(R.layout.activity_auiaichat_in_chat);

        mLayoutHolder.init(this);
        mHandler = new Handler();

        findViewById(R.id.btn_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finishChat();
            }
        });

        findViewById(R.id.btn_reporting).setVisibility(
                AICallReportingDialog.AI_CALL_REPORTING_ENABLE ? View.VISIBLE : View.GONE);
        findViewById(R.id.btn_reporting).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AICallReportingDialog.showDialog(AUIAIChatInChatActivity.this, new AICallReportingDialog.IReportingDialogDismissListener() {
                    @Override
                    public void onReportingSubmit(List<Integer> reportTypeStatIdList, String reportIssueDesc) {
                        commitReporting(reportTypeStatIdList, reportIssueDesc);
                    }

                    @Override
                    public void onDismiss(boolean hasSubmit) {
                        if (hasSubmit) {
                            String requestId = mAgentId;
                            String content = getResources().getString(R.string.reporting_id_display, requestId);
                            AICallNoticeDialog.showFunctionalDialog(AUIAIChatInChatActivity.this,
                                    null, false, content, true,
                                    R.string.copy, new AICallNoticeDialog.IActionHandle() {
                                        @Override
                                        public void handleAction() {
                                            copyToClipboard(AUIAIChatInChatActivity.this, requestId);
                                            ToastHelper.showToast(AUIAIChatInChatActivity.this, R.string.chat_bot_copy_text_tips, Toast.LENGTH_SHORT);
                                        }
                                    }
                            );
                        }
                    }
                });
            }
        });

        findViewById(R.id.btn_setting).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getVoiceIdList();
                AIChatBotSettingDialog.show(AUIAIChatInChatActivity.this, mAgentVoiceIdList);
            }
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        if (null != getIntent() && null != getIntent().getExtras()) {
            mAgentRegion = getIntent().getExtras().getString(BUNDLE_KEY_AI_AGENT_REGION, null);
            mAgentId = getIntent().getExtras().getString(BUNDLE_KEY_AI_AGENT_ID, null);
            mIsSharedAgent =  getIntent().getExtras().getBoolean(BUNDLE_KEY_IS_SHARED_AGENT, false);
            mUserId = getIntent().getExtras().getString(BUNDLE_KEY_LOGIN_USER_ID, null);
            mUserLoginAuthorization = getIntent().getExtras().getString(BUNDLE_KEY_LOGIN_AUTHORIZATION, null);
        }

        if(mIsSharedAgent) {
            long expireTimestamp = getIntent().getExtras().getLong(BUNDLE_KEY_TOKEN_EXPIRE_TIMESTAMP, 0);
            mShareConfig = new ARTCAIChatEngine.ARTCAIChatAgentShareConfig(mAgentId, expireTimestamp, mAgentRegion);
        }

        mSessionId = mUserId + "_" +mAgentId;

        boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
        mAppServer = usePreHost ? AppServiceConst.PRE_HOST : AppServiceConst.HOST;
        mAppServerService = new ARTCAICallServiceImpl.AppServerService(mAppServer);

        mChatEngine = new ARTCAIChatEngineImpl(AUIAIChatInChatActivity.this);
        mChatEngine.setEngineCallback(mAIChatEngineCallback);
        mChatEngine.startChat(
                new ARTCAIChatEngine.ARTCAIChatUserInfo(mUserId, ""),
                new ARTCAIChatEngine.ARTCAIChatAgentInfo(mAgentId), mSessionId);
        mLayoutHolder.loadMessageFromCache();
        mLayoutHolder.changeConnectionStatusText(mChatEngine.getEngineState());
    }

    @Override
    public void onBackPressed() {
        long nowMillis = SystemClock.elapsedRealtime();
        long duration = nowMillis - mLastBackButtonExitMillis;
        final long DOUBLE_PRESS_THRESHOLD = 1000;
        if (duration <= DOUBLE_PRESS_THRESHOLD) {
           finishChat();
        } else {
            ToastHelper.showToast(this, R.string.tips_exit, Toast.LENGTH_SHORT);
        }
        mLastBackButtonExitMillis = nowMillis;
    }

    private void finishChat() {
        //如果有多个消息对话的智能体，那么在结束当前对话时，无需进行登出，可以把needLogout设置为false
        boolean needLogout = true;
        if(mChatEngine != null) {
            if(needLogout) {
                mChatEngine.endChat(needLogout);
                mChatEngine.destory();
            } else {
                mChatEngine.endChat(needLogout);
            }
        }
        mLayoutHolder.saveMessage();
        finish();
    }

    private void commitReporting(List<Integer> reportTypeIdList, String otherTypeDesc) {

        if (null == reportTypeIdList || reportTypeIdList.isEmpty()) {
            return;
        }
        try {
            {
                JSONObject args = new JSONObject();
                args.put("req_id", mCurrentRequestId);
                args.put("aid", mAgentId);
                args.put("uid", mUserId);
                args.put("atype", "MessageChat");
                args.put("sid", mSessionId);
                String round = mChatEngine.currentChatRound();
                if(!TextUtils.isEmpty(round)) {
                    args.put("round_type", round);
                }
                args.put("round_req_id", mCurrentRequestId);

                StringBuilder idBuilder = new StringBuilder();
                for (int reportTypeId : reportTypeIdList) {
                    if (idBuilder.length() > 0) {
                        idBuilder.append(",");
                    }
                    idBuilder.append(reportTypeId);
                }
                args.put("rep_type", idBuilder.toString());
                if (!otherTypeDesc.isEmpty()) {
                    args.put("rep_desc", otherTypeDesc);
                }
                BizStatHelper.stat("2001", args.toString());
            }
            {
                JSONObject args = new JSONObject();

                String allLog = Logger.getAllLogRecordStr();
                args.put("log_str", allLog);
                BizStatHelper.stat("2002", args.toString());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private String generateRequsetId() {
       return UUID.randomUUID().toString();
    }

    private void getVoiceIdList() {
        if(mChatEngine != null) {
            List<String> voiceIdList = mChatEngine.getVoiceList();
            for(int i = 0; i < voiceIdList.size(); i++) {
                String voiceId = voiceIdList.get(i);
                AudioToneData audioTone = new AudioToneData(voiceId, voiceId);
                if(i % 3 == 0)
                {
                    audioTone.setIconResId(R.drawable.ic_audio_tone_0);
                } else if(i % 3 == 1) {
                    audioTone.setIconResId(R.drawable.ic_audio_tone_1);
                } else if(i % 3 == 2) {
                    audioTone.setIconResId(R.drawable.ic_audio_tone_2);
                }
                audioTone.setUsing(mChatEngine.getCurrentVoice().equals(audioTone.getAudioToneId()));
                mAgentVoiceIdList.add(audioTone);
            }
        }
    }



    private void featchAuthToken(String userId, IARTCAICallService.IARTCAICallServiceCallback callback) {
        if(mAppServerService != null) {

            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("user_id", mUserId);
                jsonObject.put("expire", 1 * 60 * 60);
                if(!TextUtils.isEmpty(mAgentId)) {
                    jsonObject.put("ai_agent_id", mAgentId);
                }
                if(!TextUtils.isEmpty(mAgentRegion)) {
                    jsonObject.put("region", mAgentRegion);
                }

                mAppServerService.postAsync(mAppServer, "/api/v2/aiagent/generateMessageChatToken", mUserLoginAuthorization, jsonObject, callback);

            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    private class LayoutHolder  {

        private EditText mChatBotEditText;
        private ImageView mChatBotAction;
        private VoiceInputEditText mPresseToPushAction;
        private ImageView mBackToInputAction;

        private CardListAdapter mChatMessageListAdapter;
        private ChatBotChatMsgContentModel mChatBotChatMsgContentModel;
        private ContentViewModel mChatBotMsgViewModel;
        private WeakReference<Context> mContextRef;
        private RecyclerView mChatMessageListView;
        private TextView mConnectStatusTextView;
        private ConstraintLayout mChatInputBar;
        private ConstraintLayout mChatPressVoiceBar;
        private ConstraintLayout mChatBottomBar;
        private LinearLayout mChatPressVoicetalkingLayout;
        private LinearLayout mChatPressVoiceToTalkLayout;
        private TextView mPressVoiceToTalkingTime;
        private TextView mPressVoiceToTalkingTitle;
        private ImageView mPressVoiveToTalkingImg;
        private SmartRefreshLayout mMessageListRefreshLayout;
        private PlayMessageAnimationView mCurrentMessagePlayingAnimationView;
        private ARTCAIChatEngine.ARTCAIChatMessage mCurrentPlayingMessage;
        private Boolean mSkipPlayStoppedMessage = false;
        private ARTCAIChatEngine.ARTCAIChatEngineState mCurrentEngineStatus;
        private Boolean mScrollListByUser = false;
        private Handler autoScrollHandler = new Handler(Looper.getMainLooper());

        private void init(Context context) {

            this.mContextRef = new WeakReference<>(context);
            mChatBotEditText = findViewById(R.id.editTextMessage);
            mChatBotAction = findViewById(R.id.chatbot_action_img);
            mConnectStatusTextView = findViewById(R.id.chatbot_connect_status);
            mPresseToPushAction = findViewById(R.id.press_to_push);
            mChatInputBar = findViewById(R.id.bottom_input_bar);
            mChatPressVoiceBar = findViewById(R.id.bottom_press_voice_bar);
            mBackToInputAction = findViewById(R.id.chatbot_back_to_text_img);
            mChatPressVoicetalkingLayout = findViewById(R.id.bottom_press_voice_talking);
            mChatPressVoiceToTalkLayout = findViewById(R.id.press_voice_to_push_layout);
            mPressVoiceToTalkingTime = findViewById(R.id.bottom_press_voice_timer);
            mPressVoiceToTalkingTitle = findViewById(R.id.bottom_press_voice_title);
            mPressVoiveToTalkingImg = findViewById(R.id.bottom_press_voice_talking_img);
            mChatBottomBar = findViewById(R.id.bottom_bar);
            mMessageListRefreshLayout = findViewById(R.id.srl_chat_message_list);
            mMessageListRefreshLayout.setEnableLoadMore(false);

            mChatBotEditText.setVerticalScrollBarEnabled(true);
            mChatBotEditText.setMovementMethod(new ScrollingMovementMethod());

            mChatBotEditText.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    if (!hasFocus) {  // 当失去焦点时
                        if(TextUtils.isEmpty(mChatBotEditText.getText())) {
                            if(mChatEngine.getCurrentAIChatAgentState() == Listening){
                                mCurrentChatType = AUIAIChatType.Init;
                            } else {
                                mCurrentChatType = AUIAIChatType.Text;
                            }
                        } else {
                            mCurrentChatType = AUIAIChatType.Text;
                        }
                    }
                    else
                    {
                        mCurrentChatType = AUIAIChatType.Text;
                        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                mChatMessageListAdapter.scrollToBottom(mChatMessageListView);
                            }
                        }, 200);

                    }
                    changeChatActionButtonState();
                }
            });

            mChatBotEditText.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    if(!TextUtils.isEmpty(mChatBotEditText.getText())) {
                        mCurrentChatType = AUIAIChatType.Text;
                        changeChatActionButtonState();
                    }
                }
                @Override
                public void afterTextChanged(Editable s) {
                }
            });


            mChatBotAction.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    boolean changeToViocePush = false;
                    String content = mChatBotEditText.getText().toString();
                    if(mCurrentAgentState == Listening ) {
                        if (!TextUtils.isEmpty(content)) {
                            sendMessage(content);
                            mChatBotEditText.setText("");
                            mChatBotEditText.clearFocus();
                            mChatBotAction.setImageResource(R.drawable.ic_chatbot_interrupt_response);
                            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                            imm.hideSoftInputFromWindow(mChatBotEditText.getWindowToken(), 0);
                        } else {
                            if(!mChatBotEditText.hasFocus()) {
                                changeToViocePush = true;
                            }
                        }
                    } else {
                        ARTCAIChatEngine.ARTCAIChatMessage thinkMessage = getCurrentThinkingMessage(mCurrentRequestId);
                        if(mCurrentAgentState == Thinking  || (thinkMessage != null && TextUtils.isEmpty(thinkMessage.text) && thinkMessage.isEnd)) {
                            deleteThinkingResponseMessage(mCurrentRequestId);
                        }
                        mChatEngine.interruptAgentResponse();

                        if(TextUtils.isEmpty(content) && !mChatBotEditText.hasFocus()){
                            mCurrentChatType = AUIAIChatType.Init;
                        }

                        changeChatActionButtonState();
                    }

                    if(changeToViocePush) {
                        mCurrentChatType = AUIAIChatType.Voice;
                        mChatInputBar.setVisibility(View.GONE);
                        mChatPressVoiceBar.setVisibility(View.VISIBLE);

                        changeChatActionButtonState();
                    }
                }
            });

            mPresseToPushAction.setVoiceInputListener(new VoiceInputEditText.VoiceInputListener() {
                @Override
                public void onLongPressStart() {
                    mChatBottomBar.setBackgroundResource(R.drawable.ic_press_voice_to_talking_background);
                    startPushingVoiceMessage();
                    updatePushVoiceUI(AUIAIChatPushVoiceAction.Start);
                    mChatMessageListAdapter.scrollToBottom(mChatMessageListView);
                }
                @Override
                public void onLongPressEnd(boolean isUpperSlip) {
                    mChatBottomBar.setBackground(null);
                    mChatBottomBar.setBackgroundColor(context.getResources().getColor(R.color.layout_base_background));
                    if(isUpperSlip) {
                        cancelPushingVoiceMessage();
                    }
                    else {
                        stopPushingVoiceMessage();
                    }
                    updatePushVoiceUI(AUIAIChatPushVoiceAction.Stop);
                }
                @Override
                public void onUpperSlip() {
                    updatePushVoiceUI(AUIAIChatPushVoiceAction.UpperSlip);
                }

                @Override
                public void onBackSlip() {
                    updatePushVoiceUI(AUIAIChatPushVoiceAction.SlipBack);
                }
            });


            //返回到文本输入
            mBackToInputAction.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(mChatEngine.getCurrentAIChatAgentState() == Listening || mCurrentEngineStatus != ARTCAIChatEngine.ARTCAIChatEngineState.Connected) {
                        mCurrentChatType = AUIAIChatType.Init;
                        mChatInputBar.setVisibility(View.VISIBLE);
                        mChatPressVoiceBar.setVisibility(View.GONE);
                    } else {
                        if(mChatEngine.getCurrentAIChatAgentState() == Thinking) {
                            deleteThinkingResponseMessage(mCurrentRequestId);
                        }
                        mChatEngine.interruptAgentResponse();
                    }
                }
            });


            mMessageListRefreshLayout.setOnRefreshListener(new OnRefreshListener() {
                @Override
                public void onRefresh(@NonNull RefreshLayout refreshLayout) {
                    featchHistoryMessage(true);
                }
            });

            initChatMessageList();
        }

        private void saveMessage() {
            List<ARTCAIChatEngine.ARTCAIChatMessage> messages = new ArrayList<>();
            int count = mChatMessageListAdapter.getItemCount();
            for (int i = count -1 ; i >= 0 ; i--) {

                CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(i);
                if(cardEntity != null && cardEntity.bizData != null) {
                    ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                    ARTCAIChatEngine.ARTCAIChatMessage message = uiMessage.getMessage();
                    if(message != null) {
                        messages.add(message);
                    }
                    if(messages.size() >= 10) {
                        break;
                    }
                }
            }
            AUIAIChatMessageCacheHelper.saveMessage(mSessionId, messages);
        }

        private void updatePushVoiceUI(AUIAIChatPushVoiceAction action) {

            switch (action) {
                case Start:
                    mChatPressVoicetalkingLayout.setVisibility(View.VISIBLE);
                    mBackToInputAction.setVisibility(View.GONE);
                    mPresseToPushAction.setText("");
                    mChatPressVoiceToTalkLayout.setBackground(null);
                    mPressVoiceToTalkingTime.setTextColor(Color.parseColor("#FCFCFD"));
                    mPressVoiceToTalkingTitle.setTextColor(Color.parseColor("#B2B7C4"));
                    mPressVoiceToTalkingTitle.setText(R.string.chat_bot_press_to_talk_title);
                    mPressVoiveToTalkingImg.setImageResource(R.drawable.ic_press_voice_talking);
                    break;
                case Stop:
                    mChatPressVoicetalkingLayout.setVisibility(View.GONE);
                    mBackToInputAction.setVisibility(View.VISIBLE);
                    mPresseToPushAction.setText(R.string.chat_bot_press_to_talk);
                    mChatPressVoiceToTalkLayout.setBackgroundResource(R.drawable.layout_chat_msg_input_bg);
                    mPressVoiceToTalkingTime.setTextColor(Color.parseColor("#FCFCFD"));
                    mPressVoiceToTalkingTime.setText("00:00");
                    mPressVoiceToTalkingTitle.setTextColor(Color.parseColor("#B2B7C4"));
                    mPressVoiceToTalkingTitle.setText(R.string.chat_bot_press_to_talk_title);
                    break;
                case UpperSlip:
                    mPressVoiceToTalkingTime.setTextColor(Color.parseColor("#F95353"));
                    mPressVoiceToTalkingTitle.setTextColor(Color.parseColor("#F95353"));
                    mPressVoiceToTalkingTitle.setText(R.string.chat_bot_press_to_talk_title_cancel);
                    mPressVoiveToTalkingImg.setImageResource(R.drawable.ic_press_voice_finish);
                    break;
                case SlipBack:
                    mPressVoiceToTalkingTime.setTextColor(Color.parseColor("#FCFCFD"));
                    mPressVoiceToTalkingTitle.setTextColor(Color.parseColor("#B2B7C4"));
                    mPressVoiveToTalkingImg.setImageResource(R.drawable.ic_press_voice_talking);
                    mPressVoiceToTalkingTitle.setText(R.string.chat_bot_press_to_talk_title);
                    break;
            }
        }

        private void startUIUpdateProgress() {
            mUIProgressing = true;
            mStartPressVoiceMillis = SystemClock.elapsedRealtime();
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    updateProgressUI();
                }
            });
        }

        private void updateProgressUI() {
            if (mUIProgressing) {
                boolean hasNextRun = true;
                // 更新通话时长
                long duration = mStartPressVoiceMillis > 0 ? SystemClock.elapsedRealtime() - mStartPressVoiceMillis : 0;
                mPressVoiceToTalkingTime.setText(TimeUtil.formatDuration(duration));

                // 数字人体验超过3分钟，自动结束
                if (duration > 3 * 60 * 1000) {
                    cancelPushingVoiceMessage();
                    stopUIUpdateProgress();
                    updatePushVoiceUI(AUIAIChatPushVoiceAction.Stop);
                    AICallNoticeDialog.showDialog(AUIAIChatInChatActivity.this,
                            0, false, R.string.chat_bot_press_to_talk_over_time, true, new OnDismissListener() {
                                @Override
                                public void onDismiss(DialogPlus dialog) {
                                }
                            });
                    hasNextRun = false;
                }

                if (hasNextRun) {
                    mHandler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            updateProgressUI();
                        }
                    }, 500);
                }
            }
        }

        private void stopUIUpdateProgress() {
            mUIProgressing = false;
        }

        private void changeChatActionButtonState() {
            if(mCurrentAgentState != Listening) {
                if(mCurrentChatType == AUIAIChatType.Text || mCurrentChatType == AUIAIChatType.Init) {
                    mChatBotAction.setImageResource(R.drawable.ic_chatbot_interrupt_response);
                } else if(mCurrentChatType == AUIAIChatType.Voice) {
                    mBackToInputAction.setImageResource(R.drawable.ic_chatbot_interrupt_response);
                    mPresseToPushAction.setTextColor(Color.parseColor("#9E9E9E"));
                    mPresseToPushAction.setEnabled(false);
                }
            } else {
                if((mCurrentChatType == AUIAIChatType.Text) && ( mChatBotEditText.hasFocus() || mChatBotEditText.getText().length() > 0)) {
                    mChatBotAction.setImageResource(R.drawable.ic_chat_bot_text_message_send);
                } else if(mCurrentChatType == AUIAIChatType.Voice) {
                    mBackToInputAction.setImageResource(R.drawable.ic_chatbot_back_to_text);
                    mPresseToPushAction.setTextColor(Color.parseColor("#FCFCFD"));
                    mPresseToPushAction.setEnabled(true);
                    mChatBotAction.setImageResource(R.drawable.ic_chatbot_push_voice);
                } else {
                    mChatBotAction.setImageResource(R.drawable.ic_chatbot_push_voice);
                }
            }
        }

        private void changeConnectionStatusText(ARTCAIChatEngine.ARTCAIChatEngineState state) {
            String connectStatusText = "";
            switch (state){
                case Init:
                    connectStatusText = getString(R.string.chat_bot_connect_init_status);
                    break;
                case Connecting:
                    connectStatusText = getString(R.string.chat_bot_connecting_status);
                    break;
                case Disconnected:
                    connectStatusText = getString(R.string.chat_bot_disconnect_status);
                    break;
                case ConnectFailed:
                    connectStatusText = getString(R.string.chat_bot_connect_failed_status);
                    break;
            }

            mConnectStatusTextView.setText(connectStatusText);
            mCurrentEngineStatus = state;
        }

        private void onErrorOcuurs(ARTCAIChatEngine.ARTCAIChatError error, String requestId) {

            int contentResource = R.string.chat_bot_error;
            boolean shoudShowErrorDialog = true;
            if(error.errorCode == ARTCAIChatEngine.ARTCAIChatErrorCode.AgentNotFound.ordinal()) {
                contentResource = R.string.chat_bot_error_agent_not_found;
            } else if(error.errorCode == ARTCAIChatEngine.ARTCAIChatErrorCode.KickedOutBySystem.ordinal()) {
                contentResource = R.string.chat_bot_error_kick_by_system;
            } else if(error.errorCode == ARTCAIChatEngine.ARTCAIChatErrorCode.KickedByUserReplace.ordinal()){
                contentResource = R.string.chat_bot_error_kick_by_user_replace;
            } else {
                shoudShowErrorDialog = false;
            }

            if(shoudShowErrorDialog) {
                AICallNoticeDialog.showDialog(AUIAIChatInChatActivity.this,
                        0, false, contentResource, true, new OnDismissListener() {
                            @Override
                            public void onDismiss(DialogPlus dialog) {
                                finishChat();
                            }
                        }
                );
            } else {
                if(error.errorCode == ARTCAIChatEngine.ARTCAIChatErrorCode.AgentError.ordinal()) {
                    ToastHelper.showToast(mContextRef.get(), error.errorMsg, Toast.LENGTH_SHORT);
                }
            }
        }

        private void insertMessageToMessageList(ARTCAIChatEngine.ARTCAIChatMessage sendMessage, boolean insertToHeader, boolean shouldScroll) {
            if(sendMessage.messageType == ARTCAIChatEngine.ARTCAIChatMessageType.Text) {

                ChatBotChatMessage message = new ChatBotChatMessage(sendMessage);
                message.setAIResponse(sendMessage.senderId.equals(mChatEngine.getAgentInfo().agentId));
                if(!insertToHeader) {
                    mChatBotChatMsgContentModel.AddChatMsg(message, mChatMessageListAdapter.getItemCount());
                } else {
                    mChatBotChatMsgContentModel.AddChatMsgFromHeader(message);
                }

                if(shouldScroll) {
                    mChatMessageListAdapter.notifyItemInserted(mChatMessageListAdapter.getItemCount());
                }

                if(!insertToHeader && shouldScroll) {
                    mChatMessageListAdapter.smoothScrollToBottom(mChatMessageListView, true);
                }
            }
        }

        private void loadMessageFromCache() {

            List<ARTCAIChatEngine.ARTCAIChatMessage> messages = AUIAIChatMessageCacheHelper.loadMessage(mSessionId);
            if(messages != null) {
                for (int i = messages.size() - 1; i >= 0; i--) {
                    insertMessageToMessageList(messages.get(i), false, false);
                }
                mChatMessageListAdapter.scrollToBottom(mChatMessageListView);
            }
        }

        private void featchHistoryMessage(boolean isDescOrder) {

            long endTime = System.currentTimeMillis() / 1000;
            if(mChatMessageListAdapter.getItemCount() > 0) {
                CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(0);
                if(cardEntity != null && cardEntity.bizData != null) {
                    ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                    ARTCAIChatEngine.ARTCAIChatMessage message = uiMessage.getMessage();
                    if(message.sendTime > 0 ) {
                        endTime = message.sendTime - 1;
                    }
                }
            }

            ARTCAIChatEngine.ARTCAIChatMessageListRequest messageListRequest =
                    new ARTCAIChatEngine.ARTCAIChatMessageListRequest(0, endTime, 1, 10, isDescOrder);
            mChatEngine.queryMessageList(messageListRequest, new ARTCAIChatEngine.IARTCAIChatHistoryMessageCallback() {
                @Override
                public void onSuccess(List<ARTCAIChatEngine.ARTCAIChatMessage> data) {

                    for(ARTCAIChatEngine.ARTCAIChatMessage message : data) {
                        insertMessageToMessageList(message, isDescOrder, false);
                    }

                    if(isDescOrder) {
                        mMessageListRefreshLayout.finishRefresh();
                    }
                }
                @Override
                public void onFailed(ARTCAIChatEngine.ARTCAIChatError error) {
                    Logger.e("queryMessageList failed, errorCode: " + error.errorCode + ", errorMsg: " + error.errorMsg);
                    mMessageListRefreshLayout.finishRefresh();
                }
            });
        }

        private void sendMessage(String content) {
            String requestId = generateRequsetId();
            mCurrentRequestId = requestId;
            ARTCAIChatEngine.ARTCAIChatMessage sendMessage = new ARTCAIChatEngine.ARTCAIChatMessage(requestId, content);
            sendMessage.messageState = ARTCAIChatEngine.ARTCAIChatMessageState.Init;
            sendMessage.messageType = ARTCAIChatEngine.ARTCAIChatMessageType.Text;
            insertMessageToMessageList(sendMessage, false, true);
            sendMessageInternal(sendMessage);
        }


        private void sendMessageInternal(ARTCAIChatEngine.ARTCAIChatMessage message) {

            mChatEngine.sendMessage(new ARTCAIChatEngine.ARTCAIChatSendMessageRequest(message.requestId, ARTCAIChatEngine.ARTCAIChatMessageType.Text, message.text), new ARTCAIChatEngine.IARTCAIChatMessageCallback() {
                @Override
                public void onSuccess(ARTCAIChatEngine.ARTCAIChatMessage data) {
                    int pos = mChatBotChatMsgContentModel.getPositionByRequestId(data.requestId, false);
                    if(pos >= 0 && pos < mChatMessageListAdapter.getItemCount()) {
                        CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(pos);
                        if(cardEntity != null && cardEntity.bizData != null) {
                            ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                            uiMessage.setMessage(data);
                            mChatBotChatMsgContentModel.updateContent(cardEntity, pos);
                        }
                    }
                }
                @Override
                public void onFailure(ARTCAIChatEngine.ARTCAIChatMessage data, ARTCAIChatEngine.ARTCAIChatError error) {
                    int pos = mChatBotChatMsgContentModel.getPositionByRequestId(data.requestId, false);
                    if(pos >= 0 && pos < mChatMessageListAdapter.getItemCount()) {
                        CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(pos);
                        if(cardEntity != null && cardEntity.bizData != null) {
                            ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                            uiMessage.setMessage(data);
                            mChatBotChatMsgContentModel.updateContent(cardEntity, pos);
                        }
                    }
                }
            });
        }
        private void handleAIChatMessage(ARTCAIChatEngine.ARTCAIChatMessage chatMessage, boolean isAgentResponse) {
            mChatMessageListAdapter.setAutoScrollToBottom(!mScrollListByUser);
            int pos = mChatBotChatMsgContentModel.getPositionByRequestId(chatMessage.requestId, isAgentResponse);
            boolean notifyChangedInstead = false;
            if(pos >= 0 && pos < mChatMessageListAdapter.getItemCount()) {
                if(chatMessage.messageState != ARTCAIChatEngine.ARTCAIChatMessageState.Failed) {
                    if(!TextUtils.isEmpty(chatMessage.text)) {
                        CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(pos);
                        if(cardEntity != null) {
                            ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                            uiMessage.setAIResponse(isAgentResponse);
                            uiMessage.setMessage(chatMessage);
                            mChatBotChatMsgContentModel.updateContent(cardEntity, pos);
                            notifyChangedInstead = true;
                        }
                    }
                    else {
                        if(chatMessage.messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Finished || chatMessage.messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Interrupted) {
                            deleteThinkingResponseMessage(chatMessage.requestId);
                        }
                    }

                }else {
                    deleteThinkingResponseMessage(chatMessage.requestId);
                }
            }
            else {
                insertMessageToMessageList(chatMessage, false, true);
            }

            if(notifyChangedInstead) {
                mChatMessageListAdapter.notifyItemChanged(pos);
            }else {
                mChatMessageListAdapter.notifyItemInserted(mChatMessageListAdapter.getItemCount());
            }
        }

        private void deleteThinkingResponseMessage(String requestId) {
            int pos = mChatBotChatMsgContentModel.getPositionByRequestId(requestId, true);
            deleteMessage(pos);
        }

        private ARTCAIChatEngine.ARTCAIChatMessage getCurrentThinkingMessage(String requestId) {
            int pos = mChatBotChatMsgContentModel.getPositionByRequestId(requestId, true);
            if(pos >= 0 && pos < mChatMessageListAdapter.getItemCount()) {
                CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(pos);
                if(cardEntity != null && cardEntity.bizData != null) {
                    ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                    ARTCAIChatEngine.ARTCAIChatMessage message = uiMessage.getMessage();
                    return message;
                }
            }
            return null;
        }

        private void messagePlayStateChaneged() {
            if(mCurrentMessagePlayingAnimationView != null) {
                if(playState == ARTCAIChatEngine.ARTCAIChatMessagePlayState.Playing) {
                    mCurrentMessagePlayingAnimationView.startAnimation();
                } else if (playState == ARTCAIChatEngine.ARTCAIChatMessagePlayState.Stopped || playState == ARTCAIChatEngine.ARTCAIChatMessagePlayState.Failed){
                    if(!mSkipPlayStoppedMessage) {
                        mCurrentMessagePlayingAnimationView.stopAnimation();
                        mCurrentMessagePlayingAnimationView = null;
                        mCurrentPlayingMessage = null;
                    } else {
                        mCurrentMessagePlayingAnimationView.stopAnimation();
                        mSkipPlayStoppedMessage = false;
                    }
                }
            }
        }

        private void startPlayingMessage(ARTCAIChatEngine.ARTCAIChatMessage message, String voiceId, PlayMessageAnimationView animationView) {

            boolean shouldStartPlay = true;
            if(mCurrentPlayingMessage == null) {
                mCurrentPlayingMessage = message;
                mCurrentMessagePlayingAnimationView = animationView;
            } else {
                if(mCurrentPlayingMessage.dialogueId.equals(message.dialogueId) && playState == ARTCAIChatEngine.ARTCAIChatMessagePlayState.Playing){
                    mChatEngine.stopPlayMessage();
                    shouldStartPlay = false;
                } else {
                    mChatEngine.stopPlayMessage();
                    mCurrentPlayingMessage = message;
                }
                mCurrentMessagePlayingAnimationView.stopAnimation();
                mCurrentMessagePlayingAnimationView = animationView;
                mSkipPlayStoppedMessage = true;
            }
            if(shouldStartPlay) {
                ToastHelper.showToast(mContextRef.get(), R.string.chat_bot_play_text_tips, Toast.LENGTH_SHORT);
                mChatEngine.startPlayMessage(message, voiceId, new ARTCAIChatEngine.IARTCAIChatMessageCallback() {
                    @Override
                    public void onSuccess(ARTCAIChatEngine.ARTCAIChatMessage data) {
                        Logger.i("startPlayMessage success");

                    }
                    @Override
                    public void onFailure(ARTCAIChatEngine.ARTCAIChatMessage data, ARTCAIChatEngine.ARTCAIChatError error) {
                        Logger.e("startPlayMessage failed  error.errorCode: " + error.errorCode + ", error.errorMsg" + error.errorMsg);

                    }
                });
            }
        }

        private void startPushingVoiceMessage() {
            String requestId = generateRequsetId();
            mCurrentRequestId = requestId;
            mPushingToTalking = true;
            mChatEngine.startPushVoiceMessage(new ARTCAIChatEngine.ARTCAIChatSendMessageRequest(mCurrentRequestId, ARTCAIChatEngine.ARTCAIChatMessageType.Voice, ""));
            startUIUpdateProgress();
        }
        private void stopPushingVoiceMessage() {
            mPushingToTalking = false;
            mChatEngine.finishPushVoiceMessage(new ARTCAIChatEngine.IARTCAIChatMessageCallback() {
                @Override
                public void onSuccess(ARTCAIChatEngine.ARTCAIChatMessage data) {
                    if(!TextUtils.isEmpty(data.text)) {
                        insertMessageToMessageList(data, false, true);
                    } else {
                        ToastHelper.showToast(AUIAIChatInChatActivity.this, R.string.chat_bot_press_to_talk_asr_null, Toast.LENGTH_SHORT);
                    }
                }
            });
            stopUIUpdateProgress();
        }

        private void cancelPushingVoiceMessage() {
            mChatEngine.cancelPushVoiceMessage();
            stopUIUpdateProgress();
        }

        private void stopPlayingMessage(ARTCAIChatEngine.ARTCAIChatMessage message) {
            mChatEngine.stopPlayMessage();
        }

        private void resetEditTextFocusIfNeed() {
            if (mChatBotEditText.hasFocus()) {
                mChatBotEditText.clearFocus();
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(mChatBotEditText.getWindowToken(), 0);
            }
        }


        private void initChatMessageList() {
            mChatMessageListView = findViewById(R.id.chatbot_message_list);
            DefaultCardViewFactory factory = new DefaultCardViewFactory();
            factory.registerCardView(CardTypeDef.CHATBOT_SEND_TEXT_MESSAGE_CARD, ChatBotSendTextMessageCard.class);
            factory.registerCardView(CardTypeDef.CHATBOT_RECEIVE_TEXT_MESSAGE_CARD, ChatBotReceiveTextMessageCard.class);
            mChatMessageListAdapter = new CardListAdapter(factory);
            mChatMessageListView.setAdapter(mChatMessageListAdapter);
            mChatMessageListView.setLayoutManager(new LinearLayoutManager(mContextRef.get(), RecyclerView.VERTICAL, false));
            mChatMessageListView.setItemAnimator(null);
            mChatBotChatMsgContentModel = new ChatBotChatMsgContentModel(mContextRef.get());
            mChatBotMsgViewModel = new ContentViewModel.Builder()
                    .setContentModel(mChatBotChatMsgContentModel)
                    .setLoadMoreEnable(false)
                    .build();
            mChatBotMsgViewModel.bindView(mChatMessageListAdapter);

            mChatMessageListView.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    resetEditTextFocusIfNeed();
                    return false;
                }
            });

            Runnable runnable = () -> {
                mScrollListByUser = false;
            };

            mChatMessageListView.addOnScrollListener(new RecyclerView.OnScrollListener() {
                @Override
                public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                    super.onScrolled(recyclerView, dx, dy);
                    if (!recyclerView.canScrollVertically(1)) {
                        // dy > 0 表示是向下滚动
                        if (dy > 0 && mScrollListByUser) {
                            mScrollListByUser = false;
                        }
                    }

                    if (dy < 0) {
                        mScrollListByUser = true;
                    }
                }
            });

            mChatMessageListAdapter.addChildClickViewIds(R.id.ic_chatbot_message_play_user);
            mChatMessageListAdapter.addChildClickViewIds(R.id.chatbot_message_item_copy_user);
            mChatMessageListAdapter.addChildClickViewIds(R.id.ic_chatbot_message_play_ai);
            mChatMessageListAdapter.addChildClickViewIds(R.id.chatbot_message_item_copy_ai);
            mChatMessageListAdapter.addChildClickViewIds(R.id.chatbot_send_message_status);
            mChatMessageListAdapter.addChildClickViewIds(R.id.chatbot_send_message_item);
            mChatMessageListAdapter.addChildClickViewIds(R.id.chat_msg_receive_message_item_ai);
            mChatMessageListAdapter.setOnItemChildClickListener(new OnItemChildClickListener() {

                @Override
                public void onItemChildClick(BaseQuickAdapter adapter, View view, int position){
                    resetEditTextFocusIfNeed();
                    if(view.getId() == R.id.chatbot_message_item_copy_user || view.getId() == R.id.chatbot_message_item_copy_ai)
                    {
                        ImageView copyIcon = (ImageView) view;
                        CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(position);
                        if(cardEntity != null && cardEntity.bizData != null) {
                            ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                            if(uiMessage.getMessage() != null) {
                                copyToClipboard(mContextRef.get(), uiMessage.getMessage().text);
                                ToastHelper.showToast(mContextRef.get(), "Text has copyed", Toast.LENGTH_SHORT);
                                copyIcon.setImageResource(R.drawable.ic_chatbot_message_copyed);
                                new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                                    @Override
                                    public void run() {
                                        if(uiMessage.getMessage().senderId.equals(mAgentId)) {
                                            copyIcon.setImageResource(R.drawable.ic_chatbot_message_copy);
                                        } else {
                                            copyIcon.setImageResource(R.drawable.ic_chatbot_message_copy_highlight);
                                        }
                                    }
                                }, 2000);
                            }
                        }
                    }
                    else if(view.getId() == R.id.ic_chatbot_message_play_user || view.getId() == R.id.ic_chatbot_message_play_ai)
                    {
                        PlayMessageAnimationView animationView= (PlayMessageAnimationView)view;
                        CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(position);
                        if(cardEntity != null && cardEntity.bizData != null) {
                            ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                            if(uiMessage.getMessage() != null) {
                                startPlayingMessage(uiMessage.getMessage(),AIChatBotSettingDialog.currentVoice, animationView);
                            }
                        }
                    }
                    else if(view.getId() == R.id.chatbot_send_message_status)
                    {
                        CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(position);
                        if(cardEntity != null && cardEntity.bizData != null) {
                            ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                            if(uiMessage.getMessage() != null) {
                                ARTCAIChatEngine.ARTCAIChatMessage message = uiMessage.getMessage();
                                if(message.messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Failed) {
                                    sendMessageInternal(message);
                                    view.setBackgroundResource(R.drawable.ic_chatbot_msg_send_loading);
                                }
                            }
                        }
                    }
                }
            });

            mChatMessageListAdapter.addChildLongClickViewIds(R.id.chat_msg_message_item_user);
            mChatMessageListAdapter.addChildLongClickViewIds(R.id.chat_msg_receive_message_item_ai);
            mChatMessageListAdapter.setOnItemChildLongClickListener(new OnItemChildLongClickListener() {
                @Override
                public boolean onItemChildLongClick(BaseQuickAdapter adapter, View view, int position) {
                    showDeleteDialog(view, position);
                    return true;
                }
            });
        }


        private void showDeleteDialog(View itemView, final int position) {
            // 加载布局
            LayoutInflater inflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            View popupView = inflater.inflate(R.layout.dialog_auiaichat_chatbot_delete_message_popup_window, null);

            // 初始化PopupWindow
            int width = ConstraintLayout.LayoutParams.WRAP_CONTENT;
            int height = ConstraintLayout.LayoutParams.WRAP_CONTENT;
            boolean focusable = true; // 让弹出窗口获取焦点
            PopupWindow popupWindow = new PopupWindow(popupView, width, height, focusable);

            // 设置动画
            //popupWindow.setAnimationStyle(R.style.PopupAnimation);

            // 显示PopupWindow
            popupWindow.showAsDropDown(itemView, itemView.getWidth()/2 -50, 0);  // 调整位置以适应尖角

            popupView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    showMessageDeleteDialog(itemView, position);
                    popupWindow.dismiss();
                }
            });
        }

        private void deleteMessage(int position) {
            // 从数据集中移除指定位置的数据
            if(position >= 0 && position < mChatMessageListAdapter.getItemCount()) {
                CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(position);
                if(cardEntity != null && cardEntity.bizData != null) {
                    ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                    if(uiMessage.getMessage() != null) {
                        mChatEngine.deleteMessage(uiMessage.getMessage(), new ARTCAIChatEngine.IARTCAIChatMessageCallback(){
                            @Override
                            public void onSuccess(ARTCAIChatEngine.ARTCAIChatMessage data) {
                                mChatMessageListAdapter.removeAt(position);
                            }

                            @Override
                            public void onFailure(ARTCAIChatEngine.ARTCAIChatMessage data, ARTCAIChatEngine.ARTCAIChatError error) {
                                Logger.e("deleteMessage failed, errorCode: " + error.errorCode + ", errorMsg: " + error.errorMsg);
                                if(TextUtils.isEmpty(data.text) || TextUtils.isEmpty(data.dialogueId)) {
                                    mChatMessageListAdapter.removeAt(position);
                                }
                            }
                        });
                    }
                }
            }
        }

        private void showMessageDeleteDialog(View itemView, final int position) {
            View view = LayoutInflater.from(mContextRef.get()).inflate(R.layout.dialog_aicall_chatbot_delete_message_confirm_dialog, null, false);
            ViewHolder viewHolder = new ViewHolder(view);
            DialogPlus dialog = DialogPlus.newDialog(mContextRef.get())
                    .setContentHolder(viewHolder)
                    .setGravity(Gravity.CENTER)
                    .setOverlayBackgroundResource(android.R.color.transparent)
                    .setContentBackgroundResource(R.color.layout_base_dialog_background)
                    .setOnClickListener((dialog1, v) -> {
                        if (v.getId() == R.id.btn_confirm) {
                            deleteMessage(position);
                            dialog1.dismiss();
                        }
                        if (v.getId() == R.id.btn_cancel) {
                            dialog1.dismiss();
                        }
                    })
                    .setOnDismissListener(new OnDismissListener() {
                        @Override
                        public void onDismiss(DialogPlus dialog) {

                        }
                    })
                    .create();
            dialog.show();
        }
    }

    public void copyToClipboard(Context context, String text) {
        // 获取剪贴板管理器
        ClipboardManager clipboard = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
        // 创建剪贴板数据
        ClipData clip = ClipData.newPlainText("AUIAICall", text); // "label" 可以自定义
        // 将数据放入剪贴板
        clipboard.setPrimaryClip(clip);
    }
}