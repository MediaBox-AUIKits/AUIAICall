package com.aliyun.auikits.aicall;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Switch;
import android.widget.Toast;

import com.acker.simplezxing.activity.CaptureActivity;
import com.alibaba.android.arouter.facade.annotation.Route;
import com.aliyun.auikits.aicall.util.PermissionUtils;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.GradientTextView;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;
import com.permissionx.guolindev.PermissionX;

import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

@Route(path = "/aicall/AUIAICallEntranceActivity")
public class AUIAICallEntranceActivity extends AppCompatActivity {
    private String mLoginUserId = null;
    private String mLoginAuthorization = null;

    private long mLastSettingTapMillis = 0;
    private long mLastSettingTapCount = 0;

    private LayoutHolder mLayoutHolder = new LayoutHolder();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!validateToken()) {
            ToastHelper.showToast(this, R.string.tips_authorization_invalidate, Toast.LENGTH_LONG);
            finish();
        }

        SettingStorage.getInstance().init(this);

        setContentView(R.layout.activity_auiaicall);
        mLayoutHolder.init();

        findViewById(R.id.btn_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        findViewById(R.id.btn_create_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                jumpToInCallActivity();
            }
        });
        findViewById(R.id.btn_more).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean showExtraConfig = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHOW_EXTRA_DEBUG_CONFIG, SettingStorage.DEFAULT_EXTRA_DEBUG_CONFIG);
                if (showExtraConfig) {
                    showRobotIdDialog();
                } else {
                    onSettingDialogTitleClicked();
                }
            }
        });

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

    private boolean validateToken() {

        if (getIntent() != null && null != getIntent().getExtras()) {
            mLoginUserId = getIntent().getStringExtra("login_user_id");
            mLoginAuthorization = getIntent().getStringExtra("authorization");
        }
        Log.i("AUIAICALL", "validateToken: [user_id: " + mLoginUserId + ", authorization: " + mLoginAuthorization + "]");
        if (TextUtils.isEmpty(mLoginUserId) || TextUtils.isEmpty(mLoginAuthorization)) {
            return false;
        }

        return true;
    }

    private void jumpToInCallActivity() {
        boolean canJump = true;
        Intent intent = new Intent(AUIAICallEntranceActivity.this, AUIAICallInCallActivity.class);
        intent.putExtra(AUIAICallInCallActivity.BUNDLE_KEY_LOGIN_USER_ID, mLoginUserId);
        intent.putExtra(AUIAICallInCallActivity.BUNDLE_KEY_LOGIN_AUTHORIZATION, mLoginAuthorization);
        if (mLayoutHolder.isOfficial()) {
            intent.putExtra(AUIAICallInCallActivity.BUNDLE_KEY_AI_AGENT_TYPE, mLayoutHolder.isAudioCall());
        } else {
            if (System.currentTimeMillis() <= mLayoutHolder.getExpireTimestamp()) {
                intent.putExtra(AUIAICallInCallActivity.BUNDLE_KEY_AI_AGENT_TYPE, mLayoutHolder.isExperienceTokenAudioCall());
                intent.putExtra(AUIAICallInCallActivity.BUNDLE_KEY_AI_AGENT_ID, mLayoutHolder.getAiAgentId());
            } else {
                canJump = false;
                ToastHelper.showToast(AUIAICallEntranceActivity.this, R.string.token_expired_tips, Toast.LENGTH_SHORT);
            }
        }
        if (canJump) {
            startActivity(intent);
        }
    }

    private void onAllPermissionGranted() {

    }

    private void showRobotIdDialog() {
        View view = LayoutInflater.from(this).inflate(R.layout.dialog_aicall_entrance_setting, null, false);

        boolean showExtraDebugConfig = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHOW_EXTRA_DEBUG_CONFIG, SettingStorage.DEFAULT_EXTRA_DEBUG_CONFIG);

        ((EditText)view.findViewById(R.id.et_robot_id)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_ROBOT_ID));
        ((Switch)view.findViewById(R.id.sv_deposit)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_DEPOSIT_SWITCH, SettingStorage.DEFAULT_DEPOSIT_SWITCH));
        ((Switch)view.findViewById(R.id.sv_audio_dump_tip)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH));
        ((Switch)view.findViewById(R.id.sv_server_type)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE));

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

                        boolean isAudioDumpEnable = ((Switch)view.findViewById(R.id.sv_audio_dump_tip)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH, isAudioDumpEnable);

                        boolean usePreAppServer = ((Switch)view.findViewById(R.id.sv_server_type)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_APP_SERVER_TYPE, usePreAppServer);

                        boolean useDeposit = ((Switch)view.findViewById(R.id.sv_deposit)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_DEPOSIT_SWITCH, useDeposit);
                    }
                    if (v.getId() == R.id.btn_confirm || v.getId() == R.id.btn_cancel) {
                        dialog1.dismiss();
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
        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_APP_SERVER_TYPE, false);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            case CaptureActivity.REQ_CODE:
                switch (resultCode) {
                    case RESULT_OK: {
                        String token = data.getStringExtra(CaptureActivity.EXTRA_SCAN_RESULT);
                        handleShareToken(token);
                        break;
                    }
                    case RESULT_CANCELED: {
                        if (data != null) {
                            String token = data.getStringExtra(CaptureActivity.EXTRA_SCAN_RESULT);
                            handleShareToken(token);
                        }
                        break;
                    }
                    default:
                        break;
                }
                break;
            default:
                break;
        }
    }

    private void handleShareToken(String shareToken) {
        if (!TextUtils.isEmpty(shareToken)) {
            try {
                Log.i("AUIAICALL", "handleShareToken: [shareToken: " + shareToken + "]");
                byte[] decodeTokenBytes = Base64.decode(shareToken, Base64.DEFAULT);
                String decodeToken = new String(decodeTokenBytes);
                JSONObject jsonObject = new JSONObject(decodeToken);
                String requestId = jsonObject.optString("RequestId");
                String name = jsonObject.optString("Name");
                String aiAgentId = jsonObject.optString("TemporaryAIAgentId");
                String workflowType = jsonObject.optString("WorkflowType");
                String expireTime = jsonObject.optString("ExpireTime");
                long expireTimestamp = parseTimestamp(expireTime);
                if (System.currentTimeMillis() <= expireTimestamp) {
                    mLayoutHolder.setExperienceToken(shareToken);
                    mLayoutHolder.setAiAgentId(aiAgentId);
                    mLayoutHolder.setExpireTimestamp(expireTimestamp);
                    mLayoutHolder.setIsExperienceTokenAudioCall(!"AvatarChat3D".equals(workflowType));
                } else {
                    ToastHelper.showToast(this, R.string.token_expired_tips, Toast.LENGTH_SHORT);
                }
                Log.i("AUIAICALL", "handleShareToken: [decodeToken: " + decodeToken + "]");
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
    public static long parseTimestamp(String formatTime) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        long timestamp = 0;
        try {
            sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date date = sdf.parse(formatTime);
            timestamp = date.getTime();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return timestamp;
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

    private class LayoutHolder implements View.OnClickListener {
        private ViewGroup mVGFunctionBar = null;
        private GradientTextView mVGFunctionOfficial = null;
        private GradientTextView mVGFunctionCustom = null;
        private boolean mIsOfficial = true;

        private ViewGroup mLayerFunctionDetailCallType = null;
        private GradientTextView mTvAudioCall = null;
        private GradientTextView mTvDigitalHumanCall = null;
        private boolean mIsAudioCall = true;

        private ViewGroup mLayerFunctionDetailAgentId = null;
        private EditText mEtExperienceToken = null;
        private ImageView mIvExperienceTokenScan = null;
        private String mAiAgentId = null;
        private boolean mIsExperienceTokenAudioCall = true;
        private long mExpireTimestamp = 0;

        private ImageView mIvEntranceBackground = null;

        private void init() {
            mIvEntranceBackground = findViewById(R.id.iv_entrance_bg);

            mVGFunctionBar = findViewById(R.id.function_bar);
            mVGFunctionOfficial = findViewById(R.id.tv_function_official);
            mVGFunctionOfficial.setOnClickListener(this);
            mVGFunctionCustom = findViewById(R.id.tv_function_custom);
            mVGFunctionCustom.setOnClickListener(this);

            mLayerFunctionDetailCallType = findViewById(R.id.layer_function_detail_call_type);
            mTvAudioCall = findViewById(R.id.tv_audio_call);
            mTvAudioCall.setOnClickListener(this);
            mTvDigitalHumanCall = findViewById(R.id.tv_digital_human_call);
            mTvDigitalHumanCall.setOnClickListener(this);

            mLayerFunctionDetailAgentId = findViewById(R.id.layer_function_detail_agent_id);
            mEtExperienceToken = findViewById(R.id.et_experience_token);
            mEtExperienceToken.setEnabled(false);
            mIvExperienceTokenScan = findViewById(R.id.tv_experience_token_scan);
            mIvExperienceTokenScan.setOnClickListener(this);

            onFunctionOfficialClick();
            onDetailVoiceAgentCallClick();
        }

        @Override
        public void onClick(View v) {
            if (null != v) {
                if (v.equals(mVGFunctionOfficial)) {
                    onFunctionOfficialClick();
                } else if (v.equals(mVGFunctionCustom)) {
                    onFunctionCustomClick();
                } else if (v.equals(mTvAudioCall)) {
                    onDetailVoiceAgentCallClick();
                } else if (v.equals(mTvDigitalHumanCall)) {
                    onDetailAvatarAgentCallClick();
                } else if (v.equals(mIvExperienceTokenScan)) {
                    startCaptureActivityForResult();
                }
            }
        }

        private void onFunctionOfficialClick() {
            setSelectedTextColor(mVGFunctionOfficial, true);
            mVGFunctionOfficial.setBackgroundResource(R.drawable.bg_function_selector_selected);
            setSelectedTextColor(mVGFunctionCustom, false);
            mVGFunctionCustom.setBackgroundResource(0);
            mIsOfficial = true;

            mLayerFunctionDetailCallType.setVisibility(View.VISIBLE);
            mLayerFunctionDetailAgentId.setVisibility(View.GONE);

            mIvEntranceBackground.setVisibility(View.VISIBLE);
        }

        private void onFunctionCustomClick() {
            setSelectedTextColor(mVGFunctionOfficial, false);
            mVGFunctionOfficial.setBackgroundResource(0);
            setSelectedTextColor(mVGFunctionCustom, true);
            mVGFunctionCustom.setBackgroundResource(R.drawable.bg_function_selector_selected);
            mIsOfficial = false;

            mLayerFunctionDetailCallType.setVisibility(View.GONE);
            mLayerFunctionDetailAgentId.setVisibility(View.VISIBLE);

            mIvEntranceBackground.setVisibility(View.GONE);
        }

        private void onDetailVoiceAgentCallClick() {
            setSelectedTextColor(mTvAudioCall, true);
            mTvAudioCall.setBackgroundResource(R.drawable.btn_function_detail_selector_selected);
            setSelectedTextColor(mTvDigitalHumanCall, false);
            mTvDigitalHumanCall.setBackgroundResource(R.drawable.btn_function_detail_selector);
            mIvEntranceBackground.setImageResource(R.drawable.bg_entrance_voice_agent);
            mIsAudioCall = true;
        }

        private void onDetailAvatarAgentCallClick() {
            setSelectedTextColor(mTvAudioCall, false);
            mTvAudioCall.setBackgroundResource(R.drawable.btn_function_detail_selector);
            setSelectedTextColor(mTvDigitalHumanCall, true);
            mTvDigitalHumanCall.setBackgroundResource(R.drawable.btn_function_detail_selector_selected);
            mIvEntranceBackground.setImageResource(R.drawable.bg_entrance_avatar_agent);
            mIsAudioCall = false;
        }

        private String getExperienceToken() {
            String ret = "";
            if (null != mEtExperienceToken) {
                ret = mEtExperienceToken.getText().toString();
            }
            return ret;
        }

        private void setExperienceToken(String token) {
            if (null != mEtExperienceToken) {
                mEtExperienceToken.setText(token);
            }
        }

        public void setAiAgentId(String aiAgentId) {
            this.mAiAgentId = aiAgentId;
        }

        public String getAiAgentId() {
            return mAiAgentId;
        }

        public void setIsExperienceTokenAudioCall(boolean isExperienceTokenAudioCall) {
            this.mIsExperienceTokenAudioCall = isExperienceTokenAudioCall;
        }

        public boolean isExperienceTokenAudioCall() {
            return mIsExperienceTokenAudioCall;
        }

        public void setExpireTimestamp(long expireTimestamp) {
            this.mExpireTimestamp = expireTimestamp;
        }

        public long getExpireTimestamp() {
            return mExpireTimestamp;
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

        public boolean isAudioCall() {
            return mIsAudioCall;
        }

        public boolean isOfficial() {
            return mIsOfficial;
        }
    }

}