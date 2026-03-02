package com.aliyun.auikits.aicall;

import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aicall.bean.AUIAICallAgentScenario;
import com.aliyun.auikits.aicall.util.AUIAICallAgentScenarioConfig;
import com.aliyun.auikits.aicall.util.AUIAICallAuthTokenHelper;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.widget.AUIAICallAgentScenarioAdapter;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.List;

public class AUIAICallScenarioSelectionActivity extends AppCompatActivity {

    private RecyclerView mRvScenarios;
    private AUIAICallAgentScenarioAdapter mAdapter;
    private List<AUIAICallAgentScenario> mScenarios;

    private ARTCAICallEngine.ARTCAICallAgentType mAgentType;
    private String mLoginUserId;
    private String mLoginAuthorization;
    private String mRtcAuthToken;
    
    // 电话类型标识
    private boolean mIsPstnCall = false;
    private boolean mIsInboundCall = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_aicall_scenario_selection);

        Intent intent = getIntent();
        if (intent != null) {
            // 优先按 Serializable 读取枚举类型，兼容现在入口传枚举对象的写法
            if (intent.getExtras() != null) {
                Object typeExtra = intent.getExtras().getSerializable(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE);
                if (typeExtra instanceof ARTCAICallEngine.ARTCAICallAgentType) {
                    mAgentType = (ARTCAICallEngine.ARTCAICallAgentType) typeExtra;
                } else {
                    int agentTypeOrdinal = intent.getIntExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, 0);
                    mAgentType = ARTCAICallEngine.ARTCAICallAgentType.values()[agentTypeOrdinal];
                }
            } else {
                int agentTypeOrdinal = intent.getIntExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, 0);
                mAgentType = ARTCAICallEngine.ARTCAICallAgentType.values()[agentTypeOrdinal];
            }

            mLoginUserId = intent.getStringExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID);
            mLoginAuthorization = intent.getStringExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION);
            mRtcAuthToken = intent.getStringExtra(AUIAIConstStrKey.BUNDLE_KEY_RTC_AUTH_TOKEN);
            
            // 读取电话类型标识
            mIsPstnCall = intent.getBooleanExtra("is_pstn_call", false);
            mIsInboundCall = intent.getBooleanExtra("is_inbound_call", false);
        }

        initViews();
        loadScenarios();
    }

    @Override
    protected void onResume() {
        super.onResume();
        fetchRtcAuthToken();
    }

    private void fetchRtcAuthToken() {
        AUIAICallAuthTokenHelper.getAICallAuthToken(mLoginUserId, mLoginAuthorization,
                new AUIAICallAuthTokenHelper.IAUIAICallAuthTokenCallback() {
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

    private void initViews() {
        findViewById(R.id.iv_close).setOnClickListener(v -> finish());

        mRvScenarios = findViewById(R.id.rv_scenarios);
        mRvScenarios.setLayoutManager(new LinearLayoutManager(this));

        findViewById(R.id.btn_enter).setOnClickListener(v -> enterCall());

        // Debug 模式下显示“添加场景”入口
        TextView tvDebugAdd = findViewById(R.id.tv_debug_add_scenario);
        if (tvDebugAdd != null) {
            if (BuildConfig.TEST_ENV_MODE) {
                tvDebugAdd.setVisibility(View.VISIBLE);
                tvDebugAdd.setOnClickListener(v -> showDebugAddScenarioDialog());
            } else {
                tvDebugAdd.setVisibility(View.GONE);
            }
        }
    }

    private void loadScenarios() {
        boolean useEmotional = SettingStorage.getInstance().getBoolean(
                SettingStorage.KEY_BOOT_ENABLE_EMOTION,
                SettingStorage.DEFAULT_BOOT_ENABLE_EMOTION
        );

        mScenarios = AUIAICallAgentScenarioConfig.getScenariosByAgentType(
                this,
                mAgentType,
                useEmotional,
                mIsPstnCall,
                mIsInboundCall
        );

        mAdapter = new AUIAICallAgentScenarioAdapter(this, mScenarios);
        mRvScenarios.setAdapter(mAdapter);
    }

    private void enterCall() {
        AUIAICallAgentScenario selectedScenario = null;
        for (AUIAICallAgentScenario scenario : mScenarios) {
            if (scenario.isSelected()) {
                selectedScenario = scenario;
                break;
            }
        }

        if (selectedScenario == null && !mScenarios.isEmpty()) {
            selectedScenario = mScenarios.get(0);
        }

        if (selectedScenario != null) {
            Intent intent;

            if (mIsPstnCall) {
                // 电话呼入/呼出：选择完场景后，跳转到原来的电话输入界面
                intent = new Intent(this, AUIAICallPhoneCallInputActivity.class);
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, mLoginUserId);
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, mLoginAuthorization);
                // true = 呼入，false = 呼出
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_IS_PSTN_IN, mIsInboundCall);
                // 传递选中的智能体ID和region
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, selectedScenario.getAgentId());
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_REGION, selectedScenario.getRegion());
            } else {
                // 非电话场景：音频对话、数字人、视觉理解、视频对话等
                intent = new Intent(this,
                        mAgentType == ARTCAICallEngine.ARTCAICallAgentType.ChatBot
                                ? AUIAIChatInChatActivity.class
                                : AUIAICallInCallActivity.class);

                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, mLoginUserId);
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, mLoginAuthorization);
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, mAgentType);
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_RTC_AUTH_TOKEN, mRtcAuthToken);
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, selectedScenario.getAgentId());
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_REGION, selectedScenario.getRegion());
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_IS_SHARED_AGENT, false);
                // 将 JSON 中配置的 limit_seconds 传给通话页
                intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_LIMIT_SECONDS, selectedScenario.getLimitSeconds());
            }

            startActivity(intent);
        }
    }

    /**
     * Debug 模式下，手动输入单个场景 JSON，解析并添加到列表
     */
    private void showDebugAddScenarioDialog() {
        EditText editText = new EditText(this);
        editText.setHint("请输入单个场景的 JSON 对象，例如：{ \"agent_id\": \"...\", \"title\": \"...\", ... }");
        editText.setMinLines(6);
        editText.setMaxLines(10);
        editText.setGravity(Gravity.TOP | Gravity.START);
        editText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE);

        int padding = (int) (16 * getResources().getDisplayMetrics().density);
        editText.setPadding(padding, padding, padding, padding);

        new AlertDialog.Builder(this)
                .setTitle("添加 Debug 场景")
                .setView(editText)
                .setPositiveButton("确定", (dialog, which) -> {
                    String jsonText = editText.getText().toString().trim();
                    if (TextUtils.isEmpty(jsonText)) {
                        Toast.makeText(this, "内容不能为空", Toast.LENGTH_SHORT).show();
                        return;
                    }

                    try {
                        // 1. 尝试解析 JSON，校验格式
                        JSONObject obj = new JSONObject(jsonText);

                        String agentId = obj.optString("agent_id");
                        String region = obj.optString("region");
                        String title = obj.optString("title");
                        String asrModelId = obj.optString("asr_model_id");
                        String ttsModelId = obj.optString("tts_model_id");
                        JSONArray tagsArray = obj.optJSONArray("tags");
                        String tags = buildTagsFromJson(tagsArray);
                        String tagFgColors = buildTagFgColorsFromJson(tagsArray);
                        String tagBgColors = buildTagBgColorsFromJson(tagsArray);
                        String voiceId = buildVoiceIdFromJson(obj.optJSONArray("voice_styles"));
                        String voiceName = buildVoiceNameFromJson(obj.optJSONArray("voice_styles"));

                        if (TextUtils.isEmpty(agentId) || TextUtils.isEmpty(title)) {
                            Toast.makeText(this, "缺少必要字段：agent_id 或 title", Toast.LENGTH_SHORT).show();
                            return;
                        }

                        ARTCAICallEngine.ARTCAICallAgentType scenarioAgentType = mAgentType;
                        if (mIsPstnCall) {
                            scenarioAgentType = ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
                        }

                        // 2. 构造场景对象并加入列表
                        AUIAICallAgentScenario scenario = new AUIAICallAgentScenario(
                                title,
                                agentId,
                                asrModelId,
                                ttsModelId,
                                tags,
                                tagFgColors,
                                tagBgColors,
                                scenarioAgentType
                        );

                        // 如果 JSON 里有 voice_styles，就用第一个 voice_id 覆盖默认的 "0"
                        if (!TextUtils.isEmpty(voiceId)) {
                            scenario.setVoiceId(voiceId);
                        }

                        // 设置音色展示名称
                        if (!TextUtils.isEmpty(voiceName)) {
                            scenario.setVoiceName(voiceName);
                        }
                        
                        // Debug 模式下，支持手动设置 limit_seconds，默认 -1 不限时
                        int debugLimitSeconds = obj.optInt("limit_seconds", -1);
                        scenario.setLimitSeconds(debugLimitSeconds);

                        // 设置智能体所在区域
                        if (!TextUtils.isEmpty(region)) {
                            scenario.setRegion(region);
                        }

                        if (mScenarios != null) {
                            // 取消之前的选中，默认选中新添加的场景
                            for (AUIAICallAgentScenario s : mScenarios) {
                                s.setSelected(false);
                            }
                            scenario.setSelected(true);
                            mScenarios.add(scenario);
                        }

                        if (mAdapter != null) {
                            mAdapter.notifyDataSetChanged();
                        }

                        Toast.makeText(this, "添加成功", Toast.LENGTH_SHORT).show();
                    } catch (Exception e) {
                        // 3. 解析失败给出提示，不添加场景
                        Toast.makeText(this, "JSON 格式错误，解析失败", Toast.LENGTH_SHORT).show();
                    }
                })
                .setNegativeButton("取消", null)
                .show();
    }

    /**
     * 从 tags 数组中拼接展示用字符串（只取 name 字段）
     */
    private String buildTagsFromJson(JSONArray tagsArray) {
        if (tagsArray == null || tagsArray.length() == 0) {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < tagsArray.length(); i++) {
            JSONObject tagObj = tagsArray.optJSONObject(i);
            if (tagObj == null) {
                continue;
            }
            String name = tagObj.optString("name");
            if (TextUtils.isEmpty(name)) {
                continue;
            }
            if (builder.length() > 0) {
                builder.append(" ");
            }
            builder.append(name);
        }
        return builder.toString();
    }

    private String buildTagFgColorsFromJson(JSONArray tagsArray) {
        if (tagsArray == null || tagsArray.length() == 0) {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < tagsArray.length(); i++) {
            JSONObject tagObj = tagsArray.optJSONObject(i);
            if (tagObj == null) {
                continue;
            }
            String name = tagObj.optString("name");
            if (TextUtils.isEmpty(name)) {
                continue;
            }
            String fg = tagObj.optString("fg");
            if (TextUtils.isEmpty(fg)) {
                fg = "DEFAULT";
            }
            if (builder.length() > 0) {
                builder.append(" ");
            }
            builder.append(fg);
        }
        return builder.toString();
    }

    private String buildTagBgColorsFromJson(JSONArray tagsArray) {
        if (tagsArray == null || tagsArray.length() == 0) {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < tagsArray.length(); i++) {
            JSONObject tagObj = tagsArray.optJSONObject(i);
            if (tagObj == null) {
                continue;
            }
            String name = tagObj.optString("name");
            if (TextUtils.isEmpty(name)) {
                continue;
            }
            String bg = tagObj.optString("bg");
            if (TextUtils.isEmpty(bg)) {
                bg = "DEFAULT";
            }
            if (builder.length() > 0) {
                builder.append(" ");
            }
            builder.append(bg);
        }
        return builder.toString();
    }

    /**
     * 从 voice_styles 数组中提取第一个 voice_id
     */
    private String buildVoiceIdFromJson(JSONArray voiceStylesArray) {
        if (voiceStylesArray == null || voiceStylesArray.length() == 0) {
            return "";
        }
        try {
            // 只取第一个 voice_styles 里的 voice_id
            JSONObject first = voiceStylesArray.optJSONObject(0);
            if (first != null) {
                return first.optString("voice_id", "");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 从 voice_styles 数组中提取第一个 name（音色展示名称）
     */
    private String buildVoiceNameFromJson(JSONArray voiceStylesArray) {
        if (voiceStylesArray == null || voiceStylesArray.length() == 0) {
            return "";
        }
        try {
            JSONObject first = voiceStylesArray.optJSONObject(0);
            if (first != null) {
                return first.optString("name", "");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }
}
