package com.aliyun.auikits.aicall;

import static com.aliyun.auikits.aiagent.ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent;
import static com.aliyun.auikits.aiagent.ARTCAICallEngine.ARTCAICallAgentType.VisionAgent;
import static com.aliyun.auikits.aiagent.ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
import static com.aliyun.auikits.aiagent.ARTCAIChatEngine.ARTCAIChatAgentState.Listening;
import static com.aliyun.auikits.aiagent.ARTCAIChatEngine.ARTCAIChatAgentState.Thinking;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_REGION;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_IS_SHARED_AGENT;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID;
import static com.aliyun.auikits.aicall.util.AUIAIConstStrKey.BUNDLE_KEY_TOKEN_EXPIRE_TIMESTAMP;
import android.Manifest;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.provider.MediaStore;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.ScrollingMovementMethod;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.webkit.MimeTypeMap;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.ARTCAIChatAttachmentUploader;
import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aiagent.ARTCAIChatEngineImpl;
import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.card.CardListAdapter;
import com.aliyun.auikits.aicall.base.card.DefaultCardViewFactory;
import com.aliyun.auikits.aicall.base.feed.ContentViewModel;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.bean.ChatBotSelectedFileAttachment;
import com.aliyun.auikits.aicall.model.ChatBotChatMsgContentModel;
import com.aliyun.auikits.aicall.model.ChatBotSelectImagesContentModel;
import com.aliyun.auikits.aicall.util.AUIAICallAgentDebug;
import com.aliyun.auikits.aicall.util.AUIAICallAgentIdConfig;
import com.aliyun.auikits.aicall.util.AUIAICallAuthTokenHelper;
import com.aliyun.auikits.aicall.util.AUIAIChatFileUtil;
import com.aliyun.auikits.aicall.util.AUIAIChatMessageCacheHelper;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.BizStatHelper;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.aliyun.auikits.aicall.util.PermissionUtils;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.TimeUtil;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.util.markwon.AUIAIMarkwonManager;
import com.aliyun.auikits.aicall.widget.AICallNoticeDialog;
import com.aliyun.auikits.aicall.widget.AICallReportingDialog;
import com.aliyun.auikits.aicall.widget.AIChatBotSettingDialog;
import com.aliyun.auikits.aicall.widget.PlayMessageAnimationView;
import com.aliyun.auikits.aicall.widget.VoiceInputEditText;
import com.aliyun.auikits.aicall.widget.card.CardTypeDef;
import com.aliyun.auikits.aicall.widget.card.ChatBotReceiveTextMessageCard;
import com.aliyun.auikits.aicall.widget.card.ChatBotSelectImageCard;
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

    private static final int PICK_IMAGES_REQUEST = 1;
    private static final int PERMISSION_REQUEST_CODE = 100;

    private LayoutHolder mLayoutHolder = new LayoutHolder();
    private MultiMediaHolder mMultiMediaHolder = new MultiMediaHolder();
    private ARTCAIChatEngine mChatEngine = null;
    private String mCurrentRequestId = null;
    private String mAgentId = null;
    private String mUserId = null;
    private String mSessionId = null;
    private String mUserLoginAuthorization = null;
    private boolean mPushingToTalking = false;
    private AUIAIChatType mCurrentChatType = AUIAIChatType.Text;
    private ARTCAIChatEngine.ARTCAIChatAgentState mCurrentAgentState = ARTCAIChatEngine.ARTCAIChatAgentState.Listening;
    protected List<AudioToneData> mAgentVoiceIdList = new ArrayList<AudioToneData>();
    private ARTCAIChatEngine.ARTCAIChatMessagePlayState playState = ARTCAIChatEngine.ARTCAIChatMessagePlayState.Init;

    private Handler mHandler = null;
    private boolean mUIProgressing = false;
    private long mStartPressVoiceMillis = 0;
    private boolean mIsSharedAgent = false;
    private String mAgentRegion = null;
    private long mLastBackButtonExitMillis = 0;
    private ARTCAIChatEngine.ARTCAIChatAgentShareConfig mShareConfig = null;

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

                AUIAICallAuthTokenHelper.getAIChatAuthToken(mUserId, mUserLoginAuthorization, mAgentId, mAgentRegion, new AUIAICallAuthTokenHelper.IAUIAICallAuthTokenCallback() {
                    @Override
                    public void onSuccess(JSONObject token) {
                        ARTCAIChatEngine.ARTCAIChatAuthToken auth = new ARTCAIChatEngine.ARTCAIChatAuthToken(token);
                        if(auth != null) {
                            callback.onSuccess(auth);
                        }
                    }
                    @Override
                    public void onFail(int errorCode, String errorMsg) {
                        Logger.e("onRequestAuthToken failed: " + errorMsg);
                    }
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
                if(!TextUtils.isEmpty(message.senderId) && message.senderId.equals(mAgentId)) {
                    mLayoutHolder.handleAIChatMessage(message, true);
                } else {
                    mLayoutHolder.handleAIChatMessage(message, false);
                }
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

        @Override
        public void onReceivedCustomMessage(String  text) {
            Logger.i("onReceivedCustomMessage: " + text);
            if(BuildConfig.TEST_ENV_MODE) {
                ToastHelper.showToast(AUIAIChatInChatActivity.this, "receive custom message: " + text, Toast.LENGTH_SHORT);
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(com.chad.library.R.style.Theme_AppCompat_Light_NoActionBar);
        setContentView(R.layout.activity_auiaichat_in_chat);

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

        mLayoutHolder.init(this);
        mMultiMediaHolder.init(this);
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



        mSessionId = mUserId + "_" +mAgentId;

        ARTCAIChatEngine.ARTCAIChatAgentInfo agentInfo = new ARTCAIChatEngine.ARTCAIChatAgentInfo(mAgentId);
        if(!mIsSharedAgent) {
            mAgentRegion = AUIAICallAgentIdConfig.getRegion();
        }
        if(!TextUtils.isEmpty(mAgentRegion)) {
            agentInfo.region = mAgentRegion;
        }
        mChatEngine = new ARTCAIChatEngineImpl(AUIAIChatInChatActivity.this);
        mChatEngine.setEngineCallback(mAIChatEngineCallback);
        if(BuildConfig.TEST_ENV_MODE) {
            String userData = SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_USER_EXTEND_DATA);
            if(!TextUtils.isEmpty(userData)) {
                mChatEngine.setUserData(userData);
            }
            String bailianParam = SettingStorage.getInstance().get(SettingStorage.KEY_BAILIAN_APP_PARAMS);
            if(!TextUtils.isEmpty(bailianParam)) {
                mChatEngine.setTemplateConfig(new ARTCAIChatEngine.ARTCAIChatTemplateConfig(bailianParam, ""));
            }
        }

        mChatEngine.startChat(
                new ARTCAIChatEngine.ARTCAIChatUserInfo(mUserId, ""),
                agentInfo, mSessionId);
        mLayoutHolder.loadMessageFromCache();
        mLayoutHolder.changeConnectionStatusText(mChatEngine.getEngineState());


        AUIAIMarkwonManager.getInstance(this).registerLinkClickCallback(new AUIAIMarkwonManager.AUIAIMarkwonManagerCallback() {
            @Override
            public void onLinkClicked(String url) {
                jumpToWebView(url);
            }
        });
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

    private void jumpToInCallActivity(ARTCAICallEngine.ARTCAICallAgentType agentType) {
        Intent intent = new Intent(AUIAIChatInChatActivity.this, AUIAICallInCallActivity.class);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, mUserId);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, mUserLoginAuthorization);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, agentType);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_RTC_AUTH_TOKEN, mMultiMediaHolder.mAICallAuthToken);
        boolean useEmotional = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_EMOTION, SettingStorage.DEFAULT_BOOT_ENABLE_EMOTION);
        boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
        String agentId = "";
        if(BuildConfig.TEST_ENV_MODE) {
            agentId = usePreHost ? AUIAICallAgentDebug.getAIAgentId(agentType, useEmotional) :  AUIAICallAgentIdConfig.getAIAgentId(agentType, useEmotional);
        }
        else {
            agentId = AUIAICallAgentIdConfig.getAIAgentId(agentType, useEmotional);
        }
        if(!TextUtils.isEmpty(agentId)) {
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, agentId);
        }
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_IS_SHARED_AGENT, false);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_CHAT_SYNC_CONFIG, true);
        startActivity(intent);
    }

    private void jumpToWebView(String url) {
        Intent intent = new Intent(AUIAIChatInChatActivity.this, AUIAIChatWebViewActivity.class);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_WEBVIEW_URL, url);
        startActivity(intent);
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

    private String generateUUId() {
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

    // 检查权限
    private boolean checkPermission() {
        String[] per = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ?
                new String[] {Manifest.permission.READ_EXTERNAL_STORAGE} :
                new String[] {Manifest.permission.READ_MEDIA_IMAGES,
                        Manifest.permission.READ_MEDIA_VIDEO,
                        Manifest.permission.READ_MEDIA_AUDIO};
        boolean hasPermission = PermissionUtils.checkPermissionsGroup(this, per);
        if(!hasPermission) {
            ToastHelper.showToast(this, "External storage is not permitted to write, please open first", Toast.LENGTH_SHORT);
        }
        return hasPermission;
    }

    // 请求权限
    private void requestPermission() {
        String[] per = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ?
                new String[] {Manifest.permission.READ_EXTERNAL_STORAGE} :
                new String[] {Manifest.permission.READ_MEDIA_IMAGES,
                        Manifest.permission.READ_MEDIA_VIDEO,
                        Manifest.permission.READ_MEDIA_AUDIO};
        PermissionUtils.requestPermissions(this, per, PERMISSION_REQUEST_CODE);
    }

    // 处理权限请求结果
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                mMultiMediaHolder.openGallery();
            } else {
                Toast.makeText(this, "权限被拒绝", Toast.LENGTH_SHORT).show();
            }
        }
    }

    // 处理从相册返回的结果
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == PICK_IMAGES_REQUEST && resultCode == RESULT_OK) {
            if (data.getClipData() != null) { // 用户选择了多张图片
                int count = data.getClipData().getItemCount();
                for (int i = 0; i < count; i++) {
                    if (i >= 9) {
                        Toast.makeText(this, R.string.chatbot_selected_image_limit, Toast.LENGTH_SHORT).show();
                        break;
                    }
                    Uri imageUri = data.getClipData().getItemAt(i).getUri();
                    mMultiMediaHolder.addSelectedImage(imageUri);
                }
            } else if (data.getData() != null) { // 用户只选择了一张图片
                Uri imageUri = data.getData();
                mMultiMediaHolder.addSelectedImage(imageUri);
            }
        }
    }

    private class LayoutHolder{

        private EditText mChatBotEditText;
        private ImageView mChatBotAction;
        private VoiceInputEditText mPresseToPushAction;
        private ImageView mChangeToVoicePushAction;
        private CardListAdapter mChatMessageListAdapter;
        private ChatBotChatMsgContentModel mChatBotChatMsgContentModel;
        private ContentViewModel mChatBotMsgViewModel;
        private WeakReference<Context> mContextRef;
        private RecyclerView mChatMessageListView;
        private TextView mConnectStatusTextView;
        private LinearLayout mChatInputLayout;
        private TextView mPressVoiceToTalkingTime;
        private TextView mPressVoiceToTalkingTitle;
        private SmartRefreshLayout mMessageListRefreshLayout;
        private PlayMessageAnimationView mCurrentMessagePlayingAnimationView;
        private ARTCAIChatEngine.ARTCAIChatMessage mCurrentPlayingMessage;
        private Boolean mSkipPlayStoppedMessage = false;
        private ARTCAIChatEngine.ARTCAIChatEngineState mCurrentEngineStatus;
        private Boolean mScrollListByUser = false;
        private Handler autoScrollHandler = new Handler(Looper.getMainLooper());
        private ImageView mAddMoreButton;
        private ConstraintLayout mMoreActionLayout;

        private ImageView mSpeechAnimationView;

        private void init(Context context) {

            this.mContextRef = new WeakReference<>(context);
            mChatBotEditText = findViewById(R.id.editTextMessage);
            mChatBotAction = findViewById(R.id.chatbot_action_img);
            mConnectStatusTextView = findViewById(R.id.chatbot_connect_status);
            mPresseToPushAction = findViewById(R.id.press_to_push);
            mChatInputLayout = findViewById(R.id.bottom_input_text_bar);
            mPressVoiceToTalkingTime = findViewById(R.id.bottom_press_voice_timer);
            mPressVoiceToTalkingTitle = findViewById(R.id.bottom_press_voice_title);
            mMessageListRefreshLayout = findViewById(R.id.srl_chat_message_list);
            mMessageListRefreshLayout.setEnableLoadMore(false);
            mAddMoreButton = findViewById(R.id.ic_bottom_add_more_image);
            mMoreActionLayout = findViewById(R.id.bottom_down_layout);
            mChangeToVoicePushAction = findViewById(R.id.ic_bottom_voice_press);
            mChatBotEditText.setVerticalScrollBarEnabled(true);
            mChatBotEditText.setMovementMethod(new ScrollingMovementMethod());
            mSpeechAnimationView = findViewById(R.id.chatbot_speech_animation_view);

            mChatBotEditText.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    if (hasFocus) {
                        scrollToBottomMessage();
                    }
                    if(mMultiMediaHolder.mSelectedImages.size() == 0) {
                        resetAddMoreLayoutToDefault();
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
                    changeChatActionButtonState();
                }
                @Override
                public void afterTextChanged(Editable s) {
                }
            });


            mChatBotAction.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    String content = mChatBotEditText.getText().toString();
                    if(mCurrentAgentState == Listening ) {
                        if(mCurrentChatType == AUIAIChatType.Text) {
                            boolean shouldResetEditText = false;
                            if(mMultiMediaHolder.mSelectedImages.size() == 0) {
                                if (!TextUtils.isEmpty(content)) {
                                    sendTextMessage(content);
                                    shouldResetEditText = true;
                                }
                            } else {
                                if(!mMultiMediaHolder.allImagesHasUploaded()) {
                                    if(mMultiMediaHolder.hasImageUploadFailed()) {
                                        ToastHelper.showToast(mContextRef.get(), R.string.chat_bot_image_upload_failed, Toast.LENGTH_SHORT);
                                    } else {
                                        ToastHelper.showToast(mContextRef.get(), R.string.chat_bot_image_uploading, Toast.LENGTH_SHORT);
                                    }
                                } else {
                                    sendTextMessage(content);
                                    if (!TextUtils.isEmpty(content)) {
                                        shouldResetEditText = true;
                                    }
                                }
                            }

                            if(shouldResetEditText) {
                                mChatBotEditText.setText("");
                                mChatBotEditText.clearFocus();
                                mChatBotAction.setImageResource(R.drawable.ic_chatbot_interrupt_response);
                                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                                imm.hideSoftInputFromWindow(mChatBotEditText.getWindowToken(), 0);
                            }
                        } else {
                            mCurrentChatType = AUIAIChatType.Text;
                        }
                    } else {
                        ARTCAIChatEngine.ARTCAIChatMessage thinkMessage = getCurrentThinkingMessage(mCurrentRequestId);
                        if(mCurrentAgentState == Thinking  || (thinkMessage != null && TextUtils.isEmpty(thinkMessage.text) && thinkMessage.isEnd)) {
                            deleteThinkingResponseMessage(mCurrentRequestId);
                        }
                        mChatEngine.interruptAgentResponse();
                    }
                    changeChatActionButtonState();
                }
            });

            mPresseToPushAction.setVoiceInputListener(new VoiceInputEditText.VoiceInputListener() {
                @Override
                public void onLongPressStart() {
                    startPushingVoiceMessage();
                    updatePushVoiceUI(AUIAIChatPushVoiceAction.Start);
                    scrollToBottomMessage();
                }
                @Override
                public void onLongPressEnd(boolean isUpperSlip) {
                    if(isUpperSlip) {
                        cancelPushingVoiceMessage();
                    }
                    else {
                        stopPushingVoiceMessage();
                    }
                    updatePushVoiceUI(AUIAIChatPushVoiceAction.Stop);
                    if(mMultiMediaHolder.mSelectedImages.size() == 0) {
                        resetAddMoreLayoutToDefault();
                    }
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


            mChangeToVoicePushAction.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mCurrentChatType = AUIAIChatType.Voice;
                    changeChatActionButtonState();

                }
            });



            mMessageListRefreshLayout.setOnRefreshListener(new OnRefreshListener() {
                @Override
                public void onRefresh(@NonNull RefreshLayout refreshLayout) {
                    featchHistoryMessage(true);
                }
            });

            mAddMoreButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(mCurrentAgentState == Listening) {
                        if(mMoreActionLayout.getVisibility() == View.GONE) {
                            mMoreActionLayout.setVisibility(View.VISIBLE);
                            mAddMoreButton.setImageResource(R.drawable.ic_bottom_add_more_hidden);

                            AUIAICallAuthTokenHelper.getAICallAuthToken(mUserId, mUserLoginAuthorization, new AUIAICallAuthTokenHelper.IAUIAICallAuthTokenCallback() {
                                @Override
                                public void onSuccess(JSONObject jsonObject) {
                                    try {
                                        if (jsonObject.has("rtc_auth_token")) {
                                            String rtcAuthToken = jsonObject.getString("rtc_auth_token");
                                            if (!TextUtils.isEmpty(rtcAuthToken)) {
                                                mMultiMediaHolder.mAICallAuthToken = rtcAuthToken;
                                            }
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                }
                                @Override
                                public void onFail(int errorCode, String errorMsg) {
                                }
                            });

                        } else {
                            mMoreActionLayout.setVisibility(View.GONE);
                            mAddMoreButton.setImageResource(R.drawable.ic_bottom_add_more);
                        }
                    }
                    scrollToBottomMessage();
                }
            });

            initChatMessageList();
        }

        private void resetAddMoreLayoutToDefault() {
            mLayoutHolder.mAddMoreButton.setVisibility(View.VISIBLE);
            mLayoutHolder.mMoreActionLayout.setVisibility(View.GONE);
            mAddMoreButton.setImageResource(R.drawable.ic_bottom_add_more);
        }

        private void scrollToBottomMessage() {
            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                @Override
                public void run() {
                    mLayoutHolder.mChatMessageListAdapter.scrollToBottom(mLayoutHolder.mChatMessageListView);
                }
            }, 200);

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

            if(action == AUIAIChatPushVoiceAction.UpperSlip) {
                mPressVoiceToTalkingTitle.setTextColor(mContextRef.get().getResources().getColor(R.color.layout_chatbot_red));
                mPressVoiceToTalkingTitle.setText(R.string.chat_bot_press_to_talk_title_cancel);
                mChatInputLayout.setBackgroundResource(R.drawable.layout_chat_voice_push_cancel_bg);
                mSpeechAnimationView.setImageResource(R.drawable.ic_chatbot_voice_push_cancel);
            } else {
                mChatInputLayout.setBackgroundResource(R.drawable.layout_chat_voice_push_bg);
                mPressVoiceToTalkingTitle.setTextColor(Color.parseColor("#FCFCFD"));
                mPressVoiceToTalkingTitle.setText(R.string.chat_bot_press_to_talk_title);
                mSpeechAnimationView.setImageResource(R.drawable.ic_chatbot_voice_push);
            }

            switch (action) {
                case Start:
                    mAddMoreButton.setVisibility(View.GONE);
                    mPresseToPushAction.setText("");
                    mChatBotAction.setVisibility(View.GONE);
                    mPressVoiceToTalkingTime.setVisibility(View.VISIBLE);
                    mSpeechAnimationView.setVisibility(View.VISIBLE);
                    mPressVoiceToTalkingTitle.setVisibility(View.VISIBLE);
                    break;
                case Stop:
                    mChatInputLayout.setBackgroundResource(R.drawable.layout_chat_msg_input_bg);
                    mSpeechAnimationView.setVisibility(View.GONE);
                    mAddMoreButton.setVisibility(View.VISIBLE);
                    mPresseToPushAction.setText(R.string.chat_bot_press_to_talk);
                    mPressVoiceToTalkingTime.setText("00:00");
                    mPressVoiceToTalkingTime.setVisibility(View.GONE);
                    mPressVoiceToTalkingTitle.setVisibility(View.GONE);
                    mChatBotAction.setVisibility(View.VISIBLE);
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
                mChatBotAction.setImageResource(R.drawable.ic_chatbot_interrupt_response);
                mChatBotAction.setVisibility(View.VISIBLE);
                if(mCurrentChatType == AUIAIChatType.Voice) {
                    mPresseToPushAction.setTextColor(Color.parseColor("#9E9E9E"));
                    mPresseToPushAction.setEnabled(false);
                } else if(mCurrentChatType == AUIAIChatType.Text) {
                    mChangeToVoicePushAction.setImageResource(R.drawable.ic_chatbot_push_voice_disable);
                    mChangeToVoicePushAction.setEnabled(false);
                }

                mAddMoreButton.setImageResource(R.drawable.ic_bottom_add_more_disable);

            } else {
                //机器人不再回复

                boolean hasMultiMedia = mMultiMediaHolder.mSelectedImages.size() > 0 ;
                boolean hasText = !TextUtils.isEmpty(mChatBotEditText.getText().toString().trim());

                mAddMoreButton.setImageResource(R.drawable.ic_bottom_add_more);
                mChangeToVoicePushAction.setImageResource(R.drawable.ic_chatbot_push_voice);
                mChangeToVoicePushAction.setEnabled(true);
                if(mCurrentChatType == AUIAIChatType.Voice) {
                    if(hasMultiMedia) {
                        mPresseToPushAction.setTextColor(Color.parseColor("#9E9E9E"));
                        mPresseToPushAction.setEnabled(false);

                    } else {
                        mPresseToPushAction.setTextColor(Color.parseColor("#FCFCFD"));
                        mPresseToPushAction.setEnabled(true);
                    }

                    mPresseToPushAction.setVisibility(View.VISIBLE);
                    mChatBotAction.setImageResource(R.drawable.ic_chatbot_back_to_text);
                    mChatBotEditText.setVisibility(View.GONE);
                    mChangeToVoicePushAction.setVisibility(View.GONE);
                    mChatBotAction.setVisibility(View.VISIBLE);
                    LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) mChatInputLayout.getLayoutParams();
                    layoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 20, getResources().getDisplayMetrics());
                    mChatInputLayout.setLayoutParams(layoutParams);

                } else {
                    mChatBotEditText.setVisibility(View.VISIBLE);
                    mPresseToPushAction.setVisibility(View.GONE);
                    if(mChatBotEditText.hasFocus()) {
                        mChangeToVoicePushAction.setVisibility(View.GONE);
                        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) mChatInputLayout.getLayoutParams();
                        layoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 20, getResources().getDisplayMetrics());
                        mChatInputLayout.setLayoutParams(layoutParams);
                    } else  {
                        mChangeToVoicePushAction.setVisibility(View.VISIBLE);
                        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) mChatInputLayout.getLayoutParams();
                        layoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 12, getResources().getDisplayMetrics());
                        mChatInputLayout.setLayoutParams(layoutParams);
                    }

                    if(hasMultiMedia || hasText) {
                        if(hasMultiMedia) {
                            if(mMultiMediaHolder.allImagesHasUploaded()) {
                                mChatBotAction.setImageResource(R.drawable.ic_chat_bot_text_message_send);
                            } else {
                                mChatBotAction.setImageResource(R.drawable.ic_chat_bot_text_message_send_disable);
                            }
                        } else {
                            mChatBotAction.setImageResource(R.drawable.ic_chat_bot_text_message_send);
                        }
                        mChatBotAction.setVisibility(View.VISIBLE);
                    } else {
                        mChatBotAction.setVisibility(View.GONE);
                    }
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
                if(mChatEngine.getAgentInfo() != null) {
                    message.setAIResponse(sendMessage.senderId.equals(mChatEngine.getAgentInfo().agentId));
                } else {
                    message.setAIResponse(false);
                }

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
                scrollToBottomMessage();
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

        private void sendTextMessage(String content) {
            String requestId = generateUUId();
            mCurrentRequestId = requestId;
            ARTCAIChatEngine.ARTCAIChatMessage sendMessage = new ARTCAIChatEngine.ARTCAIChatMessage(requestId, content);
            sendMessage.messageState = ARTCAIChatEngine.ARTCAIChatMessageState.Init;
            sendMessage.messageType = ARTCAIChatEngine.ARTCAIChatMessageType.Text;
            insertMessageToMessageList(sendMessage, false, true);
            sendMessageInternal(sendMessage);
        }


        private void sendMessageInternal(ARTCAIChatEngine.ARTCAIChatMessage message) {

            ARTCAIChatEngine.ARTCAIChatSendMessageRequest request;
            if(mMultiMediaHolder.mAttachmentUploader != null && !mMultiMediaHolder.mSelectedImages.isEmpty()) {
                request = new ARTCAIChatEngine.ARTCAIChatSendMessageRequest(message.requestId, ARTCAIChatEngine.ARTCAIChatMessageType.Text, message.text, mMultiMediaHolder.mAttachmentUploader);
            } else {
                request = new ARTCAIChatEngine.ARTCAIChatSendMessageRequest(message.requestId, ARTCAIChatEngine.ARTCAIChatMessageType.Text, message.text);
            }

            mChatEngine.sendMessage(request, new ARTCAIChatEngine.IARTCAIChatMessageCallback() {
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
                    mMultiMediaHolder.clearSelectedImages();
                }
                @Override
                public void onFailure(ARTCAIChatEngine.ARTCAIChatMessage data, ARTCAIChatEngine.ARTCAIChatError error) {
                    int pos = mChatBotChatMsgContentModel.getPositionByRequestId(data.requestId, false);
                    if(pos >= 0 && pos < mChatMessageListAdapter.getItemCount()) {
                        CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(pos);
                        if (cardEntity != null && cardEntity.bizData != null) {
                            ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                            uiMessage.setMessage(data);
                            mChatBotChatMsgContentModel.updateContent(cardEntity, pos);
                        }
                    }
                    mLayoutHolder.resetAddMoreLayoutToDefault();
                }
            });
        }
        private void handleAIChatMessage(ARTCAIChatEngine.ARTCAIChatMessage chatMessage, boolean isAgentResponse) {
            mChatMessageListAdapter.setAutoScrollToBottom(!mScrollListByUser);
            int pos = mChatBotChatMsgContentModel.getPositionByRequestId(chatMessage.requestId, isAgentResponse);
            boolean notifyChangedInstead = false;
            if(pos >= 0 && pos < mChatMessageListAdapter.getItemCount()) {
                if(chatMessage.messageState != ARTCAIChatEngine.ARTCAIChatMessageState.Failed) {
                    if(!TextUtils.isEmpty(chatMessage.text) || !TextUtils.isEmpty(chatMessage.reasoningText) || chatMessage.attachmentList.size() > 0 ) {
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
                if(TextUtils.isEmpty(message.text)) {
                    ToastHelper.showToast(mContextRef.get(), "AI Response is null, can not play", Toast.LENGTH_SHORT);
                    return;
                }
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
            String requestId = generateUUId();
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
            mChatMessageListAdapter = new CardListAdapter(factory, new CardListAdapter.OnItemLongClickListener() {
                @Override
                public void onItemLongClick(View view, int position) {
                    showDeleteDialog(view, position, true);
                }
            });
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
                                if(!TextUtils.isEmpty(uiMessage.getMessage().text)) {
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
                                } else {
                                    ToastHelper.showToast(mContextRef.get(), "AI Response is null, can not copy", Toast.LENGTH_SHORT);
                                }
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

            mChatMessageListAdapter.addChildLongClickViewIds(R.id.chatbot_send_message_item_text_layout);
            mChatMessageListAdapter.addChildLongClickViewIds(R.id.chat_msg_receive_message_item_ai);
            mChatMessageListAdapter.addChildLongClickViewIds(R.id.chat_message_text);
            mChatMessageListAdapter.setOnItemChildLongClickListener(new OnItemChildLongClickListener() {
                @Override
                public boolean onItemChildLongClick(BaseQuickAdapter adapter, View view, int position) {
                    showDeleteDialog(view, position, false);
                    return true;
                }
            });
        }


        private void showDeleteDialog(View itemView, final int position, boolean isImageLongPress) {
            // 加载布局
            LayoutInflater inflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            View popupView = inflater.inflate(R.layout.dialog_auiaichat_chatbot_delete_message_popup_window, null);
            TextView deleteButton = popupView.findViewById(R.id.chatbot_message_item_delete_text);

            boolean isMixtMessage = false;
            ARTCAIChatEngine.ARTCAIChatMessage message = null;
            if(position >= 0 && position < mChatMessageListAdapter.getItemCount()) {
                CardEntity cardEntity = (CardEntity) mChatMessageListAdapter.getItem(position);
                if(cardEntity != null && cardEntity.bizData != null ) {
                    ChatBotChatMessage uiMessage = (ChatBotChatMessage) cardEntity.bizData;
                    message = uiMessage.getMessage();
                    if(message != null && message.attachmentList.size() > 0 && !TextUtils.isEmpty(message.text)) {
                        isMixtMessage = true;
                        deleteButton.setText(getString(R.string.chat_bot_delete_all_message));
                    } else {
                        deleteButton.setText(getString(R.string.chat_bot_delete_message));
                    }
                }
            }


            // 初始化PopupWindow
            int width = ConstraintLayout.LayoutParams.WRAP_CONTENT;
            int height = ConstraintLayout.LayoutParams.WRAP_CONTENT;
            boolean focusable = true; // 让弹出窗口获取焦点
            PopupWindow popupWindow = new PopupWindow(popupView, width, height, focusable);

            // 设置动画
            //popupWindow.setAnimationStyle(R.style.PopupAnimation);

            // 显示PopupWindow
            int yOff = 0;
            int xOff = itemView.getWidth()/2 -50;
            if(isMixtMessage) {
                yOff = -itemView.getHeight()/2;
            }
            if(isImageLongPress && message != null) {
                if(message.attachmentList.size() > 0) {
                    if(message.attachmentList.size() == 1) {
                        xOff = itemView.getWidth() -200;
                    }
                }
            }
            popupWindow.showAsDropDown(itemView, xOff, yOff);  // 调整位置以适应尖角

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
                if(cardEntity != null && cardEntity.bizData != null ) {
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
                } else {
                    mChatMessageListAdapter.removeAt(position);
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

    private class MultiMediaHolder {

        private WeakReference<Context> mContextRef;
        private ImageView mAddPhotoBtn;
        private ArrayList<ChatBotSelectedFileAttachment> mSelectedImages = new ArrayList<ChatBotSelectedFileAttachment>();
        private RecyclerView mSelectedImagesListView;
        private CardListAdapter mSelectedImagesListAdapter;
        private ChatBotSelectImagesContentModel mSelectedImagesContentModel;
        private ContentViewModel mSelectedImageViewModel;
        private LinearLayout mAddMorePhotoLayout;
        private ConstraintLayout mSelectedImageLayout;
        private LinearLayout mAddButtonLayout;
        private ARTCAIChatAttachmentUploader mAttachmentUploader = null;
        private String mAICallAuthToken = null;

        private void init(Context context) {
            this.mContextRef = new WeakReference<>(context);
            mAddPhotoBtn = findViewById(R.id.bottom_down_layout_left_img);
            mAddMorePhotoLayout = findViewById(R.id.bottom_down_layout_add_more_img);
            mSelectedImageLayout = findViewById(R.id.chatbot_image_list_layout);
            mAddButtonLayout = findViewById(R.id.bottom_down_action_layout);

            mAddPhotoBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    addImage();
                }
            });

            mAddMorePhotoLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    addImage();
                }
            });

            findViewById(R.id.bottom_down_voice_chat_action).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    jumpToInCallActivity(VoiceAgent);
                    mLayoutHolder.resetAddMoreLayoutToDefault();
                }
            });

            findViewById(R.id.bottom_down_avator_chat_action).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    jumpToInCallActivity(AvatarAgent);
                    mLayoutHolder.resetAddMoreLayoutToDefault();
                }
            });

            findViewById(R.id.bottom_down_vision_chat_action).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    jumpToInCallActivity(VisionAgent);
                    mLayoutHolder.resetAddMoreLayoutToDefault();
                }
            });

            if(mIsSharedAgent) {
                findViewById(R.id.bottom_down_vision_chat_action).setVisibility(View.GONE);
                findViewById(R.id.bottom_down_avator_chat_action).setVisibility(View.GONE);
                findViewById(R.id.bottom_down_voice_chat_action).setVisibility(View.GONE);
            } else {
                findViewById(R.id.bottom_down_vision_chat_action).setVisibility(View.VISIBLE);
                findViewById(R.id.bottom_down_avator_chat_action).setVisibility(View.VISIBLE);
                findViewById(R.id.bottom_down_voice_chat_action).setVisibility(View.VISIBLE);
            }

            initSelectedImagesList();
        }

        private void addImage() {

            if(mSelectedImages.size() >= 9 ){
                ToastHelper.showToast(mContextRef.get(), R.string.chatbot_selected_image_limit, Toast.LENGTH_SHORT);
                return;
            }

            if(mAttachmentUploader == null && mChatEngine != null) {

                mAttachmentUploader = mChatEngine.createAttachmentUploader();

                if(mAttachmentUploader != null) {

                    mAttachmentUploader.registerAttachmentUploadCallback(new ARTCAIChatAttachmentUploader.IARTCAIChatAttachmentUploadCallback() {
                        @Override
                        public void onSuccess(ARTCAIChatAttachmentUploader.ARTCAIChatAttachment attachment) {
                            int pos = getPossition(attachment.attachmentId);
                            if(pos >=0 && pos < mSelectedImages.size()) {
                                CardEntity cardEntity = (CardEntity) mSelectedImagesListAdapter.getItem(pos);
                                if (cardEntity != null) {
                                    ChatBotSelectedFileAttachment imageAttachment = (ChatBotSelectedFileAttachment) cardEntity.bizData;
                                    imageAttachment.uploadFailed = false;
                                    imageAttachment.progress = 100;
                                    mSelectedImagesContentModel.updateContent(cardEntity, pos);
                                }
                            }
                            mLayoutHolder.changeChatActionButtonState();
                        }

                        @Override
                        public void onFailure(ARTCAIChatAttachmentUploader.ARTCAIChatAttachment attachment, ARTCAIChatEngine.ARTCAIChatError error) {
                            int pos = getPossition(attachment.attachmentId);
                            if(pos >=0 && pos < mSelectedImages.size()) {
                                CardEntity cardEntity = (CardEntity) mSelectedImagesListAdapter.getItem(pos);
                                if (cardEntity != null) {
                                    ChatBotSelectedFileAttachment imageAttachment = (ChatBotSelectedFileAttachment) cardEntity.bizData;
                                    imageAttachment.uploadFailed = true;
                                    mSelectedImagesContentModel.updateContent(cardEntity, pos);
                                }
                            }
                            mLayoutHolder.changeChatActionButtonState();
                            ToastHelper.showToast(mContextRef.get(), R.string.chat_bot_image_upload_failed, Toast.LENGTH_SHORT);
                        }
                        @Override
                        public void onProgress(ARTCAIChatAttachmentUploader.ARTCAIChatAttachment attachment, int progress) {
                            int pos = getPossition(attachment.attachmentId);
                            if(pos >=0 && pos < mSelectedImages.size()) {
                                CardEntity cardEntity = (CardEntity) mSelectedImagesListAdapter.getItem(pos);
                                if (cardEntity != null) {
                                    ChatBotSelectedFileAttachment imageAttachment = (ChatBotSelectedFileAttachment) cardEntity.bizData;
                                    imageAttachment.uploadFailed = false;
                                    imageAttachment.progress = progress;
                                    long currentTime = System.currentTimeMillis();
                                    if(imageAttachment.lastUpdateTime == 0 || currentTime - imageAttachment.lastUpdateTime > 1500) {
                                        imageAttachment.lastUpdateTime = currentTime;
                                        mSelectedImagesContentModel.updateContent(cardEntity, pos);
                                    }
                                }
                            }
                        }
                    });


                    if (checkPermission()) {
                        openGallery();
                    } else {
                        requestPermission();
                    }
                }
            } else {
                if(mAttachmentUploader != null) {
                    if (checkPermission()) {
                        openGallery();
                    } else {
                        requestPermission();
                    }
                }
            }
        }

        private int getPossition(String attachmentId) {
            for (int i = 0; i < mSelectedImages.size(); i++) {
                if (mSelectedImages.get(i).attachmentId.equals(attachmentId)) {
                    return i;
                }
            }
            return -1;
        }

        private void openGallery() {
            Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
            intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true); // 允许多选
            startActivityForResult(intent, PICK_IMAGES_REQUEST);
        }

        private void initSelectedImagesList() {
            mSelectedImagesListView = findViewById(R.id.chatbot_image_list);
            DefaultCardViewFactory factory = new DefaultCardViewFactory();
            factory.registerCardView(CardTypeDef.CHATBOT_SELECTED_IMAGE_CARD, ChatBotSelectImageCard.class);
            mSelectedImagesListAdapter = new CardListAdapter(factory);
            mSelectedImagesListAdapter.setAutoScrollToBottom(false);
            mSelectedImagesListView.setAdapter(mSelectedImagesListAdapter);
            mSelectedImagesListView.setLayoutManager(new LinearLayoutManager(mContextRef.get(), RecyclerView.HORIZONTAL, false));
            mSelectedImagesContentModel = new ChatBotSelectImagesContentModel(mSelectedImages, CardTypeDef.CHATBOT_SELECTED_IMAGE_CARD);
            mSelectedImageViewModel = new ContentViewModel.Builder()
                    .setContentModel(mSelectedImagesContentModel)
                    .setLoadMoreEnable(false)
                    .build();
            mSelectedImageViewModel.bindView(mSelectedImagesListAdapter);
            mSelectedImagesListView.addItemDecoration(new DividerItemDecoration(mContextRef.get(), DividerItemDecoration.HORIZONTAL){
                @Override
                public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                                           @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                    // 获取当前项的位置
                    int position = parent.getChildAdapterPosition(view);

                    // 如果不是第一个项，则设置顶部间距
                    if (position > 0) {
                        outRect.left = 8;
                    }
                }
            });
            mSelectedImagesListAdapter.addChildClickViewIds(R.id.chatbot_selected_image_delete);
            mSelectedImagesListAdapter.setOnItemChildClickListener(new OnItemChildClickListener() {
                @Override
                public void onItemChildClick(@NonNull BaseQuickAdapter adapter, @NonNull View view, int position) {
                    if (view.getId() == R.id.chatbot_selected_image_delete) {
                        if(position >= 0 && position < mSelectedImages.size()) {
                            mAttachmentUploader.removeAttachment(mSelectedImages.get(position).attachmentId);
                            mSelectedImagesListAdapter.removeAt(position);
                            mSelectedImages.remove(position);
                            updateSelectedImageUI();
                            if(mSelectedImages.isEmpty()) {
                                mAttachmentUploader = null;
                            }
                        } else {
                            mSelectedImagesListAdapter.removeAt(position);
                        }
                    }
                }
            });
        }

        private void addSelectedImage(Uri imageUri) {
            if(mAttachmentUploader != null) {
                if(mSelectedImages.size() < 9) {
                    if(AUIAIChatFileUtil.getFileSizeFromUri(AUIAIChatInChatActivity.this, imageUri) <= 10 * 1024 * 1024) {
                        String filePath = AUIAIChatFileUtil.getPathFromUri(AUIAIChatInChatActivity.this, imageUri);
                        String fileName = AUIAIChatFileUtil.getFileName(filePath);

                        String type = null;
                        String extension = MimeTypeMap.getFileExtensionFromUrl(filePath);
                        if (extension != null) {
                            type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
                        }
                        ARTCAIChatAttachmentUploader.ARTCAIChatAttachment imageAttachment = ARTCAIChatAttachmentUploader.ARTCAIChatAttachment.createImageAttachment(generateUUId(), fileName, filePath, "");
                        ChatBotSelectedFileAttachment imageFile = new ChatBotSelectedFileAttachment(imageAttachment.attachmentId, imageUri, ChatBotSelectedFileAttachment.ChatBotAttachmentType.Image);
                        mSelectedImages.add(imageFile);
                        mSelectedImagesContentModel.addSelectedImage(imageFile);
                        mAttachmentUploader.addAttachment(imageAttachment);
                        updateSelectedImageUI();
                    } else {
                        ToastHelper.showToast(mContextRef.get(), R.string.chatbot_selected_image_size_limit, Toast.LENGTH_SHORT);
                    }
                } else {
                    ToastHelper.showToast(mContextRef.get(), R.string.chatbot_selected_image_limit, Toast.LENGTH_SHORT);
                }
            }
        }

        private void updateSelectedImageUI() {
           if(mSelectedImages.size() > 0) {
               mAddButtonLayout.setVisibility(View.GONE);
               mSelectedImageLayout.setVisibility(View.VISIBLE);
               mLayoutHolder.mAddMoreButton.setVisibility(View.GONE);
               DisplayMetrics displayMetrics = new DisplayMetrics();
               getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
               int screenWidth = displayMetrics.widthPixels;

               int count = screenWidth / DisplayUtil.dip2px(60);

               if(mSelectedImages.size() >= (count -1)) {

                   mSelectedImagesListView.getLayoutParams().width =  screenWidth - DisplayUtil.dip2px(92 );
               } else {
                   mSelectedImagesListView.getLayoutParams().width =  DisplayUtil.dip2px((mSelectedImages.size() * 60 ));
               }
               mLayoutHolder.scrollToBottomMessage();
           } else {
               mAddButtonLayout.setVisibility(View.VISIBLE);
               mSelectedImageLayout.setVisibility(View.GONE);
               mLayoutHolder.resetAddMoreLayoutToDefault();
           }
            mLayoutHolder.changeChatActionButtonState();
        }

        private void clearSelectedImages() {

            if(mAttachmentUploader != null) {
                mAttachmentUploader = null;
            }

            mSelectedImagesListAdapter.setNewData(null);
            mSelectedImages.clear();
            updateSelectedImageUI();
        }

        private boolean allImagesHasUploaded() {
            if(mAttachmentUploader != null) {
                return mAttachmentUploader.allUploadSussess();
            } else {
                if(mSelectedImages.size() > 0) {
                    for (int i = 0; i < mSelectedImages.size(); i++) {
                        if(mSelectedImages.get(i).uploadFailed) {
                            return false;
                        }
                    }
                }
            }
            return false;
        }

        private boolean hasImageUploadFailed() {
            if(mSelectedImages.size() > 0) {
                for (int i = 0; i < mSelectedImages.size(); i++) {
                    if(mSelectedImages.get(i).uploadFailed) {
                        return true;
                    }
                }
            }
            return false;
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