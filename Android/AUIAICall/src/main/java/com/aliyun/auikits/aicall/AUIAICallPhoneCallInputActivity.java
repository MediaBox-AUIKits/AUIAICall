package com.aliyun.auikits.aicall;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.util.AUIAICallAgentDebug;
import com.aliyun.auikits.aicall.util.AUIAICallAgentIdConfig;
import com.aliyun.auikits.aicall.util.AUIAICallClipboardUtils;
import com.aliyun.auikits.aicall.util.AUIAICallManager;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.AICallPSTNSettingDialog;

import java.util.List;

public class AUIAICallPhoneCallInputActivity extends AppCompatActivity {

    private TextView mTitleTextView;
    private ImageView mIvBtnBack;
    private TextView mStartCallBtn;
    // 呼出
    LinearLayout mOutPhoneCallLayout;
    private LinearLayout mPstnVoiceSelectLayout;
    private TextView mPstnVoiceSelectTextView;
    private EditText mPstnOutNumberEditText;
    private SwitchCompat mSwitchInterrupt = null;

    // 呼入
    LinearLayout mInPhoneCallLayout;
    private TextView mPSTNInNumberEditText;

    private String mUserId;
    private String mAuth;
    private boolean isInboundCall = false;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_phone_call_input);

        // 获取参数
        if (getIntent().getExtras() != null) {
            mUserId = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID);
            mAuth = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION);
            isInboundCall = getIntent().getExtras().getBoolean(AUIAIConstStrKey.BUNDLE_KEY_IS_PSTN_IN, false);
        }

        // 初始化界面
        initViews();
    }

    private void initViews() {
        mTitleTextView = findViewById(R.id.tv_ai_call_title);
        mIvBtnBack = findViewById(R.id.btn_back);
        mIvBtnBack.setOnClickListener(v -> finish());
        mStartCallBtn = findViewById(R.id.tv_start_call);
        mStartCallBtn.setOnClickListener(v -> jumpToIncallActivity());

        mOutPhoneCallLayout = findViewById(R.id.ll_out_call_input);
        mInPhoneCallLayout = findViewById(R.id.ll_in_call_input);

        if(isInboundCall) {
            // 呼入
            mInPhoneCallLayout.setVisibility(View.VISIBLE);
            mOutPhoneCallLayout.setVisibility(View.GONE);

            mPSTNInNumberEditText = findViewById(R.id.et_pstn_in_called_number);
            mPSTNInNumberEditText.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                }

                @Override
                public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                    boolean isEmpty = TextUtils.isEmpty(charSequence);
                    mStartCallBtn.setEnabled(!isEmpty);
                    if(isEmpty) {
                        mStartCallBtn.setTextColor(getResources().getColor(R.color.color_text_disabled));
                    } else {
                        mStartCallBtn.setTextColor(getResources().getColor(R.color.color_text_inverse));
                    }
                }

                @Override
                public void afterTextChanged(Editable editable) {

                }
            });
            mTitleTextView.setText(R.string.phone_agent_in_call);
            mStartCallBtn.setText(R.string.pstn_in_call_entrance_text);

            findViewById(R.id.iv_pstn_in_copy).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    AUIAICallClipboardUtils.copyToClipboard(AUIAICallPhoneCallInputActivity.this, mPSTNInNumberEditText.getText().toString());
                    ToastHelper.showToast(AUIAICallPhoneCallInputActivity.this, R.string.pstn_in_call_number_copied, Toast.LENGTH_SHORT);
                }
            });

            findViewById(R.id.iv_pstn_in_get_number_again).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    fetchInBoundCallerNumber(mUserId, mAuth);
                }
            });

            fetchInBoundCallerNumber(mUserId, mAuth);
        } else {
            // 呼出
            mInPhoneCallLayout.setVisibility(View.GONE);
            mOutPhoneCallLayout.setVisibility(View.VISIBLE);

            mPstnOutNumberEditText = findViewById(R.id.et_pstn_out_called_number);
            mPstnOutNumberEditText.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                }
                @Override
                public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                    boolean isEmpty = TextUtils.isEmpty(charSequence);
                    mStartCallBtn.setEnabled(!isEmpty);
                    if(isEmpty) {
                        mStartCallBtn.setTextColor(getResources().getColor(R.color.color_text_disabled));
                    } else {
                        mStartCallBtn.setTextColor(getResources().getColor(R.color.color_text_inverse));
                    }
                }
                @Override
                public void afterTextChanged(Editable editable) {

                }
            });
            mSwitchInterrupt = findViewById(R.id.sv_pstn_out_interrupt_config);

            mTitleTextView.setText(R.string.phone_agent_call);
            mStartCallBtn.setText(R.string.room_entrance_text);

            mPstnVoiceSelectLayout = findViewById(R.id.ll_pstn_out_voice_select);
            mPstnVoiceSelectTextView = findViewById(R.id.tv_pstn_out_voice_value);
            List<AudioToneData> audioToneList = AICallPSTNSettingDialog.getDefaultAudioToneList(this);
            mPstnVoiceSelectTextView.setText(AICallPSTNSettingDialog.currentVoice);

            mPstnVoiceSelectLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    AICallPSTNSettingDialog.show(AUIAICallPhoneCallInputActivity.this, audioToneList, new AICallPSTNSettingDialog.AICallPSTNVoiceChangeListener() {
                        @Override
                        public void onVoiceChange(String voice) {
                            mPstnVoiceSelectTextView.setText(voice);
                        }
                    });
                }
            });
        }
    }

    private void jumpToIncallActivity() {
        if(isInboundCall) {
            String pstnInCallNumber = getPSTNInboundCallNumber();
            if(TextUtils.isEmpty(pstnInCallNumber)) {
                ToastHelper.showToast(AUIAICallPhoneCallInputActivity.this, R.string.pstn_in_call_number_vaild, Toast.LENGTH_SHORT);
                return;
            }

            Intent intent = new Intent(Intent.ACTION_DIAL);
            intent.setData(Uri.parse("tel:" + pstnInCallNumber));
            startActivity(intent);
        } else {
            String pstnCallNumber = getPSTNOutboundCallNumber();
            if(TextUtils.isEmpty(pstnCallNumber)) {
                ToastHelper.showToast(AUIAICallPhoneCallInputActivity.this, R.string.pstn_out_call_number_vaild, Toast.LENGTH_SHORT);
                return;
            }
            boolean isInterlligentInterrupt = getPSTNSmartInterrupt();
            String voiceId = getPSTNVoiceSelect();
            boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
            String agentId = "";
            if(BuildConfig.TEST_ENV_MODE) {
                agentId = usePreHost ? AUIAICallAgentDebug.getOutBoundAgentId() :  AUIAICallAgentIdConfig.getOutBoundAgentId();
            }
            else {
                agentId = AUIAICallAgentIdConfig.getOutBoundAgentId();
            }

            Intent intent = new Intent(AUIAICallPhoneCallInputActivity.this, AUIAICallInPhoneCallActivity.class);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_PSTN_OUT_NUMBER, pstnCallNumber);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, mUserId);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, agentId);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, mAuth);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_PSTN_SMART_INTERRUPT, isInterlligentInterrupt);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_PSTN_OUT_VOICE, voiceId);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_IS_SHARED_AGENT, false);
            startActivity(intent);
        }
    }

    private void fetchInBoundCallerNumber(String userId, String auth) {
        String agentId;
        boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
        if(BuildConfig.TEST_ENV_MODE) {
            agentId = usePreHost ? AUIAICallAgentDebug.getOutBoundAgentId() :  AUIAICallAgentIdConfig.getOutBoundAgentId();
        } else {
            agentId = AUIAICallAgentIdConfig.getOutBoundAgentId();
        }
        AUIAICallManager.getInBoundCallNumber(userId, auth, agentId, AUIAICallAgentDebug.getRegion(), new AUIAICallManager.IAUIAICallManagerBoundCallNumberCallback() {
            @Override
            public void onSuccess(String data) {
                if(data != null) {
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            mPSTNInNumberEditText.setText(data);
                        }
                    });

                }
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        ToastHelper.showToast(AUIAICallPhoneCallInputActivity.this, R.string.pstn_in_call_get_number_failed, Toast.LENGTH_SHORT);
                    }
                });
            }
        });
    }

    public String getPSTNOutboundCallNumber() {
        return mPstnOutNumberEditText.getText().toString();
    }

    public String getPSTNInboundCallNumber() {
        return mPSTNInNumberEditText.getText().toString();
    }

    public boolean getPSTNSmartInterrupt() {
        return mSwitchInterrupt.isChecked();
    }

    public String getPSTNVoiceSelect() {
        return AICallPSTNSettingDialog.currentAudioToneId;
    }
}
