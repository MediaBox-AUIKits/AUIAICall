package com.aliyun.auikits.aicall;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;

import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.util.AppServiceConst;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.voiceprint.AUIAICallVoiceprintManager;
import com.aliyun.auikits.aicall.widget.InputEditDialog;
import com.aliyun.auikits.aicall.widget.OptionSelectorDialog;

import org.json.JSONObject;

import java.util.Arrays;
import java.util.List;

public class AUIAICallAgentSettingActivity extends AppCompatActivity {

    private String mLoginUserId;
    private String mLoginAuthorization;

    private TextView mNoEmotional;
    private TextView mEmotional;
    private TextView mVoicePrintTitle;
    private TextView mVoicePrintDesc;
    private LinearLayout mVoicePrintDetailLayout;
    private SwitchCompat mEnableVoicePrintSwitch;

    // 声纹模式切换相关控件
    private TextView mVoicePrintModePreRegister;
    private TextView mVoicePrintModeAutoRegister;
    private TextView mVoicePrintTips;
    private LinearLayout mVoicePrintStatusLayout;  // 状态区域父布局（ll_voiceprint_status_group）
    private View mRecordVoiceSelect;
    private TextView mDeleteVoicePrintButton;      // 删除声纹按钮

    // 新增配置项控件
    private SwitchCompat mSemanticBreakSwitch;
    private View mEagernessConfigLayout;
    private TextView mEagernessValue;
    private SwitchCompat mEnableVoiceInterruptSwitch;
    private SwitchCompat mBackChannelingSwitch;
    private SwitchCompat mAutoSpeechUserIdleSwitch;
    private View mAutoSpeechUserIdleWaitTimeLayout;
    private TextView mAutoSpeechUserIdleWaitTimeValue;
    private View mAutoSpeechUserIdleMaxRepeatsLayout;
    private TextView mAutoSpeechUserIdleMaxRepeatsValue;
    private View mBackgroundSoundLayout;
    private TextView mAmbientIdValue;

    private List<String> ambientVolumeType;
    private List<String> ambientVolumeIds = Arrays.asList("", "public_conversation", "public_customer_service", "public_park");
    private List<String> eagernessOptions;
    private List<String> eagernessValues = Arrays.asList("Low", "Medium", "High");

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_aiagent_setting);

        // 初始化背景音选项（支持多语言）
        ambientVolumeType = Arrays.asList(
                getString(R.string.ambient_option_none),
                getString(R.string.ambient_option_conversation),
                getString(R.string.ambient_option_customer_service),
                getString(R.string.ambient_option_outdoor_park)
        );

        // 初始化检测速度选项（支持多语言）
        eagernessOptions = Arrays.asList(
                getString(R.string.eagerness_option_low),
                getString(R.string.eagerness_option_medium),
                getString(R.string.eagerness_option_high)
        );

        // 透传过来的登录信息，用于跳转声纹录制页
        Intent intent = getIntent();
        if (intent != null) {
            mLoginUserId = intent.getStringExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID);
            mLoginAuthorization = intent.getStringExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION);
        }

        // 初始化声纹管理器
        AUIAICallVoiceprintManager mgr = AUIAICallVoiceprintManager.getInstance();
        mgr.init(getApplicationContext());
        if (!TextUtils.isEmpty(mLoginUserId)) {
            mgr.setUserId(mLoginUserId);
            boolean usePreHost = SettingStorage.getInstance()
                    .getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
            mgr.setPreEnv(usePreHost);
        }

        initViews();
        initState();
        initListeners();
    }

    @Override
    protected void onResume() {
        super.onResume();
        // 从声纹录制页返回时刷新状态文案
        updateVoicePrintStatusText();
    }

    private void initViews() {
        mNoEmotional = findViewById(R.id.tv_mode_not_emotional);
        mEmotional = findViewById(R.id.tv_mode_yes_emotional);
        mVoicePrintTitle = findViewById(R.id.tv_voiceprint_record_status);
        mVoicePrintDesc = findViewById(R.id.btn_record_voiceprint);
        mVoicePrintDetailLayout = findViewById(R.id.layout_voiceprint_detail);
        mEnableVoicePrintSwitch = findViewById(R.id.sv_voiceprint_switch);

        // 声纹模式切换控件
        mVoicePrintModePreRegister = findViewById(R.id.tv_voice_print_mode_pre_register);
        mVoicePrintModeAutoRegister = findViewById(R.id.tv_voice_print_mode_auto_register);
        mVoicePrintTips = findViewById(R.id.tv_voiceprint_record_tips);
        mVoicePrintStatusLayout = findViewById(R.id.ll_voiceprint_status_group);
        mRecordVoiceSelect = findViewById(R.id.iv_record_voice_select);
        mDeleteVoicePrintButton = findViewById(R.id.btn_delete_voiceprint);

        // 初始化新增配置项控件
        mSemanticBreakSwitch = findViewById(R.id.sv_semantic_break);
        mEagernessConfigLayout = findViewById(R.id.cl_layout_eagerness);
        mEagernessValue = findViewById(R.id.tv_eagerness_value);
        mEnableVoiceInterruptSwitch = findViewById(R.id.sv_voice_interrupt);
        mBackChannelingSwitch = findViewById(R.id.sv_back_channeling);
        mAutoSpeechUserIdleSwitch = findViewById(R.id.sv_auto_speech_user_idle);
        mAutoSpeechUserIdleWaitTimeLayout = findViewById(R.id.cl_layout_auto_speech_user_idle_wait_time);
        mAutoSpeechUserIdleWaitTimeValue = findViewById(R.id.tv_auto_speech_user_idle_wait_time_value);
        mAutoSpeechUserIdleMaxRepeatsLayout = findViewById(R.id.cl_layout_auto_speech_user_idle_max_repeats);
        mAutoSpeechUserIdleMaxRepeatsValue = findViewById(R.id.tv_auto_speech_user_idle_max_repeats_value);
        mBackgroundSoundLayout = findViewById(R.id.cl_layout_ambient);
        mAmbientIdValue = findViewById(R.id.tv_ambient_value);
    }

    private void initState() {
        // 情绪开关
        boolean defaultEmotion = SettingStorage.getInstance()
                .getBoolean(SettingStorage.KEY_BOOT_ENABLE_EMOTION,
                        SettingStorage.DEFAULT_BOOT_ENABLE_EMOTION);
        mNoEmotional.setSelected(!defaultEmotion);
        mEmotional.setSelected(defaultEmotion);

        // 声纹开关
        boolean enableVoicePrint = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_VOICE_PRINT,
                SettingStorage.DEFAULT_ENABLE_VOICE_PRINT);
        mEnableVoicePrintSwitch.setChecked(enableVoicePrint);
        mVoicePrintDetailLayout.setVisibility(enableVoicePrint ? View.VISIBLE : View.GONE);

        // 声纹录制状态文案
        updateVoicePrintStatusText();

        // 声纹模式（默认预注册）
        boolean isAutoRegister = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_VOICE_PRIINT_AUTO_REGISTER, false);
        updateVoicePrintMode(isAutoRegister);

        // 语义断句
        boolean semanticBreak = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_SEMATNIC, true);
        mSemanticBreakSwitch.setChecked(semanticBreak);
        updateSemanticBreakRelatedUI(semanticBreak);

        // 检测速度
        String eagernessConfig = SettingStorage.getInstance().getString(SettingStorage.KEY_BOOT_EAGERNESS_CONFIG, "Medium");
        int eagernessIndex = eagernessValues.indexOf(eagernessConfig);
        if (eagernessIndex != -1) {
            mEagernessValue.setText(eagernessOptions.get(eagernessIndex));
        } else {
            mEagernessValue.setText(eagernessOptions.get(1)); // 默认 Medium
        }

        // 智能打断
        boolean enableVoiceInterrupt = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_ENABLE_VOICE_INTERRUPT, true);
        mEnableVoiceInterruptSwitch.setChecked(enableVoiceInterrupt);

        // 附和语
        boolean backChanneling = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_BACK_CHANNELING, true);
        mBackChannelingSwitch.setChecked(backChanneling);

        // 主动问询
        boolean auto_speech = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_AGENT_AUTO_SPEECH_USER_IDLE, true);
        mAutoSpeechUserIdleSwitch.setChecked(auto_speech);
        updateAutoSpeechRelatedUI(auto_speech);

        // 等待时间
        int waitTime = SettingStorage.getInstance().getInt(SettingStorage.KEY_BOOT_AUTO_SPEECH_USER_IDLE_WAIT_TIME, 5000);
        mAutoSpeechUserIdleWaitTimeValue.setText(waitTime + " ms");

        // 问询次数
        int queryCount = SettingStorage.getInstance().getInt(SettingStorage.KEY_BOOT_AUTO_SPEECH_USER_IDLE_MAX_REPEATS, 10);
        mAutoSpeechUserIdleMaxRepeatsValue.setText(queryCount + " " + getString(R.string.auto_speech_user_idle_max_repeats_unit));

        // 通话背景音
        String ambientResourceId = SettingStorage.getInstance().getString(SettingStorage.KEY_BOOT_AMBIENT_RESOURCE_ID, "");
        int index = ambientVolumeIds.indexOf(ambientResourceId);
        if (index != -1) {
            mAmbientIdValue.setText(ambientVolumeType.get(index));
        } else {
            mAmbientIdValue.setText(ambientVolumeType.get(0));
        }
    }

    private void initListeners() {
        // 顶部返回区域：箭头 + 标题一起触发返回
        View backArea = findViewById(R.id.layout_back_area);
        if (backArea != null) {
            backArea.setOnClickListener(v -> onBackPressed());
        }

        // 情绪模式：非情绪
        mNoEmotional.setOnClickListener(v -> {
            mEmotional.setSelected(false);
            mNoEmotional.setSelected(true);
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_EMOTION, false);
        });

        // 情绪模式：情绪
        mEmotional.setOnClickListener(v -> {
            mEmotional.setSelected(true);
            mNoEmotional.setSelected(false);
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_EMOTION, true);
        });

        // 声纹开关
        mEnableVoicePrintSwitch.setOnClickListener(v -> {
            boolean checked = mEnableVoicePrintSwitch.isChecked();
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_VOICE_PRINT, checked);
            mVoicePrintDetailLayout.setVisibility(checked ? View.VISIBLE : View.GONE);
        });

        // 声纹录制入口（图标按钮，仅在预注册模式下显示）
        if (mRecordVoiceSelect != null) {
            mRecordVoiceSelect.setOnClickListener(v -> startVoicePrintRecordActivity());
        }

        // 声纹录入按钮（文字按钮：录入/重新录入）
        if (mVoicePrintDesc != null) {
            mVoicePrintDesc.setOnClickListener(v -> startVoicePrintRecordActivity());
        }

        // 删除声纹按钮（右侧单独卡片）
        if (mDeleteVoicePrintButton != null) {
            mDeleteVoicePrintButton.setOnClickListener(v -> clearVoicePrintRemote());
        }

        // 预注册模式选择
        if (mVoicePrintModePreRegister != null) {
            mVoicePrintModePreRegister.setOnClickListener(v -> {
                SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_VOICE_PRIINT_AUTO_REGISTER, false);
                updateVoicePrintMode(false);
            });
        }

        // 无感注册模式选择
        if (mVoicePrintModeAutoRegister != null) {
            mVoicePrintModeAutoRegister.setOnClickListener(v -> {
                SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_VOICE_PRIINT_AUTO_REGISTER, true);
                updateVoicePrintMode(true);
            });
        }

        // 语义断句开关
        mSemanticBreakSwitch.setOnClickListener(v -> {
            boolean checked = mSemanticBreakSwitch.isChecked();
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_SEMATNIC, checked);
            updateSemanticBreakRelatedUI(checked);
        });

        // 检测速度
        mEagernessConfigLayout.setOnClickListener(v -> showEagernessDialog());

        // 智能打断开关
        mEnableVoiceInterruptSwitch.setOnClickListener(v -> {
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_ENABLE_VOICE_INTERRUPT, mEnableVoiceInterruptSwitch.isChecked());
        });

        // 附和语开关
        mBackChannelingSwitch.setOnClickListener(v -> {
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_BACK_CHANNELING,
                    mBackChannelingSwitch.isChecked());
        });

        // 主动问询开关
        mAutoSpeechUserIdleSwitch.setOnClickListener(v -> {
            boolean checked = mAutoSpeechUserIdleSwitch.isChecked();
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_AGENT_AUTO_SPEECH_USER_IDLE, checked);
            updateAutoSpeechRelatedUI(checked);
        });

        // 等待时间
        mAutoSpeechUserIdleWaitTimeLayout.setOnClickListener(v -> showWaitTimeEditDialog());

        // 问询次数
        mAutoSpeechUserIdleMaxRepeatsLayout.setOnClickListener(v -> showQueryCountEditDialog());

        // 通话背景音
        mBackgroundSoundLayout.setOnClickListener(v -> showBackgroundSoundDialog());
    }

    /**
     * 更新语义断句相关UI的可见性
     */
    private void updateSemanticBreakRelatedUI(boolean semanticBreakEnabled) {
        mEagernessConfigLayout.setVisibility(semanticBreakEnabled ? View.VISIBLE : View.GONE);
    }

    /**
     * 更新主动问询相关UI的可见性
     */
    private void updateAutoSpeechRelatedUI(boolean autoSpeechEnabled) {
        mAutoSpeechUserIdleWaitTimeLayout.setVisibility(autoSpeechEnabled ? View.VISIBLE : View.GONE);
        mAutoSpeechUserIdleMaxRepeatsLayout.setVisibility(autoSpeechEnabled ? View.VISIBLE : View.GONE);
    }

    /**
     * 更新声纹模式和相关UI状态
     */
    private void updateVoicePrintMode(boolean enableAutoVoicePrint) {
        
        // 更新模式选中状态
        mVoicePrintModePreRegister.setSelected(!enableAutoVoicePrint);
        mVoicePrintModeAutoRegister.setSelected(enableAutoVoicePrint);
        
        // 更新描述文本
        if (enableAutoVoicePrint) {
            mVoicePrintTips.setText(R.string.voiceprint_auto_register_desc);
        } else {
            mVoicePrintTips.setText(R.string.voiceprint_pre_register_desc);
        }
        
        // 更新声纹状态区域和按钮
        updateVoicePrintStatusText();
    }

    /**
     * 更新声纹录制状态文本和UI显示
     */
    private void updateVoicePrintStatusText() {
        boolean enableAutoRegister = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_VOICE_PRIINT_AUTO_REGISTER, false);
        
        // 从 Manager 读取声纹状态
        AUIAICallVoiceprintManager mgr = AUIAICallVoiceprintManager.getInstance();
        if (!TextUtils.isEmpty(mLoginUserId)) {
            mgr.setUserId(mLoginUserId);
            boolean usePreHost = SettingStorage.getInstance()
                    .getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
            mgr.setPreEnv(usePreHost);
        }
        mgr.switchVoiceprintMode(enableAutoRegister);
        boolean voicePrintRecorded = mgr.isRegistedVoiceprint();

        if (!enableAutoRegister) {
            // 预注册模式：始终显示状态区域
            mVoicePrintStatusLayout.setVisibility(View.VISIBLE);

            if (voicePrintRecorded) {
                mVoicePrintTitle.setText(R.string.voiceprint_info_title);
                mVoicePrintDesc.setText(R.string.voiceprint_rerecord);
            } else {
                mVoicePrintTitle.setText(R.string.voiceprint_info_tipe_cannot_use);
                mVoicePrintDesc.setText(R.string.voiceprint_info_record);
            }

            // 预注册下：录入按钮和图标都可见，删除按钮隐藏
            mVoicePrintDesc.setVisibility(View.VISIBLE);
            if (mRecordVoiceSelect != null) {
                mRecordVoiceSelect.setVisibility(View.VISIBLE);
            }
            if (mDeleteVoicePrintButton != null) {
                mDeleteVoicePrintButton.setVisibility(View.GONE);
            }
        } else {
            // 无感注册模式
            if (voicePrintRecorded) {
                // 已录入：显示左侧状态卡片 + 右侧删除按钮
                mVoicePrintStatusLayout.setVisibility(View.VISIBLE);
                mVoicePrintTitle.setText(R.string.voiceprint_info_title);

                // 左卡片只展示标题，不需要右侧“录入”文字和图标
                mVoicePrintDesc.setVisibility(View.GONE);
                if (mRecordVoiceSelect != null) {
                    mRecordVoiceSelect.setVisibility(View.GONE);
                }

                // 显示右侧删除按钮
                if (mDeleteVoicePrintButton != null) {
                    mDeleteVoicePrintButton.setVisibility(View.VISIBLE);
                }
            } else {
                // 未录入：整块状态区域隐藏（左状态 + 右删除一起隐藏）
                mVoicePrintStatusLayout.setVisibility(View.GONE);
            }
        }
    }

    /**
     * 清除声纹信息
     */
    private void clearVoicePrintRemote() {
        boolean enableAutoRegister = SettingStorage.getInstance()
                .getBoolean(SettingStorage.KEY_BOOT_VOICE_PRIINT_AUTO_REGISTER, false);
        
        AUIAICallVoiceprintManager mgr = AUIAICallVoiceprintManager.getInstance();
        
        if (!TextUtils.isEmpty(mLoginUserId)) {
            mgr.setUserId(mLoginUserId);
            boolean usePreHost = SettingStorage.getInstance()
                    .getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
            mgr.setPreEnv(usePreHost);
        }
        
        if (enableAutoRegister) {
            // 无感模式删除
            mgr.removeAutoRegister(mLoginAuthorization, (success, errorMsg) -> {
                runOnUiThread(() -> {
                    if (success) {
                        ToastHelper.showToast(this, "声纹删除成功", Toast.LENGTH_SHORT);
                        updateVoicePrintStatusText();
                    } else {
                        ToastHelper.showToast(this, "声纹删除失败：" + errorMsg, Toast.LENGTH_SHORT);
                    }
                });
            });
        } else {
            // 预注册模式删除
            mgr.removePreRegister(mLoginAuthorization, (success, errorMsg) -> {
                runOnUiThread(() -> {
                    if (success) {
                        ToastHelper.showToast(this, "声纹删除成功", Toast.LENGTH_SHORT);
                        updateVoicePrintStatusText();
                    } else {
                        ToastHelper.showToast(this, "声纹删除失败：" + errorMsg, Toast.LENGTH_SHORT);
                    }
                });
            });
        }
    }

    private void startVoicePrintRecordActivity() {
        Intent intent = new Intent(this, AUIAICallVoicePrintRecordActivity.class);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, mLoginUserId);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, mLoginAuthorization);
        startActivity(intent);
    }

    /**
     * 显示检测速度选择对话框
     */
    private void showEagernessDialog() {
        String currentValue = SettingStorage.getInstance()
                .getString(SettingStorage.KEY_BOOT_EAGERNESS_CONFIG, "Medium");

        int selectedIndex = eagernessValues.indexOf(currentValue);
        if (selectedIndex == -1) {
            selectedIndex = 1; // 默认 Medium
        }

        OptionSelectorDialog.show(this, getString(R.string.eagerness_dialog_title), eagernessOptions, selectedIndex,
                (position, option) -> {
                    mEagernessValue.setText(option);
                    // 保存对应的英文值
                    String selectedValue = eagernessValues.get(position);
                    SettingStorage.getInstance().setString(SettingStorage.KEY_BOOT_EAGERNESS_CONFIG, selectedValue);
                });
    }

    /**
     * 显示通话背景音选择对话框
     */
    private void showBackgroundSoundDialog() {
        String currentId = SettingStorage.getInstance().getString(SettingStorage.KEY_BOOT_AMBIENT_RESOURCE_ID, "");
        int selectedIndex = ambientVolumeIds.indexOf(currentId);
        if (selectedIndex == -1) {
            selectedIndex = 0;
        }

        OptionSelectorDialog.show(this, getString(R.string.ambient_dialog_title), ambientVolumeType, selectedIndex,
                (position, option) -> {
                    // UI 上显示选中的文字
                    mAmbientIdValue.setText(option);
                    // 但实际保存对应的 ID
                    String selectedId = ambientVolumeIds.get(position);
                    SettingStorage.getInstance().setString(SettingStorage.KEY_BOOT_AMBIENT_RESOURCE_ID, selectedId);
                });
    }

    /**
     * 显示等待时间编辑对话框
     */
    private void showWaitTimeEditDialog() {
        int currentValue = SettingStorage.getInstance()
                .getInt(SettingStorage.KEY_BOOT_AUTO_SPEECH_USER_IDLE_WAIT_TIME, 5000);

        InputEditDialog.show(
                this,
                getString(R.string.auto_speech_user_idle_wait_time_dialog_title),
                getString(R.string.auto_speech_user_idle_wait_time_dialog_desc),
                String.valueOf(currentValue),
                null,
                input -> {
                    if (TextUtils.isEmpty(input)) {
                        return;
                    }
                    try {
                        int value = Integer.parseInt(input);
                        if (value > 0) {
                            mAutoSpeechUserIdleWaitTimeValue.setText(value + " ms");
                            SettingStorage.getInstance().setInt(SettingStorage.KEY_BOOT_AUTO_SPEECH_USER_IDLE_WAIT_TIME, value);
                        }
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
        );
    }

    /**
     * 显示问询次数编辑对话框
     */
    private void showQueryCountEditDialog() {
        int currentValue = SettingStorage.getInstance()
                .getInt(SettingStorage.KEY_BOOT_AUTO_SPEECH_USER_IDLE_MAX_REPEATS, 10);

        InputEditDialog.show(
                this,
                getString(R.string.auto_speech_user_idle_max_repeats_dialog_title),
                getString(R.string.auto_speech_user_idle_max_repeats_dialog_desc),
                String.valueOf(currentValue),
                null,
                input -> {
                    if (TextUtils.isEmpty(input)) {
                        return;
                    }
                    try {
                        int value = Integer.parseInt(input);
                        if (value > 0) {
                            mAutoSpeechUserIdleMaxRepeatsValue.setText(value + " " + getString(R.string.auto_speech_user_idle_max_repeats_unit));
                            SettingStorage.getInstance().setInt(SettingStorage.KEY_BOOT_AUTO_SPEECH_USER_IDLE_MAX_REPEATS, value);
                        }
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
        );
    }
}
