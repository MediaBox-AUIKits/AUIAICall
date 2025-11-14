package com.aliyun.auikits.aicall;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.Fragment;
import androidx.viewpager2.adapter.FragmentStateAdapter;
import androidx.viewpager2.widget.ViewPager2;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.acker.simplezxing.activity.CaptureActivity;
import com.alibaba.android.arouter.facade.annotation.Route;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.util.ARTCAIAgentUtil;
import com.aliyun.auikits.aicall.controller.ARTCAICallController;
import com.aliyun.auikits.aicall.util.AUIAICallAgentDebug;
import com.aliyun.auikits.aicall.util.AUIAICallAgentIdConfig;
import com.aliyun.auikits.aicall.util.AUIAICallAuthTokenHelper;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.PermissionUtils;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.AIAgentSettingDialog;
import com.aliyun.auikits.aicall.widget.GradientTextView;
import com.google.android.material.tabs.TabLayout;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;
import com.permissionx.guolindev.PermissionX;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

@Route(path = "/aicall/AUIAICallEntranceActivity")
public class AUIAICallEntranceActivity extends AppCompatActivity {

    private enum AUIAICallType {
        AUIAICallTypeVoiceChat,
        AUIAICallTypeAvatarChat,
        AUIAICallTypeVisionChat,
        AUIAICallTypeChatBot,
        AUIAICallTypeVideoChat,
        AUIAICallTypeOutboundCall,
        AUIAICallTypeInboundCall,
        AUIAICallTypeCustom
    };

    private String mLoginUserId = null;
    private String mLoginAuthorization = null;
    private boolean mShowPstnCallPage = false;

    private long mLastSettingTapMillis = 0;
    private long mLastSettingTapCount = 0;

    private boolean mInternalBuild = false;

    private String mRtcAuthToken = null;
    private LayoutHolder mLayoutHolder = new LayoutHolder();
    private ConstraintLayout mBtnCreateRoomLayout = null;
    private TextView mTvCreateRoom = null;
    private ImageView mTVScanQR = null;
    // 自定义智能体Token
    private String mEtCustomAgentCallToken;
    private  boolean handShareToken = false;

    private ImageButton themeSwitchButton;

    // 保存tab索引，切换主题后恢复
    private static final String KEY_CURRENT_TAB_POSTION = "current_tab_position";
    private int currentTabPosition = 0;

    // Debug开关
    private TextView mTvDebug;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!validateToken()) {
            ToastHelper.showToast(this, R.string.tips_authorization_invalidate, Toast.LENGTH_LONG);
            finish();
        }

        SettingStorage.getInstance().init(this);

        setContentView(R.layout.activity_auiaicall);

        if(savedInstanceState != null) {
            currentTabPosition = savedInstanceState.getInt(KEY_CURRENT_TAB_POSTION, 0);
        }

        mBtnCreateRoomLayout = findViewById(R.id.btn_create_room_layout);
        mTvCreateRoom = findViewById(R.id.tv_create_room_btn);
        mTVScanQR = findViewById(R.id.iv_scan);

        mLayoutHolder.init(this);

        // 退出
        findViewById(R.id.iv_close).setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mBtnCreateRoomLayout.setOnClickListener(view -> jumpToInCallActivity());

        findViewById(R.id.iv_more).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mLayoutHolder.getOfficialLayerHolder().getAUIAICallAgentType() != AUIAICallType.AUIAICallTypeChatBot
                        && mLayoutHolder.getOfficialLayerHolder().getAUIAICallAgentType() != AUIAICallType.AUIAICallTypeInboundCall
                        && mLayoutHolder.getOfficialLayerHolder().getAUIAICallAgentType() != AUIAICallType.AUIAICallTypeOutboundCall) {
                    AIAgentSettingDialog.show(AUIAICallEntranceActivity.this, new AIAgentSettingDialog.IAIVoicePrintRecordListener() {
                        @Override
                        public void onClick() {
                            jumpToVoicePrintRecordActivity();
                        }
                    });
                }
            }
        });
        mTvDebug = findViewById(R.id.tv_debug);
        if(BuildConfig.TEST_ENV_MODE) {
            mTvDebug.setVisibility(View.VISIBLE);
        }
        mTvDebug.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                if(BuildConfig.TEST_ENV_MODE) {
                    boolean showExtraConfig = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHOW_EXTRA_DEBUG_CONFIG, SettingStorage.DEFAULT_EXTRA_DEBUG_CONFIG);
                    if (showExtraConfig) {
                        showRobotIdDialog();
                    } else {
                        onSettingDialogTitleClicked();
                    }
                }
            }
        });

//        if(!SettingStorage.getInstance().getBoolean(SettingStorage.KEY_VOICE_PRINT_FIRST_RECORD_TIPS, false)) {
//            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
//                @Override
//                public void run() {
//                    showVoiceDialog(findViewById(R.id.config_bgm_view));
//                }
//            }, 1000);
//        }

        themeSwitchButton = findViewById(R.id.ib_theme);
        themeSwitchButton.setOnClickListener(v -> toggleTheme());

        PermissionX.init(this)
                .permissions(PermissionUtils.getPermissions())
                .request((allGranted, grantedList, deniedList) -> {
                    if(!allGranted) {
                        ToastHelper.showToast(AUIAICallEntranceActivity.this, R.string.permission_tips, Toast.LENGTH_SHORT);
                        finish();
                    } else {
                        onAllPermissionGranted();
                    }
                });
    }

    @Override
    protected void onResume() {
        super.onResume();
        featchRtcAuthToken();
    }

    @Override
    protected void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt(KEY_CURRENT_TAB_POSTION, currentTabPosition);
    }

   private void showVoiceDialog(View itemView) {
       // 加载布局
       LayoutInflater inflater = LayoutInflater.from(this);
       View popupView = inflater.inflate(R.layout.dialog_auiaicall_voice_print_popup_window, null);

       // 初始化PopupWindow
       int width = ConstraintLayout.LayoutParams.WRAP_CONTENT;
       int height = ConstraintLayout.LayoutParams.WRAP_CONTENT;
       boolean focusable = true; // 让弹出窗口获取焦点
       PopupWindow popupWindow = new PopupWindow(popupView, width, height, focusable);

       // 设置动画
       //popupWindow.setAnimationStyle(R.style.PopupAnimation);

       // 显示PopupWindow在屏幕右侧，距离右侧20dp
       int[] location = new int[2];
       itemView.getLocationOnScreen(location);

       // 获取itemView的高度
       int itemViewHeight = itemView.getHeight();

       // 转换20dp为像素值
       int twentyDpInPx = (int) (20 * getResources().getDisplayMetrics().density + 0.5f);

       // 获取屏幕宽度
       int screenWidth = getResources().getDisplayMetrics().widthPixels;

       // 获取PopupWindow的测量宽度（需要先measure）
       popupView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
       int popupWidth = popupView.getMeasuredWidth();

       // 计算X坐标：屏幕宽度 - Popup宽度 - 20dp = 右侧对齐并留出20dp边距
       int x = screenWidth - popupWidth - twentyDpInPx;

       // Y坐标保持在itemView下方
       int y = location[1] + itemViewHeight + twentyDpInPx;

       // 在指定位置显示PopupWindow
       popupWindow.showAtLocation(itemView, Gravity.NO_GRAVITY, x, y);

       SettingStorage.getInstance().setBoolean(SettingStorage.KEY_VOICE_PRINT_FIRST_RECORD_TIPS, true);
   }

    private void toggleTheme() {
        int currentMode = AppCompatDelegate.getDefaultNightMode();
        int newMode = currentMode == AppCompatDelegate.MODE_NIGHT_YES ? AppCompatDelegate.MODE_NIGHT_NO : AppCompatDelegate.MODE_NIGHT_YES;
        AppCompatDelegate.setDefaultNightMode(newMode);
        recreate();
    }

    private void featchRtcAuthToken() {

        AUIAICallAuthTokenHelper.getAICallAuthToken(mLoginUserId, mLoginAuthorization, new AUIAICallAuthTokenHelper.IAUIAICallAuthTokenCallback() {
            @Override
            public void onSuccess(JSONObject jsonObject) {

                try {
                    if (jsonObject.has("rtc_auth_token")) {
                        String rtcAuthToken = jsonObject.getString("rtc_auth_token");
                        if (!TextUtils.isEmpty(rtcAuthToken)) {
                            mRtcAuthToken = rtcAuthToken;
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
    }


    private boolean validateToken() {

        if (getIntent() != null && null != getIntent().getExtras()) {
            mLoginUserId = getIntent().getStringExtra("login_user_id");
            mLoginAuthorization = getIntent().getStringExtra("authorization");
            mInternalBuild = getIntent().getBooleanExtra("international_build", false);
        }
        if (TextUtils.isEmpty(mLoginUserId)) {
            // 建议绑定为业务的登录用户id
            mLoginUserId = "mock_user_id";
        }
        if (TextUtils.isEmpty(mLoginAuthorization)) {
            // 默认关闭appServer鉴权校验
            mLoginAuthorization = "mock_authorization";
        }
        Log.i("AUIAICALL", "validateToken: [user_id: " + mLoginUserId + ", authorization: " + mLoginAuthorization + "]");
        if (TextUtils.isEmpty(mLoginUserId) || TextUtils.isEmpty(mLoginAuthorization)) {
            return false;
        }

        return true;
    }

    private void jumpToInCallActivity() {
        AUIAICallType callType = mLayoutHolder.getOfficialLayerHolder().getAUIAICallAgentType();
        if(callType == AUIAICallType.AUIAICallTypeCustom) {
            // 自定义智能体
            boolean isUseTextInputMode = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_CUSTOM_AGENT_TEXT_INPUT_MODE, false);
            if(BuildConfig.TEST_ENV_MODE && isUseTextInputMode) {
                // 文本框输入Token体验
                startTextInputTokenMode();
            } else {
                // 扫码体验
                startCaptureActivityForResult();
            }

            return;
        }

        // Official Agent
        if(callType != AUIAICallType.AUIAICallTypeInboundCall && callType != AUIAICallType.AUIAICallTypeOutboundCall) {
            Intent intent = new Intent(AUIAICallEntranceActivity.this, mLayoutHolder.getOfficialLayerHolder().getAUIAICallAgentType() == AUIAICallType.AUIAICallTypeChatBot ? AUIAIChatInChatActivity.class:AUIAICallInCallActivity.class);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, mLoginUserId);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, mLoginAuthorization);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, mLayoutHolder.getOfficialLayerHolder().getAICallAgentType());
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_RTC_AUTH_TOKEN, mRtcAuthToken);
            boolean useEmotional = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_EMOTION, SettingStorage.DEFAULT_BOOT_ENABLE_EMOTION);
            boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
            String agentId = "";
            if(BuildConfig.TEST_ENV_MODE) {
                agentId = usePreHost ? AUIAICallAgentDebug.getAIAgentId(mLayoutHolder.getOfficialLayerHolder().getAICallAgentType(), useEmotional) :  AUIAICallAgentIdConfig.getAIAgentId(mLayoutHolder.getOfficialLayerHolder().getAICallAgentType(), useEmotional);
                String autoTestAgent = SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_AUTO_TEST_AGENT);
                if(!TextUtils.isEmpty(autoTestAgent)) {
                    agentId = autoTestAgent;
                }
            }
            else {
                agentId = AUIAICallAgentIdConfig.getAIAgentId(mLayoutHolder.getOfficialLayerHolder().getAICallAgentType(), useEmotional);
            }
            if(!TextUtils.isEmpty(agentId)) {
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, agentId);
            }
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_IS_SHARED_AGENT, false);
            startActivity(intent);
        } else if(callType == AUIAICallType.AUIAICallTypeInboundCall) {
            Intent intent = new Intent(AUIAICallEntranceActivity.this, AUIAICallPhoneCallInputActivity.class);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, mLoginUserId);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, mLoginAuthorization);

            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_IS_PSTN_IN, true);
            startActivity(intent);
        } else  {
            boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
            String agentId = "";
            if(BuildConfig.TEST_ENV_MODE) {
                agentId = usePreHost ? AUIAICallAgentDebug.getOutBoundAgentId() :  AUIAICallAgentIdConfig.getOutBoundAgentId();
            }
            else {
                agentId = AUIAICallAgentIdConfig.getOutBoundAgentId();
            }

            Intent intent = new Intent(AUIAICallEntranceActivity.this, AUIAICallPhoneCallInputActivity.class);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, mLoginUserId);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, mLoginAuthorization);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_IS_PSTN_IN, false);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, agentId);
            startActivity(intent);
        }
    }

    private void jumpToVoicePrintRecordActivity() {
        Intent intent = new Intent(AUIAICallEntranceActivity.this, AUIAICallVoicePrintRecordActivity.class);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, mLoginUserId);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, mLoginAuthorization);

        startActivity(intent);
    }

    private void onAllPermissionGranted() {

    }

    private void showRobotIdDialog() {
        View view = LayoutInflater.from(this).inflate(R.layout.dialog_aicall_entrance_setting, null, false);

        boolean showExtraDebugConfig = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHOW_EXTRA_DEBUG_CONFIG, SettingStorage.DEFAULT_EXTRA_DEBUG_CONFIG);

        ((EditText)view.findViewById(R.id.et_robot_id)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_ROBOT_ID));
        ((Switch)view.findViewById(R.id.sv_deposit)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_DEPOSIT_SWITCH, SettingStorage.DEFAULT_DEPOSIT_SWITCH));
        ((Switch)view.findViewById(R.id.sv_use_appserver_start_agent)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_USE_APP_SERVER_START_AGENT, SettingStorage.DEFAULT_USE_APPSERVER_START_AGENT));
        ((Switch)view.findViewById(R.id.sv_audio_dump)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH));
        ((Switch)view.findViewById(R.id.sv_audio_tip)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_AUDIO_TIPS_SWITCH));
        ((Switch)view.findViewById(R.id.sv_server_type)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE));
        ((Switch)view.findViewById(R.id.sv_use_rtc_pre_env)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_USE_RTC_PRE_ENV_SWITCH, SettingStorage.DEFAULT_USE_RTC_PRE_ENV));
        ((Switch)view.findViewById(R.id.sv_boot_push_to_talk)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_PUSH_TO_TALK, SettingStorage.DEFAULT_ENABLE_PUSH_TO_TALK));
        ((Switch)view.findViewById(R.id.sv_boot_use_audio_delay_info)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_AUDIO_DELAY_INFO, true));
        ((Switch)view.findViewById(R.id.sv_boot_enable_agent_auto_exit)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_AGENT_AUTO_EXIT, true));
        ((Switch)view.findViewById(R.id.sv_boot_enable_enable_semantic)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_SEMATNIC, true));
        ((Switch)view.findViewById(R.id.sv_boot_enable_audio_aec)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_AUDIO_AEC, true));
        ((Switch)view.findViewById(R.id.sv_boot_enable_llm_complete_reply)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_LLM_COMPLETE_REPLY, false));
        ((Switch)view.findViewById(R.id.sv_boot_enable_brust_send_recv)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_BRUST_SEND_RECV, true));
        ((Switch)view.findViewById(R.id.sv_boot_enable_screen_track)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_SCREEN_TRACK_SENG, false));


        //((Switch)view.findViewById(R.id.sv_boot_use_voice_print)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_VOICE_PRINT, SettingStorage.DEFAULT_ENABLE_VOICE_PRINT));
        ((Switch)view.findViewById(R.id.sv_share_boot_use_demo_app_server)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHARE_BOOT_USE_DEMO_APP_SERVER, SettingStorage.DEFAULT_SHARE_BOOT_USE_DEMO_APP_SERVER));
        ((Switch)view.findViewById(R.id.sv_custom_agent_text_input_mode)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_CUSTOM_AGENT_TEXT_INPUT_MODE, false));
        ((EditText)view.findViewById(R.id.et_boot_user_data)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_USER_EXTEND_DATA));

        ((EditText) view.findViewById(R.id.enable_voice_interrupt_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_ENABLE_VOICE_INTERRUPT, "1"));
        ((EditText) view.findViewById(R.id.voice_id_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_VOICE_ID));
        ((EditText) view.findViewById(R.id.UserOfflineTimeout_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_USER_OFFLINE_TIMEOUT, "5"));
        ((EditText) view.findViewById(R.id.MaxIdleTime_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_MAX_IDLE_TIME, "600"));
        ((EditText) view.findViewById(R.id.WorkflowOverrideParams_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_WORK_FLOW_OVERRIDE_PARAMS));
        ((EditText) view.findViewById(R.id.BailianAppParams_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BAILIAN_APP_PARAMS));
        ((EditText) view.findViewById(R.id.Volume_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_VOLUME, "100"));
        ((EditText) view.findViewById(R.id.Greeting_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_GREETING));
        ((EditText) view.findViewById(R.id.VoiceprintId_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_VOICE_PRINT_ID));
        ((EditText) view.findViewById(R.id.EnableIntelligentSegment_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_ENABLE_INTELLIGENT_SEGMENT, "1"));
        ((EditText) view.findViewById(R.id.AvatarId_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_AVATAR_ID));
        ((EditText) view.findViewById(R.id.AsrMaxSilence_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_ASR_MAX_SILENCE, "400"));
        ((EditText) view.findViewById(R.id.UserOnlineTimeout_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_USER_ONLINE_TIME_OUT, "60"));
        ((EditText) view.findViewById(R.id.asrLanguage_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_USER_ASR_LANGUAGE, ""));
        ((EditText) view.findViewById(R.id.llmSystemPrompt_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_LLM_SYSTEM_PROMPT));
        ((EditText) view.findViewById(R.id.llm_history_limit_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_LLM_HISTORY_LIMIT, "10"));
        ((EditText) view.findViewById(R.id.interrupt_words_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_INTERRUPT_WORDS, ""));
        ((EditText) view.findViewById(R.id.vad_level_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_VAD_LEVEL, "11"));
        ((EditText) view.findViewById(R.id.asr_hot_words_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_ASR_HOT_WORDS, ""));
        ((EditText) view.findViewById(R.id.turn_end_words_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_TURN_END_WORDS, ""));
        ((EditText) view.findViewById(R.id.asr_customparams_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_ASR_CUSTOM_PARAMS, ""));
        ((EditText) view.findViewById(R.id.tts_pronunciation_rules_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_PRONUNCIATION_RULES, ""));
        ((EditText) view.findViewById(R.id.vcr_config_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_VCR_CONFIG_RULES, ""));
        ((EditText) view.findViewById(R.id.semantic_duration_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_SEMATNIC_DURATION, "-1"));
        ((EditText) view.findViewById(R.id.vad_duration_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_VAD_DURATION, "0"));
        ((EditText) view.findViewById(R.id.speech_rate_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_TTS_SPEECH_RATE, "1.0"));
        ((EditText) view.findViewById(R.id.tts_language_id_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_TTS_LANGUAGE_ID, ""));
        ((EditText) view.findViewById(R.id.tts_emotion_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_TTS_EMOTION, ""));
        ((EditText) view.findViewById(R.id.openai_extra_query_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_OPENAI_EXTRA_QUERY, ""));
        ((EditText) view.findViewById(R.id.ambient_config_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_AMBIENT_CONFIG, ""));
        ((EditText) view.findViewById(R.id.pre_connect_audio_url_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_PRE_CONNECT_AUDIO_URL, ""));
        ((EditText) view.findViewById(R.id.output_min_length_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_OUTPUT_MIN_LENGTH, "-1"));
        ((EditText) view.findViewById(R.id.output_max_delay_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_OUTPUT_MAX_DELAY, "-1"));
        ((EditText) view.findViewById(R.id.auto_test_agent_id_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_AUTO_TEST_AGENT, ""));
        ((EditText) view.findViewById(R.id.experimental_config_input)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_EXPERIMENTAL_CONFIG, ""));


        if (!showExtraDebugConfig) {
            view.findViewById(R.id.ll_audio_dump).setVisibility(View.GONE);
            view.findViewById(R.id.ll_server_type).setVisibility(View.GONE);
        }

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(this)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.CENTER)
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnClickListener((dialog1, v) -> {
                    if (v.getId() == R.id.btn_confirm) {
                        String robotId = ((EditText)findViewById(R.id.et_robot_id)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_ROBOT_ID, robotId);

                        boolean isAudioDumpEnable = ((Switch)view.findViewById(R.id.sv_audio_dump)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH, isAudioDumpEnable);

                        boolean isAudioTipsEnable = ((Switch)view.findViewById(R.id.sv_audio_tip)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_AUDIO_TIPS_SWITCH, isAudioTipsEnable);

                        boolean usePreAppServer = ((Switch)view.findViewById(R.id.sv_server_type)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_APP_SERVER_TYPE, usePreAppServer);

                        boolean useDeposit = ((Switch)view.findViewById(R.id.sv_deposit)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_DEPOSIT_SWITCH, useDeposit);

                        boolean useAppServerStartAgent = ((Switch)view.findViewById(R.id.sv_use_appserver_start_agent)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_USE_APP_SERVER_START_AGENT, useAppServerStartAgent);

                        boolean useRtcPreEnv = ((Switch)view.findViewById(R.id.sv_use_rtc_pre_env)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_USE_RTC_PRE_ENV_SWITCH, useRtcPreEnv);

                        boolean bootEnablePushToTalk = ((Switch)view.findViewById(R.id.sv_boot_push_to_talk)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_PUSH_TO_TALK, bootEnablePushToTalk);

                        boolean useAudioDelayInfo = ((Switch)view.findViewById(R.id.sv_boot_use_audio_delay_info)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_AUDIO_DELAY_INFO, useAudioDelayInfo);

                        boolean enableAgentAutoExit = ((Switch)view.findViewById(R.id.sv_boot_enable_agent_auto_exit)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_AGENT_AUTO_EXIT, enableAgentAutoExit);

                        boolean enableSemantic = ((Switch)view.findViewById(R.id.sv_boot_enable_enable_semantic)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_SEMATNIC, enableSemantic);

                        boolean audioAec = ((Switch)view.findViewById(R.id.sv_boot_enable_audio_aec)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_AUDIO_AEC, audioAec);

                        boolean llmComplete = ((Switch)view.findViewById(R.id.sv_boot_enable_llm_complete_reply)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_LLM_COMPLETE_REPLY, llmComplete);

                        boolean enableBrust = ((Switch)view.findViewById(R.id.sv_boot_enable_brust_send_recv)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_BRUST_SEND_RECV, enableBrust);

                        boolean enableScreenTrack = ((Switch)view.findViewById(R.id.sv_boot_enable_screen_track)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_SCREEN_TRACK_SENG, enableScreenTrack);

                        //boolean bootUseVoicePrint = ((Switch)view.findViewById(R.id.sv_boot_use_voice_print)).isChecked();
                        //SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_VOICE_PRINT, bootUseVoicePrint);

                        boolean shareBootUseDemoAppServer = ((Switch)view.findViewById(R.id.sv_share_boot_use_demo_app_server)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_SHARE_BOOT_USE_DEMO_APP_SERVER, shareBootUseDemoAppServer);

                        // 自动化要求自定义智能体以文本框输入的方式进入而不是扫码体验
                        boolean isCustomAgentTextInputMode = ((Switch)view.findViewById(R.id.sv_custom_agent_text_input_mode)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_CUSTOM_AGENT_TEXT_INPUT_MODE, isCustomAgentTextInputMode);

                        String bootUserExtendData = ((EditText)view.findViewById(R.id.et_boot_user_data)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_USER_EXTEND_DATA, bootUserExtendData);

                        String bootEnableVoiceInterrupt = ((EditText)view.findViewById(R.id.enable_voice_interrupt_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_ENABLE_VOICE_INTERRUPT, bootEnableVoiceInterrupt);

                        String bootVoiceId = ((EditText)view.findViewById(R.id.voice_id_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_VOICE_ID, bootVoiceId);

                        String bootUserOfflineTimeout = ((EditText)view.findViewById(R.id.UserOfflineTimeout_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_USER_OFFLINE_TIMEOUT, bootUserOfflineTimeout);

                        String bootMaxIdleTime = ((EditText)view.findViewById(R.id.MaxIdleTime_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_MAX_IDLE_TIME, bootMaxIdleTime);

                        String bootWorkflowOverrideParams = ((EditText)view.findViewById(R.id.WorkflowOverrideParams_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_WORK_FLOW_OVERRIDE_PARAMS, bootWorkflowOverrideParams);

                        String bootBailianAppParams = ((EditText)view.findViewById(R.id.BailianAppParams_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_BAILIAN_APP_PARAMS, bootBailianAppParams);

                        String bootVolume = ((EditText)view.findViewById(R.id.Volume_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_VOLUME, bootVolume);

                        String bootGreeting = ((EditText)view.findViewById(R.id.Greeting_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_GREETING, bootGreeting);

                        String bootVoiceprintId = ((EditText)view.findViewById(R.id.VoiceprintId_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_VOICE_PRINT_ID, bootVoiceprintId);

                        String bootEnableIntelligentSegment = ((EditText)view.findViewById(R.id.EnableIntelligentSegment_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_ENABLE_INTELLIGENT_SEGMENT, bootEnableIntelligentSegment);

                        String bootAvatarId = ((EditText)view.findViewById(R.id.AvatarId_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_AVATAR_ID, bootAvatarId);

                        String bootAsrMaxSilence = ((EditText)view.findViewById(R.id.AsrMaxSilence_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_ASR_MAX_SILENCE, bootAsrMaxSilence);

                        String bootUserOnlineTimeout = ((EditText)view.findViewById(R.id.UserOnlineTimeout_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_USER_ONLINE_TIME_OUT, bootUserOnlineTimeout);

                        String bootAsrLanguage = ((EditText)view.findViewById(R.id.asrLanguage_input)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_USER_ASR_LANGUAGE, bootAsrLanguage);

                        SettingStorage.getInstance().set(SettingStorage.KEY_LLM_SYSTEM_PROMPT, ((EditText)view.findViewById(R.id.llmSystemPrompt_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_LLM_HISTORY_LIMIT, ((EditText)view.findViewById(R.id.llm_history_limit_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_INTERRUPT_WORDS, ((EditText)view.findViewById(R.id.interrupt_words_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_VAD_LEVEL, ((EditText)view.findViewById(R.id.vad_level_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_ASR_HOT_WORDS, ((EditText)view.findViewById(R.id.asr_hot_words_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_TURN_END_WORDS, ((EditText)view.findViewById(R.id.turn_end_words_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_ASR_CUSTOM_PARAMS, ((EditText)view.findViewById(R.id.asr_customparams_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_PRONUNCIATION_RULES, ((EditText)view.findViewById(R.id.tts_pronunciation_rules_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_VCR_CONFIG_RULES, ((EditText)view.findViewById(R.id.vcr_config_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_SEMATNIC_DURATION, ((EditText)view.findViewById(R.id.semantic_duration_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_VAD_DURATION, ((EditText)view.findViewById(R.id.vad_duration_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_TTS_SPEECH_RATE, ((EditText)view.findViewById(R.id.speech_rate_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_TTS_LANGUAGE_ID, ((EditText)view.findViewById(R.id.tts_language_id_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_TTS_EMOTION, ((EditText)view.findViewById(R.id.tts_emotion_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_OPENAI_EXTRA_QUERY, ((EditText)view.findViewById(R.id.openai_extra_query_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_TTS_MODEL_ID, ((EditText)view.findViewById(R.id.tts_model_id_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_AMBIENT_CONFIG, ((EditText)view.findViewById(R.id.ambient_config_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_PRE_CONNECT_AUDIO_URL, ((EditText)view.findViewById(R.id.pre_connect_audio_url_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_OUTPUT_MIN_LENGTH, ((EditText)view.findViewById(R.id.output_min_length_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_OUTPUT_MAX_DELAY, ((EditText)view.findViewById(R.id.output_max_delay_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_AUTO_TEST_AGENT, ((EditText)view.findViewById(R.id.auto_test_agent_id_input)).getText().toString());
                        SettingStorage.getInstance().set(SettingStorage.KEY_BOOT_EXPERIMENTAL_CONFIG, ((EditText)view.findViewById(R.id.experimental_config_input)).getText().toString());


                    }
                    if (v.getId() == R.id.btn_confirm || v.getId() == R.id.btn_cancel) {
                        dialog1.dismiss();
                        featchRtcAuthToken();
                    }
                    if (v.getId() == R.id.tv_dialog_title) {
                        onSettingDialogTitleClicked();
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

    private void onSettingDialogTitleClicked() {
        long now = SystemClock.elapsedRealtime();
        if (now - mLastSettingTapMillis > 500 || mLastSettingTapMillis == 0) {
            mLastSettingTapCount = 1;
        } else {
            mLastSettingTapCount++;
        }
        mLastSettingTapMillis = now;

        if (mLastSettingTapCount >= 3) {
            mLastSettingTapCount = 0;
            mLastSettingTapMillis = 0;
            boolean showExtraConfig = !SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHOW_EXTRA_DEBUG_CONFIG, SettingStorage.DEFAULT_EXTRA_DEBUG_CONFIG);

            if (showExtraConfig) {
                ToastHelper.showToast(this, R.string.debug_mode_enable, Toast.LENGTH_SHORT);
            } else {
                ToastHelper.showToast(this, R.string.debug_mode_disable, Toast.LENGTH_SHORT);
            }
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_SHOW_EXTRA_DEBUG_CONFIG, showExtraConfig);
            if (!showExtraConfig) {
                onExtraDebugConfigDisable();
            }
        }
    }

    private void onExtraDebugConfigDisable() {
        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH, false);
        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_AUDIO_TIPS_SWITCH, false);
        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_APP_SERVER_TYPE, false);
        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_USE_RTC_PRE_ENV_SWITCH, false);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(requestCode == CaptureActivity.REQ_CODE && data != null) {
            String token = data.getStringExtra(CaptureActivity.EXTRA_SCAN_RESULT);
            if(!TextUtils.isEmpty((token))) {
                handleCustomAgentToken(token);
            }
        }
//        switch (requestCode) {
//            case CaptureActivity.REQ_CODE:
//                switch (resultCode) {
//                    case RESULT_OK: {
//                        String token = data.getStringExtra(CaptureActivity.EXTRA_SCAN_RESULT);
//                        handleShareToken(token);
//                        break;
//                    }
//                    case RESULT_CANCELED: {
//                        if (data != null) {
//                            String token = data.getStringExtra(CaptureActivity.EXTRA_SCAN_RESULT);
//                            handleShareToken(token);
//                        }
//                        break;
//                    }
//                    default:
//                        break;
//                }
//                break;
//            default:
//                break;
//        }
    }

    private void startCaptureActivityForResult() {
        Intent intent = new Intent(this, CaptureActivity.class);
        Bundle bundle = new Bundle();
        bundle.putBoolean(CaptureActivity.KEY_NEED_BEEP, CaptureActivity.VALUE_BEEP);
        bundle.putBoolean(CaptureActivity.KEY_NEED_VIBRATION, CaptureActivity.VALUE_VIBRATION);
        bundle.putBoolean(CaptureActivity.KEY_NEED_EXPOSURE, CaptureActivity.VALUE_NO_EXPOSURE);
        bundle.putByte(CaptureActivity.KEY_FLASHLIGHT_MODE, CaptureActivity.VALUE_FLASHLIGHT_OFF);
        bundle.putByte(CaptureActivity.KEY_ORIENTATION_MODE, CaptureActivity.VALUE_ORIENTATION_AUTO);
        bundle.putBoolean(CaptureActivity.KEY_SCAN_AREA_FULL_SCREEN, CaptureActivity.VALUE_SCAN_AREA_FULL_SCREEN);
        bundle.putBoolean(CaptureActivity.KEY_NEED_SCAN_HINT_TEXT, CaptureActivity.VALUE_SCAN_HINT_TEXT);
        intent.putExtra(CaptureActivity.EXTRA_SETTING_BUNDLE, bundle);
        startActivityForResult(intent, CaptureActivity.REQ_CODE);
    }

    // 用于自动化，文本框输入Token
    private void startTextInputTokenMode() {
        EditText editText = new EditText(this);
        editText.setHint("请输入Token");
        editText.setMaxLines(3);
        editText.setMovementMethod(android.text.method.ScrollingMovementMethod.getInstance());
        editText.setInputType(android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_FLAG_MULTI_LINE);

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("输入Token")
                .setView(editText)
                .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        String token = editText.getText().toString().trim();
                        if (!TextUtils.isEmpty(token)) {
                            handleCustomAgentToken(token);
                        } else {
                            ToastHelper.showToast(AUIAICallEntranceActivity.this, "Token不能为空", Toast.LENGTH_SHORT);
                        }
                    }
                })
                .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                })
                .show();
    }

    private void handleCustomAgentToken(String token) {
        mEtCustomAgentCallToken = token;
        // 启动通话
        try {
            ARTCAIAgentUtil.ARTCAIAgentShareInfo shareInfo = ARTCAIAgentUtil.parseAiAgentShareInfo(mEtCustomAgentCallToken);
            if(shareInfo != null) {
                if (System.currentTimeMillis() <= shareInfo.expireTimestamp) {
                    ARTCAICallController.launchCallActivity(this, mEtCustomAgentCallToken, mLoginUserId, mLoginAuthorization);
                } else {
                    ToastHelper.showToast(this, R.string.token_expired_tips, Toast.LENGTH_SHORT);
                }
            } else {
                ToastHelper.showToast(this, "null shareInfo", Toast.LENGTH_SHORT);
            }
        } catch (Exception e) {
            e.printStackTrace();
            ToastHelper.showToast(this, "请输入正确的Token", Toast.LENGTH_SHORT);
        }
    }

    private class LayoutHolder implements View.OnClickListener {

        private ViewGroup mVGFunctionDetailOfficial = null;
        private OfficialLayerHolder mOfficialLayerHolder = new OfficialLayerHolder();

        private void init(Context context) {
            mVGFunctionDetailOfficial = findViewById(R.id.layer_function_detail_official);
            mOfficialLayerHolder.init(context);
        }

        @Override
        public void onClick(View v) {

        }

        private void setSelectedTextColor(GradientTextView gradientTextView, boolean selected) {
            if (null != gradientTextView) {
                if (selected) {
                    gradientTextView.setStartColor(0xFF4CA9F8);
                    gradientTextView.setEndColor(0xFF4DCFE1);
                } else {
                    gradientTextView.setStartColor(0);
                    gradientTextView.setEndColor(0);
                }
            }
        }

        public ARTCAICallEngine.ARTCAICallAgentType getAICallAgentType() {
            return mOfficialLayerHolder.getAICallAgentType();
        }

        public OfficialLayerHolder getOfficialLayerHolder() {
            return mOfficialLayerHolder;
        }
    }

    private static String aiCallAgentTypeTitle(Context context, AUIAICallType aICallAgentType) {
        switch (aICallAgentType) {
            case AUIAICallTypeVoiceChat:
                return context.getString(R.string.ai_audio_call);
            case AUIAICallTypeAvatarChat:
                return context.getString(R.string.digital_human_call);
            case AUIAICallTypeVisionChat:
                return context.getString(R.string.vision_agent_call);
            case AUIAICallTypeChatBot:
                return context.getString(R.string.chat_bot);
            case AUIAICallTypeVideoChat:
                return context.getString(R.string.video_agent_call);
            case AUIAICallTypeOutboundCall:
                return context.getString(R.string.phone_agent_call);
            case AUIAICallTypeInboundCall:
                return context.getString(R.string.phone_agent_in_call);
            case AUIAICallTypeCustom:
                return context.getString(R.string.custom_agent);
            default:
                break;
        }
        return "";
    }

    private static String aiCallAgentTypeDecription(Context context, AUIAICallType aICallAgentType) {
        switch (aICallAgentType) {
            case AUIAICallTypeVoiceChat:
                return context.getString(R.string.description_voice_call);
            case AUIAICallTypeAvatarChat:
                return context.getString(R.string.description_avatar_call);
            case AUIAICallTypeVisionChat:
                return context.getString(R.string.description_vision_call);
            case AUIAICallTypeChatBot:
                return context.getString(R.string.description_chatbot);
            case AUIAICallTypeVideoChat:
                return context.getString(R.string.description_video_call);
            case AUIAICallTypeOutboundCall:
                return context.getString(R.string.description_pstn_out_bound);
            case AUIAICallTypeInboundCall:
                return context.getString(R.string.description_pstn_in_bound);
            case AUIAICallTypeCustom:
                return context.getString(R.string.description_custom_agent);
            default:
                break;
        }
        return "";
    }

    private class OfficialLayerHolder {
        private AUIAICallType mAICallAgentType = AUIAICallType.AUIAICallTypeVoiceChat;
        private TabLayout mTabCallType = null;
        private ViewPager2 mViewPagerCallType = null;
        private List<AUIAICallType> mAUICallTypeList = new LinkedList<>();

        private Context mContext;

        private void init(Context context) {
            mAUICallTypeList.add(AUIAICallType.AUIAICallTypeVoiceChat);
            mAUICallTypeList.add(AUIAICallType.AUIAICallTypeAvatarChat);
            mAUICallTypeList.add(AUIAICallType.AUIAICallTypeVisionChat);
            mAUICallTypeList.add(AUIAICallType.AUIAICallTypeVideoChat);
            mAUICallTypeList.add(AUIAICallType.AUIAICallTypeChatBot);
            if(mShowPstnCallPage) {
                if(!mInternalBuild) {
                    mAUICallTypeList.add(AUIAICallType.AUIAICallTypeOutboundCall);
                    mAUICallTypeList.add(AUIAICallType.AUIAICallTypeInboundCall);
                }
            }
            mAUICallTypeList.add(AUIAICallType.AUIAICallTypeCustom);

            mContext = context;

            mTabCallType = findViewById(R.id.tab_function_detail_call_type);
            mViewPagerCallType = findViewById(R.id.viewpager_function_detail_call_type);

            ViewPagerAdapter adapter = new ViewPagerAdapter((AppCompatActivity) context);
            for (AUIAICallType aiCallAgentType : mAUICallTypeList) {
                adapter.addFragment(aiCallAgentType, aiCallAgentTypeTitle(context, aiCallAgentType));
            }
            mViewPagerCallType.setAdapter(adapter);
            mViewPagerCallType.setOffscreenPageLimit(2);
            mViewPagerCallType.setPageTransformer(new StackGalleryPageTransformer());
            // 获取实际位置
            int actualPossition = adapter.getActualPosition(currentTabPosition);
            mAICallAgentType = mAUICallTypeList.get(actualPossition);
            setupTabLayout(adapter, actualPossition);

            mViewPagerCallType.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
                @Override
                public void onPageSelected(int position) {
                    super.onPageSelected(position);
                    currentTabPosition = position;
                    int actualPosition = adapter.getActualPosition(position);

                    if (mTabCallType.getTabCount() > actualPosition) {
                        mTabCallType.selectTab(mTabCallType.getTabAt(actualPosition));
                    }

                    mAICallAgentType = mAUICallTypeList.get(actualPosition);
                    if (mAICallAgentType == AUIAICallType.AUIAICallTypeInboundCall) {
                        mTVScanQR.setVisibility(View.GONE);
                        mTvCreateRoom.setText(R.string.pstn_in_call_entrance_text);
                    } else if (mAICallAgentType == AUIAICallType.AUIAICallTypeCustom) {
                        mTvCreateRoom.setText(R.string.custom_agent_room_entrance_text);
                        mTVScanQR.setVisibility(View.VISIBLE);
                    } else {
                        mTVScanQR.setVisibility(View.GONE);
                        mTvCreateRoom.setText(R.string.room_entrance_text);
                    }
                    updateAgentInfo(actualPosition);
                }
            });
            // 首次更新viewpager页面
            mViewPagerCallType.setCurrentItem(currentTabPosition, false);
        }

        private void setupTabLayout(ViewPagerAdapter adapter, int actualPosition) {
            mTabCallType.removeAllTabs();

            for (int i = 0; i < mAUICallTypeList.size(); i++) {
                TabLayout.Tab tab = mTabCallType.newTab().setCustomView(R.layout.tab_title_custom_text_view);
                View tabView = tab.getCustomView();
                if (tabView != null) {
                    TextView textView = tabView.findViewById(R.id.tab_title);
                    View indicator = tabView.findViewById(R.id.tab_indicator);
                    textView.setText(adapter.getPageTitle(i));
                    if (i == actualPosition) {
                        textView.setTypeface(null, Typeface.BOLD);
                        indicator.setVisibility(View.VISIBLE);
                    } else {
                        textView.setTypeface(null, Typeface.NORMAL);
                        indicator.setVisibility(View.INVISIBLE);
                    }
                }

                mTabCallType.addTab(tab);
            }

            // 默认选中第一个
            mTabCallType.selectTab(mTabCallType.getTabAt(currentTabPosition), false);
            // Tab 点击事件：跳转到 ViewPager 中对应位置（居中区域）
            mTabCallType.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
                @Override
                public void onTabSelected(TabLayout.Tab tab) {
                    View tabView = tab.getCustomView();
                    if(tabView != null) {
                        TextView textView = tabView.findViewById(R.id.tab_title);
                        textView.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
                        tabView.findViewById(R.id.tab_indicator).setVisibility(View.VISIBLE);
                    }
                    int actualPosition = tab.getPosition();
                    int targetVirtualPosition = adapter.getInitialPosition() + actualPosition;
                    // 防止重复设置触发 onPageSelected
                    if (mViewPagerCallType.getCurrentItem() != targetVirtualPosition) {
                        mViewPagerCallType.setCurrentItem(targetVirtualPosition, false);
                    }
                }

                @Override
                public void onTabUnselected(TabLayout.Tab tab) {
                    View tabView = tab.getCustomView();
                    if (tabView != null) {
                        TextView textView = tabView.findViewById(R.id.tab_title);
                        textView.setTypeface(Typeface.DEFAULT);
                        tabView.findViewById(R.id.tab_indicator).setVisibility(View.INVISIBLE);
                    }
                }

                @Override
                public void onTabReselected(TabLayout.Tab tab) {
                    // 可选：双击滚动到顶部或其他操作
                }
            });
        }

        // 跟随Tab更新智能体介绍
        private void updateAgentInfo(int position) {
            TextView agentNameText = findViewById(R.id.tv_agent_name);
            TextView agentIndexText = findViewById(R.id.tv_agent_index);
            TextView agentDescription = findViewById(R.id.tv_agent_description);
            agentNameText.setText(aiCallAgentTypeTitle(mContext, mAUICallTypeList.get(position)));
            String indexMsg = String.format(java.util.Locale.getDefault(), "[. %02d_%02d]", position + 1, mAUICallTypeList.size());
            agentIndexText.setText(indexMsg);

            agentDescription.setText(aiCallAgentTypeDecription(mContext, mAUICallTypeList.get(position)));
        }

        public AUIAICallType getAUIAICallAgentType() {
            return mAICallAgentType;
        }

        public ARTCAICallEngine.ARTCAICallAgentType getAICallAgentType() {
            switch (mAICallAgentType) {
                case AUIAICallTypeVoiceChat:
                    return ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
                case AUIAICallTypeAvatarChat:
                    return ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent;
                case AUIAICallTypeVisionChat:
                    return ARTCAICallEngine.ARTCAICallAgentType.VisionAgent;
                case AUIAICallTypeChatBot:
                    return ARTCAICallEngine.ARTCAICallAgentType.ChatBot;
                case AUIAICallTypeVideoChat:
                    return ARTCAICallEngine.ARTCAICallAgentType.VideoAgent;
            }
            return ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
        }
    }

    private static class ViewPagerAdapter extends FragmentStateAdapter {
        private final List<AUIAICallType> fragmentTypeList = new ArrayList<>();
        private final List<String> fragmentTitleList = new ArrayList<>();
        private static final int INFINITE_COUNT = 10;

        public ViewPagerAdapter(AppCompatActivity activity) {
            super(activity);
        }

        @Override
        public int getItemCount() {
            return fragmentTypeList.isEmpty() ? 0 : fragmentTypeList.size() * INFINITE_COUNT;
        }

        @NonNull
        @Override
        public Fragment createFragment(int position) {
            int actualPosition = position % fragmentTypeList.size();
            return OfficialCallPreviewFragment.newInstance(fragmentTypeList.get(actualPosition));
        }

        public void addFragment(AUIAICallType callAgentType, String title) {
            fragmentTypeList.add(callAgentType);
            fragmentTitleList.add(title);
        }

        public CharSequence getPageTitle(int position) {
            int actualPosition = position % fragmentTitleList.size();
            return fragmentTitleList.get(actualPosition);
        }

        // 获取实际位置
        public int getActualPosition(int position) {
            return fragmentTypeList.isEmpty() ? 0 : position % fragmentTypeList.size();
        }

        // 获取初始位置，中间
        public int getInitialPosition() {
            if (fragmentTypeList.isEmpty()) return 0;
            return (INFINITE_COUNT / 2) * fragmentTypeList.size();
        }
    }

    public class StackGalleryPageTransformer implements ViewPager2.PageTransformer {

        private static final float SCALE_FACTOR = 0.9f;
        private static final float ALPHA_FACTOR = 1.0f;
        private static final float TRANSLATION_X_OFFSET = 80f;
        private static final float VERTICAL_OFFSET = 0f;

        @Override
        public void transformPage(@NonNull View page, float position) {
            float pageWidth = page.getWidth();
            float pageHeight = page.getHeight();

            if (position < 0) {
                // 完全不可见的左侧页面
                page.setAlpha(0f);
                page.setTranslationX(-pageWidth * 0.5f);
                page.setTranslationY(pageHeight * 0.5f);
                page.setScaleX(0.7f);
                page.setScaleY(0.7f);
            } else if (position <= 2) {
                float scaleFactor = SCALE_FACTOR + (1 - SCALE_FACTOR) * (1 - position);
                page.setScaleX(scaleFactor);
                page.setScaleY(scaleFactor);
                page.setAlpha(ALPHA_FACTOR);
                page.setTranslationX(-pageWidth * position * 1.15f);
                page.setTranslationY(-VERTICAL_OFFSET * Math.abs(position));

                // Z 轴分层（Android 5.0+）
                page.setTranslationZ(10 * (1 - Math.abs(position)));

            } else {
                // 完全不可见的右侧页面
                page.setAlpha(0f);
                page.setTranslationX(pageWidth * 0.5f);
                page.setTranslationY(pageHeight * 0.5f);
                page.setScaleX(0.7f);
                page.setScaleY(0.7f);
            }
        }
    }

    public static class OfficialCallPreviewFragment extends Fragment {
        private AUIAICallType mCallAgentType;
        private ImageView mIvPreview;

        public OfficialCallPreviewFragment() {}

        private OfficialCallPreviewFragment(AUIAICallType callAgentType) {
            this.mCallAgentType = callAgentType;
        }

        public static OfficialCallPreviewFragment newInstance(AUIAICallType callAgentType) {
            OfficialCallPreviewFragment fragment = new OfficialCallPreviewFragment(callAgentType);
            Bundle args = new Bundle();
            args.putString("callAgentType", callAgentType.name());
            fragment.setArguments(args);
            return fragment;
        }

        private void printLifeCycle(String lifeCycle) {
            Log.i("OfficialCallPreview", lifeCycle);
        }

        @Nullable
        @Override
        public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
            printLifeCycle("onCreateView");

            View view = inflater.inflate(R.layout.layout_fragment_aicall_preview, container, false);
            mIvPreview = view.findViewById(R.id.iv_entrance_preview);
            if (mCallAgentType == AUIAICallType.AUIAICallTypeAvatarChat) {
                mIvPreview.setImageResource(R.drawable.bg_entrance_avatar_agent);
            } else if (mCallAgentType == AUIAICallType.AUIAICallTypeVisionChat) {
                mIvPreview.setImageResource(R.drawable.bg_entrance_vision_agent);
            } else if(mCallAgentType == AUIAICallType.AUIAICallTypeChatBot) {
                mIvPreview.setImageResource(R.drawable.bg_entrance_chatbot_agent);
            } else if(mCallAgentType == AUIAICallType.AUIAICallTypeVideoChat) {
                mIvPreview.setImageResource(R.drawable.bg_entrance_video_agent);
            } else if(mCallAgentType == AUIAICallType.AUIAICallTypeVoiceChat) {
                mIvPreview.setImageResource(R.drawable.bg_entrance_voice_agent);
            } else if(mCallAgentType == AUIAICallType.AUIAICallTypeInboundCall) {
                mIvPreview.setImageResource(R.drawable.bg_entrance_pstn_in);
            } else if(mCallAgentType == AUIAICallType.AUIAICallTypeOutboundCall) {
                mIvPreview.setImageResource(R.drawable.bg_entrance_pstn_out);
            } else {
                mIvPreview.setImageResource(R.drawable.bg_entrance_custom_agent);
            }
            return view;
        }

        @Override
        public void onDestroyView() {
            super.onDestroyView();
            printLifeCycle("onDestroyView");
        }

        @Override
        public void onCreate(Bundle savedInstanceState) {
            printLifeCycle("onCreate");
            super.onCreate(savedInstanceState);
            if (getArguments() != null) {
                String callAgentTypeName = getArguments().getString("callAgentType");
                mCallAgentType = AUIAICallType.valueOf(callAgentTypeName);
            }
        }

        @Override
        public void onAttach(Context context) {
            printLifeCycle("onAttach");
            super.onAttach(context);
        }

        @Override
        public void onDetach() {
            printLifeCycle("onDetach");
            super.onDetach();
        }

        @Override
        public void onDestroy() {
            printLifeCycle("onDestroy");
            super.onDestroy();
        }

        @Override
        public void onStart() {
            printLifeCycle("onStart");
            super.onStart();
        }

        @Override
        public void onStop() {
            printLifeCycle("onStop");
            super.onStop();
        }

        @Override
        public void onResume() {
            printLifeCycle("onResume");
            super.onResume();
        }

        @Override
        public void onPause() {
            printLifeCycle("onPause");
            super.onPause();
        }

        @Override
        public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
            printLifeCycle("onViewCreated");
            super.onViewCreated(view, savedInstanceState);
        }
    }
}