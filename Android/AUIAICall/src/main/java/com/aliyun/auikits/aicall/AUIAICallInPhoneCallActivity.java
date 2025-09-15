package com.aliyun.auikits.aicall;

import static com.aliyun.auikits.aiagent.ARTCAICallEngine.ARTCAICallTurnDetectionMode.ARTCAICallTurnDetectionNormalMode;
import static com.aliyun.auikits.aiagent.ARTCAICallEngine.ARTCAICallTurnDetectionMode.ARTCAICallTurnDetectionSemanticMode;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Base64;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.util.AUIAICallAgentDebug;
import com.aliyun.auikits.aicall.util.AUIAICallAgentIdConfig;
import com.aliyun.auikits.aicall.util.AUIAICallClipboardUtils;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.AppServiceConst;
import com.aliyun.auikits.aicall.util.BizStatHelper;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.AICallNoticeDialog;
import com.aliyun.auikits.aicall.widget.AICallReportingDialog;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class AUIAICallInPhoneCallActivity extends AppCompatActivity {
    private static final String TAG = "AUIAICallInPhoneCallActivity";
    private ARTCAICallServiceImpl.AppServerService mAppServerService = null;
    private String appServerAddress = null;
    private String mUserId = null;
    private String mAuthorization = null;
    private String mPstnOutCallPhoneNumber = null;
    private String mPstnOutCallerPhoneNumber = null;
    private boolean mIsSmartInterrupt = true;
    private String mVoiceId = null;
    private String mAgentId = null;
    private String mAgentRegion = null;
    private String mInstanceId = null;
    private String mRequestId = null;

    private TextView mCallStatusTextView;
    private ImageView mCallStatusImageView;
    private TextView mCallInstanceIdTextView;
    private LinearLayout mCallStatusSuccessLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(com.chad.library.R.style.Theme_AppCompat_Light_NoActionBar);
        setContentView(R.layout.activity_auiaiphonecall_in_call);

        findViewById(R.id.btn_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mCallStatusTextView = findViewById(R.id.iv_call_tips);
        mCallStatusImageView = findViewById(R.id.iv_call_status_image);
        mCallInstanceIdTextView = findViewById(R.id.iv_call_instanceid);
        mCallStatusSuccessLayout = findViewById(R.id.iv_call_instanceid_layout);

       findViewById(R.id.iv_call_instanceid_copy).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AUIAICallClipboardUtils.copyToClipboard(AUIAICallInPhoneCallActivity.this, mInstanceId);
                ToastHelper.showToast(AUIAICallInPhoneCallActivity.this, R.string.pstn_out_call_instanceid_copied, Toast.LENGTH_SHORT);
            }
       });

        findViewById(R.id.btn_reporting).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AICallReportingDialog.showDialog(AUIAICallInPhoneCallActivity.this, new AICallReportingDialog.IReportingDialogDismissListener() {
                    @Override
                    public void onReportingSubmit(List<Integer> reportTypeStatIdList, String reportIssueDesc) {
                        commitReporting(reportTypeStatIdList, reportIssueDesc);
                    }

                    @Override
                    public void onDismiss(boolean hasSubmit) {
                        if (hasSubmit) {
                            String requestId = mInstanceId;
                            String content = getResources().getString(R.string.reporting_id_display, mInstanceId);
                            AICallNoticeDialog.showFunctionalDialog(AUIAICallInPhoneCallActivity.this,
                                    null, false, content, true,
                                    R.string.copy, new AICallNoticeDialog.IActionHandle() {
                                        @Override
                                        public void handleAction() {
                                            AUIAICallClipboardUtils.copyToClipboard(AUIAICallInPhoneCallActivity.this, mInstanceId);
                                            ToastHelper.showToast(AUIAICallInPhoneCallActivity.this, R.string.copied, Toast.LENGTH_SHORT);
                                        }
                                    }
                            );
                        }
                    }
                });
            }
        });


        boolean mIsSharedAgent = false;
        if (null != getIntent() && null != getIntent().getExtras()) {
            mUserId = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, null);
            mAuthorization = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, null);
            mPstnOutCallPhoneNumber = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_PSTN_OUT_NUMBER, null);
            mIsSmartInterrupt = getIntent().getExtras().getBoolean(AUIAIConstStrKey.BUNDLE_KEY_PSTN_SMART_INTERRUPT, true);
            mVoiceId = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_PSTN_OUT_VOICE, null);
            mIsSharedAgent =  getIntent().getExtras().getBoolean(AUIAIConstStrKey.BUNDLE_KEY_IS_SHARED_AGENT, false);
            mAgentRegion = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_REGION, null);
            mAgentId = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, null);
        }

        if(!TextUtils.isEmpty(mPstnOutCallPhoneNumber)) {
            Logger.i("AUIAICallInPhoneCallActivity onCreate pstnOutNumber:" + mPstnOutCallPhoneNumber);
        }

        if(TextUtils.isEmpty(mAgentRegion)) {
            if(!mIsSharedAgent) {
                mAgentRegion = AUIAICallAgentIdConfig.getRegion();
            }
        }

        boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);

        if(usePreHost) {
            appServerAddress = AUIAICallAgentDebug.PRE_HOST;
        } else {
            appServerAddress = AppServiceConst.HOST;
        }

        if(mAppServerService == null) {
            mAppServerService = new ARTCAICallServiceImpl.AppServerService(appServerAddress);
        }

        startPstnOutCall();


    }

    private void startPstnOutCall() {
        if(mAppServerService != null) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("user_id", mUserId);
                if(!TextUtils.isEmpty(mAgentId)) {
                    jsonObject.put("ai_agent_id", mAgentId);
                }
                if(!TextUtils.isEmpty(mAgentRegion)) {
                    jsonObject.put("region", mAgentRegion);
                }
                if(!TextUtils.isEmpty(mPstnOutCallPhoneNumber)) {
                    jsonObject.put("called_number", mPstnOutCallPhoneNumber);
                }

                ARTCAICallEngine.ARTCAICallAgentConfig agentConfig = new ARTCAICallEngine.ARTCAICallAgentConfig();
                agentConfig.asrConfig.asrMaxSilence = Integer.parseInt(SettingStorage.getInstance().get(SettingStorage.KEY_ASR_MAX_SILENCE, "400"));
                agentConfig.asrConfig.asrLanguageId = SettingStorage.getInstance().get(SettingStorage.KEY_USER_ASR_LANGUAGE);
                agentConfig.asrConfig.customParams = SettingStorage.getInstance().get(SettingStorage.KEY_ASR_CUSTOM_PARAMS);
                String asrHotWords = SettingStorage.getInstance().get(SettingStorage.KEY_ASR_HOT_WORDS);
                if(!TextUtils.isEmpty(asrHotWords)) {
                    agentConfig.asrConfig.asrHotWords = new ArrayList<String>();
                    if(asrHotWords.contains(",")) {
                        String[] inputs = asrHotWords.split(",");
                        if(inputs.length > 0) {
                            for(String input : inputs) {
                                agentConfig.asrConfig.asrHotWords.add(input);
                            }
                        }
                    } else {
                        agentConfig.asrConfig.asrHotWords.add(asrHotWords);
                    }
                }
                agentConfig.asrConfig.vadLevel = Integer.parseInt(SettingStorage.getInstance().get(SettingStorage.KEY_VAD_LEVEL, "11"));
                agentConfig.asrConfig.vadDuration = Integer.parseInt(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_VAD_DURATION, "0"));

                agentConfig.agentGreeting = SettingStorage.getInstance().get(SettingStorage.KEY_GREETING);
                agentConfig.llmConfig.bailianAppParams = SettingStorage.getInstance().get(SettingStorage.KEY_BAILIAN_APP_PARAMS);
                agentConfig.llmConfig.llmSystemPrompt = SettingStorage.getInstance().get(SettingStorage.KEY_LLM_SYSTEM_PROMPT);
                agentConfig.llmConfig.llmHistoryLimit = Integer.parseInt(SettingStorage.getInstance().get(SettingStorage.KEY_LLM_HISTORY_LIMIT, "10"));
                String interruptWorks = SettingStorage.getInstance().get(SettingStorage.KEY_INTERRUPT_WORDS);
                if(!TextUtils.isEmpty(interruptWorks)) {
                    agentConfig.interruptConfig.interruptWords = new ArrayList<String>();
                    if(interruptWorks.contains(",")) {
                        String[] inputs = interruptWorks.split(",");
                        if(inputs.length > 0) {
                            for(String input : inputs) {
                                agentConfig.interruptConfig.interruptWords.add(input);
                            }
                        }
                    } else {
                        agentConfig.interruptConfig.interruptWords.add(interruptWorks);
                    }
                }

                if(mIsSmartInterrupt) {
                    agentConfig.interruptConfig.enableVoiceInterrupt = true;
                } else {
                    agentConfig.interruptConfig.enableVoiceInterrupt = false;
                }
                agentConfig.ttsConfig.agentVoiceId = mVoiceId;
                agentConfig.ttsConfig.speechRate = Double.parseDouble(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_TTS_SPEECH_RATE, "1.0"));
                agentConfig.ttsConfig.languageId = SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_TTS_LANGUAGE_ID, "");
                agentConfig.ttsConfig.emotion = SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_TTS_EMOTION, "");
                agentConfig.ttsConfig.modelId = SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_TTS_MODEL_ID, "");

                String turnEndWords = SettingStorage.getInstance().get(SettingStorage.KEY_TURN_END_WORDS);
                if(!TextUtils.isEmpty(turnEndWords)) {
                    agentConfig.turnDetectionConfig.turnEndWords = new ArrayList<String>();
                    if(turnEndWords.contains(",")) {
                        String[] inputs = turnEndWords.split(",");
                        if(inputs.length > 0) {
                            for(String input : inputs) {
                                agentConfig.turnDetectionConfig.turnEndWords.add(input);
                            }
                        }
                    } else {
                        agentConfig.turnDetectionConfig.turnEndWords.add(turnEndWords);
                    }
                }

                agentConfig.turnDetectionConfig.mode = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_SEMATNIC, true) ? ARTCAICallTurnDetectionSemanticMode : ARTCAICallTurnDetectionNormalMode;
                String sematnicDuration = SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_SEMATNIC_DURATION, "-1");
                if(!TextUtils.isEmpty(sematnicDuration)) {
                    agentConfig.turnDetectionConfig.semanticWaitDuration = Integer.parseInt(sematnicDuration);
                }

                String ambientConfigStr = SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_AMBIENT_CONFIG);
                if(!TextUtils.isEmpty(ambientConfigStr)) {
                    JSONObject ambientConfigObject = new JSONObject(ambientConfigStr);
                    agentConfig.ambientConfig = new ARTCAICallEngine.ARTCAICallAgentAmbientConfig(ambientConfigObject);
                }


                agentConfig.enableIntelligentSegment = SettingStorage.getInstance().get(SettingStorage.KEY_ENABLE_INTELLIGENT_SEGMENT).equals("1") ? true:false;
                agentConfig.preConnectAudioUrl = SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_PRE_CONNECT_AUDIO_URL, "");
                agentConfig.llmConfig.outputMinLength = Integer.parseInt(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_OUTPUT_MIN_LENGTH, "-1"));
                agentConfig.llmConfig.outputMaxDelay = Integer.parseInt(SettingStorage.getInstance().get(SettingStorage.KEY_BOOT_OUTPUT_MAX_DELAY, "-1"));

                JSONObject outboundCallObject = new JSONObject();
                jsonObject.put("config",agentConfig.toData().toString());

                mAppServerService.postAsync(
                        appServerAddress,
                        "/api/v2/aiagent/startAIAgentOutboundCall",
                        mAuthorization,
                        jsonObject,
                        new ARTCAICallServiceImpl.IARTCAICallServiceCallback() {
                            @Override
                            public void onSuccess(JSONObject jsonObject) {
                                Logger.i("AUIAICallInPhoneCallActivity startPstnOutCall onSuccess:" + jsonObject.toString());

                                if(null != jsonObject) {
                                    try {

                                        if(jsonObject.has("request_id")) {
                                            mRequestId = jsonObject.getString("request_id");
                                        }

                                        if(jsonObject.has("instance_id")) {
                                            mInstanceId = jsonObject.getString("instance_id");
                                            notifyPstnOutCallSuccess();
                                        }

                                    }catch (JSONException e) {
                                        e.printStackTrace();
                                    }
                                }

                            }
                            @Override
                            public void onFail(int errorCode, String errorMsg) {
                                Logger.i("AUIAICallInPhoneCallActivity startPstnOutCall onFail:" + errorCode + ":" + errorMsg);
                                notifyPstnOutCallFailed(errorCode, errorMsg);
                            }
                        }
                );
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    private void notifyPstnOutCallSuccess() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mCallStatusSuccessLayout.setVisibility(View.VISIBLE);
                mCallStatusTextView.setText(R.string.pstn_out_call_tips);
                mCallStatusImageView.setImageResource(R.drawable.ic_pstn_call);
                mCallInstanceIdTextView.setText("ID " + mInstanceId);
            }
        });
    }

    private void notifyPstnOutCallFailed(int errorCode, String errorMsg) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mCallStatusSuccessLayout.setVisibility(View.GONE);
                String tips = getString(R.string.pstn_out_call_failed_tips) + ", errorCode: " + errorCode + ", errorMsg: " + errorMsg ;
                mCallStatusTextView.setText(tips);
                mCallStatusImageView.setImageResource(R.drawable.ic_pstn_call_failed);
            }
        });
    }


    private void commitReporting(List<Integer> reportTypeIdList, String otherTypeDesc) {

        if (null == reportTypeIdList || reportTypeIdList.isEmpty()) {
            return;
        }
        try {
            {
                JSONObject args = new JSONObject();
                args.put("req_id", mRequestId);
                args.put("aid", mAgentId);
                args.put("ains", mInstanceId);
                args.put("auid", mUserId);
                args.put("uid", mUserId);
                args.put("atype", "AgentOutboundCall");
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
                args.put("req_id", mRequestId);

                String allLog = Logger.getAllLogRecordStr();
                args.put("log_str", allLog);
                BizStatHelper.stat("2002", args.toString());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

}
