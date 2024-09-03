package com.aliyun.auikits.aicall;


import static com.aliyun.auikits.aiagent.ARTCAICallEngine.AICallErrorCode.AgentConcurrentLimit;

import androidx.appcompat.app.AppCompatActivity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.aliyun.auikits.aicall.controller.ARTCAICallController;
import com.aliyun.auikits.aicall.controller.ARTCAICustomController;
import com.aliyun.auikits.aicall.controller.ARTCAICallDepositController;
import com.aliyun.auikits.aicall.service.ForegroundAliveService;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.TimeUtil;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.AICallNoticeDialog;
import com.aliyun.auikits.aicall.widget.AICallRatingDialog;
import com.aliyun.auikits.aicall.widget.AICallSettingDialog;
import com.aliyun.auikits.aicall.widget.SpeechAnimationView;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aicall.util.AppServiceConst;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class AUIAICallInCallActivity extends AppCompatActivity {
    public static final String BUNDLE_KEY_AI_AGENT_TYPE = "BUNDLE_KEY_AI_AGENT_TYPE";
    public static final String BUNDLE_KEY_AI_AGENT_ID = "BUNDLE_KEY_AI_AGENT_ID";

    private static final boolean IS_SUBTITLE_ENABLE = true;
    private static String sUserId = null;

    private Handler mHandler = null;
    private boolean mUIProgressing = false;
    private long mCallConnectedMillis = 0;

    private ARTCAICallController mARTCAICallController = null;
    private ARTCAICallEngine mARTCAICallEngine = null;

    private ARTCAICallController.AICallState mCallState;
    private ARTCAICallEngine.AICallErrorCode mAICallErrorCode = ARTCAICallEngine.AICallErrorCode.None;
    private ARTCAICallEngine.ARTCAICallRobotState mRobotState = ARTCAICallEngine.ARTCAICallRobotState.Listening;
    private boolean isUserSpeaking = false;
    private long mLastBackButtonExitMillis = 0;
    private boolean mUseAvatar = false;

    private SubtitleHolder mSubtitleHolder = new SubtitleHolder();

    private ARTCAICallController.IARTCAICallStateCallback mCallStateCallback = new ARTCAICallController.IARTCAICallStateCallback() {
        @Override
        public void onAICallEngineStateChanged(ARTCAICallController.AICallState oldCallState, ARTCAICallController.AICallState newCallState, ARTCAICallEngine.AICallErrorCode errorCode) {
            switch (newCallState) {
                case None:
                    break;
                case Connecting:
                    break;
                case Connected:
                    startUIUpdateProgress();
                    break;
                case Over:
                    stopUIUpdateProgress();
                    break;
                case Error:
                    break;
                default:
                    break;
            }
            mAICallErrorCode = errorCode;
            mCallState = newCallState;
            updateUIByEngineState();
            updateForegroundAliveService();
            updateAvatarVisibility(mUseAvatar);
        }
    };

    private ARTCAICallEngine.IARTCAICallEngineCallback mARTCAIEngineCallback = new ARTCAICallEngine.IARTCAICallEngineCallback() {

        @Override
        public void onAICallEngineRobotStateChanged(ARTCAICallEngine.ARTCAICallRobotState oldRobotState, ARTCAICallEngine.ARTCAICallRobotState newRobotState) {
            switch (newRobotState) {
                case Listening:
                    break;
                case Thinking:
                    break;
                case Speaking:
                    break;
                default:
                    break;
            }
            mRobotState = newRobotState;
            updateUIByEngineState();
        }

        @Override
        public void onUserSpeaking(boolean isSpeaking) {
            isUserSpeaking = isSpeaking;
            updateUIByEngineState();
        }

        @Override
        public void onUserAsrSubtitleNotify(String text, boolean isSentenceEnd, int sentenceId) {
            Log.i("AUIAICALL", "onUserAsrSubtitleNotify: [sentenceId: " + sentenceId + ", isSentenceEnd" + isSentenceEnd + ", text: " + text + "]");

            if (IS_SUBTITLE_ENABLE) {
                mSubtitleHolder.updateSubtitle(true, isSentenceEnd, text, sentenceId);
            } else {
                mSubtitleHolder.setSubtitleLayoutVisibility(false);
            }
        }

        @Override
        public void onAIAgentSubtitleNotify(String text, boolean end, int userAsrSentenceId) {
            Log.i("AUIAICALL", "onRobotSubtitleNotify: [userAsrSentenceId: " + userAsrSentenceId + ", end: " + end + ", text: " + text + "]");

            if (IS_SUBTITLE_ENABLE) {
                mSubtitleHolder.updateSubtitle(false, end, text, userAsrSentenceId);
            } else {
                mSubtitleHolder.setSubtitleLayoutVisibility(false);
            }
        }

        @Override
        public void onNetworkStatusChanged(String uid, ARTCAICallEngine.ARTCAICallNetworkQuality quality) {
            Log.i("AUIAICALL", "onNetworkStatusChanged: [uid: " + uid + ", quality: " + quality + "]");
        }

        @Override
        public void onVoiceIdChanged(String voiceId) {
            Log.i("AUIAICALL", "onVoiceIdChanged: [voiceId: " + voiceId + "]");
        }

        @Override
        public void onVoiceVolumeChanged(String uid, int volume) {
            Log.i("AUIAICALL", "onVoiceVolumeChanged: [uid: " + uid + "volume: " + volume + "]");
        }

        @Override
        public void onVoiceInterrupted(boolean enable) {
            Log.i("AUIAICALL", "onVoiceInterrupted: [enable: " + enable + "]");
        }

        @Override
        public void onCallBegin() {
            Log.i("AUIAICALL", "onCallBegin");
        }

        @Override
        public void onCallEnd() {
            Log.i("AUIAICALL", "onCallEnd");
        }

        @Override
        public void onErrorOccurs(ARTCAICallEngine.AICallErrorCode errorCode) {
            Log.i("AUIAICALL", "onErrorOccurs: [errorCode: " + errorCode + "]");
            if (errorCode == AgentConcurrentLimit) {
                AICallNoticeDialog.showDialog(AUIAICallInCallActivity.this,
                        0, false, R.string.token_resource_exhausted, true, new OnDismissListener() {
                            @Override
                            public void onDismiss(DialogPlus dialog) {
                                finish();
                            }
                        });
            }
        }

        @Override
        public void onAgentAudioAvailable(boolean available) {
            Log.i("AUIAICALL", "onAgentAudioAvailable: [available: " + available + "]");
        }

        @Override
        public void onAgentVideoAvailable(boolean available) {
            Log.i("AUIAICALL", "onAgentVideoAvailable: [available: " + available + "]");
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_auiaicall_in_call);
        mHandler = new Handler();

        findViewById(R.id.btn_setting).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                AICallSettingDialog.show(AUIAICallInCallActivity.this, mARTCAICallEngine, mUseAvatar);
            }
        });
        findViewById(R.id.btn_stop_call).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (handUp(false)) {
                    finish();
                }
            }
        });
        findViewById(R.id.btn_mute_call).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                boolean isMicrophoneOn = !mARTCAICallEngine.isMicrophoneOn();
                mARTCAICallEngine.switchMicrophone(isMicrophoneOn);
                updateMuteButtonUI(isMicrophoneOn);
                updateUIByEngineState();
            }
        });
        findViewById(R.id.btn_speaker).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                boolean isSpeakerOn = mARTCAICallEngine.isSpeakerOn();
                mARTCAICallEngine.enableSpeaker(!isSpeakerOn);
                updateSpeakerButtonUI();
            }
        });
        findViewById(R.id.speech_animation_view).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mARTCAICallEngine.interruptSpeaking();
            }
        });
        findViewById(R.id.avatar_layer).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mARTCAICallEngine.interruptSpeaking();
            }
        });

        String aiAgentId = null;
        ARTCAICallEngine.ARTCAICallAgentType aiAgentType = ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
        if (null != getIntent() && null != getIntent().getExtras()) {
            aiAgentId = getIntent().getExtras().getString(BUNDLE_KEY_AI_AGENT_ID, null);
            aiAgentType = getIntent().getExtras().getBoolean(BUNDLE_KEY_AI_AGENT_TYPE) ?
                    ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent : ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent;
        }
        mUseAvatar = aiAgentType == ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent;

        boolean useDeposit = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_DEPOSIT_SWITCH, SettingStorage.DEFAULT_DEPOSIT_SWITCH);
        ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig = new ARTCAICallEngine.ARTCAICallConfig();
        artcaiCallConfig.aiAgentId = aiAgentId;
        artcaiCallConfig.enableAudioDump = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH);
        boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
        artcaiCallConfig.appServerHost = usePreHost ? AppServiceConst.PRE_HOST : AppServiceConst.HOST;
        artcaiCallConfig.useDeposit = useDeposit;

        mARTCAICallController = useDeposit ? new ARTCAICallDepositController(this, generateUserId()) :
                new ARTCAICustomController(this, generateUserId());
        mARTCAICallController.setBizCallEngineCallback(mARTCAIEngineCallback);
        mARTCAICallController.setCallStateCallback(mCallStateCallback);
        mARTCAICallController.init(artcaiCallConfig);
        mARTCAICallController.setAiAgentType(aiAgentType);

        mARTCAICallEngine = mARTCAICallController.getARTCAICallEngine();
        mARTCAICallEngine.setAvatarAgentView(findViewById(R.id.avatar_layer),
                new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
                );
        mARTCAICallController.start();
        updateSpeakerButtonUI();
    }

    @Override
    public void onBackPressed() {
        long nowMillis = SystemClock.elapsedRealtime();
        long duration = nowMillis - mLastBackButtonExitMillis;
        final long DOUBLE_PRESS_THRESHOLD = 1000;
        if (duration <= DOUBLE_PRESS_THRESHOLD) {
            if (handUp(false)) {
                super.onBackPressed();
            }
        } else {
            ToastHelper.showToast(this, R.string.tips_exit, Toast.LENGTH_SHORT);
        }
        mLastBackButtonExitMillis = nowMillis;
    }

    /**
     *
     * @param keepActivity
     * @return 是否可以直接关闭Activity
     */
    private boolean handUp(boolean keepActivity) {
        mARTCAICallEngine.handup();

        if (!keepActivity) {
            AICallRatingDialog.show(this,
                    new AICallRatingDialog.IRatingDialogDismissListener() {
                        @Override
                        public void onSubmit(int subRating, int callDelay, int noiseHandling, int recognition, int interaction, int realism) {
                            mARTCAICallEngine.rating(subRating, callDelay, noiseHandling,
                                    recognition, interaction, realism);
                        }

                        @Override
                        public void onDismiss() {
                            finish();
                        }
                    });
        }
        return false;
    }

    // 改为接通之后显示Avatar
    private void updateAvatarVisibility(boolean useAvatar) {
        if (mCallState == ARTCAICallController.AICallState.Connected) {
            if (useAvatar) {
                findViewById(R.id.avatar_layer).setVisibility(View.VISIBLE);
                findViewById(R.id.speech_animation_view).setVisibility(View.GONE);
            } else {
                findViewById(R.id.avatar_layer).setVisibility(View.GONE);
                findViewById(R.id.speech_animation_view).setVisibility(View.VISIBLE);
            }
        }
    }

    private static String generateUserId() {
        if (TextUtils.isEmpty(sUserId)) {
            sUserId = UUID.randomUUID().toString();
        }
        return sUserId;
    }

    private void updateMuteButtonUI(boolean isMuted) {
        ImageView ivMuteCall = (ImageView) findViewById(R.id.iv_mute_call);
        TextView tvMuteCall = (TextView) findViewById(R.id.tv_mute_call);
        if (isMuted) {
            ivMuteCall.setImageResource(R.drawable.ic_voice_mute);
            tvMuteCall.setText(R.string.mute_call);
        } else {
            ivMuteCall.setImageResource(R.drawable.ic_voice_open);
            tvMuteCall.setText(R.string.unmute_call);
        }
    }

    private void updateSpeakerButtonUI() {
        boolean isSpeakerOn = null != mARTCAICallEngine ? mARTCAICallEngine.isSpeakerOn() : true;
        ImageView ivSpeaker = (ImageView) findViewById(R.id.iv_speaker);
        TextView tvSpeaker = (TextView) findViewById(R.id.tv_speaker);
        if (isSpeakerOn) {
            ivSpeaker.setImageResource(R.drawable.ic_speaker_on);
            tvSpeaker.setText(R.string.speaker_off);
        } else {
            ivSpeaker.setImageResource(R.drawable.ic_speaker_off);
            tvSpeaker.setText(R.string.speaker_on);
        }
    }

    private void startUIUpdateProgress() {
        mUIProgressing = true;
        mCallConnectedMillis = SystemClock.elapsedRealtime();
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                updateProgressUI();
            }
        });
    }

    private void stopUIUpdateProgress() {
        mUIProgressing = false;
    }

    private void updateProgressUI() {
        if (mUIProgressing) {
            boolean hasNextRun = true;
            // 更新通话时长
            long duration = mCallConnectedMillis > 0 ? SystemClock.elapsedRealtime() - mCallConnectedMillis : 0;
            ((TextView)findViewById(R.id.tv_call_duration)).setText(TimeUtil.formatDuration(duration));

            // 更新实时字幕
            mSubtitleHolder.refreshSubtitle();

            // 数字人体验超过5分钟，自动结束
            if (duration > 5 * 60 * 1000) {
                AICallNoticeDialog.showDialog(AUIAICallInCallActivity.this,
                        0, false, R.string.token_time_lit_tips, true, new OnDismissListener() {
                            @Override
                            public void onDismiss(DialogPlus dialog) {
                                finish();
                            }
                        });
                handUp(true);
                hasNextRun = false;
            }

            if (hasNextRun) {
                mHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        updateProgressUI();
                    }
                }, 100);
            }
        }
    }

    private void updateForegroundAliveService() {
        if ( mCallState == ARTCAICallController.AICallState.Connected) {
            // start
            Intent serviceIntent = new Intent(this, ForegroundAliveService.class);
            startService(serviceIntent);
        } else {
            // stop
            Intent serviceIntent = new Intent(this, ForegroundAliveService.class);
            stopService(serviceIntent);
        }
    }

    private void updateUIByEngineState() {
        updateCallTips();
        updateSpeechAnimationType();
    }

    private void updateCallTips() {
        int resId = 0;
        boolean needSetText = false;
        boolean keepText = false;

        if (mCallState == ARTCAICallController.AICallState.Over) {
            keepText = true;
        } else if (mCallState == ARTCAICallController.AICallState.Connecting) {
            resId = R.string.call_connection_tips;
            needSetText = true;
        } else if (mCallState == ARTCAICallController.AICallState.Connected) {
            if (mRobotState == ARTCAICallEngine.ARTCAICallRobotState.Thinking) {
                resId = R.string.robot_thinking_tips;
                needSetText = true;
            } else if (mRobotState == ARTCAICallEngine.ARTCAICallRobotState.Speaking) {
                resId = R.string.robot_speaking_tips;
                needSetText = true;
            } else if (mRobotState == ARTCAICallEngine.ARTCAICallRobotState.Listening) {
                resId = R.string.robot_listening_tips;
                needSetText = true;
            }
        } else if (mCallState == ARTCAICallController.AICallState.Error) {
            switch (mAICallErrorCode) {
                case StartFailed:
                    resId = R.string.call_error_start_failed;
                    break;
                case TokenExpired:
                    resId = R.string.call_error_token_expired;
                    break;
                case ConnectionFailed:
                    resId = R.string.call_error_connection_failed;
                    break;
                case KickedByUserReplace:
                    resId = R.string.call_error_kicked_by_user_replace;
                    break;
                case KickedBySystem:
                    resId = R.string.call_error_kicked_by_system;
                    break;
                case LocalDeviceException:
                    resId = R.string.call_error_local_device_exception;
                    break;
                case AgentLeaveChannel:
                    resId = R.string.error_tips_avatar_leave_join;
                    break;
                case AgentAudioSubscribeFailed:
                    resId = R.string.error_tips_avatar_subscribe_fail;
                    break;
                case AgentConcurrentLimit:
                    resId = R.string.token_resource_exhausted;
                    break;
                case AiAgentAsrUnavailable:
                    resId = R.string.error_tips_asr_unavailable;
                    break;
                case AvatarAgentUnavailable:
                    resId = R.string.error_tips_avatar_agent_unavailable;
                    break;
                default:
                    resId = R.string.call_error_default;
                    break;
            }
            handUp(true);
            needSetText = true;
        }

        TextView tvCallTips = (TextView) findViewById(R.id.tv_call_tips);
        if (!keepText) {
            if (needSetText) {
                tvCallTips.setText(resId);
            } else {
                tvCallTips.setText("");
            }
        }
    }

    private void updateSpeechAnimationType() {
        Log.i("AUIAICALL", "updateSpeechAnimationType: [robotState: " + mRobotState + ", isUserSpeaking: " + isUserSpeaking + "]");
        SpeechAnimationView speechAnimationView = ((SpeechAnimationView)findViewById(R.id.speech_animation_view));
        if (mCallState == ARTCAICallController.AICallState.Connecting) {
            speechAnimationView.setAnimationType(SpeechAnimationView.AnimationType.Connecting);
        } else {
            if (mRobotState == ARTCAICallEngine.ARTCAICallRobotState.Thinking) {
                speechAnimationView.setAnimationType(SpeechAnimationView.AnimationType.ROBOT_THINKING);
            } else if (mRobotState == ARTCAICallEngine.ARTCAICallRobotState.Speaking) {
                speechAnimationView.setAnimationType(SpeechAnimationView.AnimationType.ROBOT_SPEAKING);
            } else if (mRobotState == ARTCAICallEngine.ARTCAICallRobotState.Listening) {
                speechAnimationView.setAnimationType(
                        isUserSpeaking ?
                                SpeechAnimationView.AnimationType.LISTENING :
                                SpeechAnimationView.AnimationType.WAITING
                );
            }
        }
    }

    private class SubtitleHolder {
        private ImageView mIvSubtitle = null;
        private TextView mTvSubtitle = null;

        private LinearLayout mLlFullScreenSubtitle = null;
        private ImageView mBtnCloseFullScreenSubtitle = null;
        private ScrollView mSvFullScreenSubtitle = null;
        private TextView mTvFullScreenSubtitle = null;

        private List<SubtitleTextPart> mSubtitlePartList = new ArrayList<>();
        private Integer mAsrSentenceId = null;
        private Boolean isLastSubtitleOfAsr = null;
        private static final int INTERNATIONAL_WORD_INTERVAL = 30;
        private static final int CHINESE_WORD_INTERVAL = 100;
        private static final String SINGLE_WORD = "龍";
        private static final String TARGET_WORD = " > ";

        private class SubtitleTextPart {
            long receiveTime = 0;
            String text;
            long displayEndTime = 0;
        }

        private void updateSubtitle(boolean isAsrText, boolean end, String text, int asrSentenceId) {
            Log.i("AUIAICall", "updateSubtitle [isAsrText" + isAsrText + ", end: " + end +
                    ", text: " + text + ", asrSentenceId: " + asrSentenceId + "]");
            boolean resetSubtitle = false;
            if (isLastSubtitleOfAsr == null || isAsrText || isLastSubtitleOfAsr) { // asr字幕、robot字幕切换
                resetSubtitle = true;
            } else if (mAsrSentenceId == null || mAsrSentenceId != asrSentenceId) { // 新对话
                resetSubtitle = true;
            }
            mAsrSentenceId = asrSentenceId;
            isLastSubtitleOfAsr = isAsrText;
            if (resetSubtitle) {
                mSubtitlePartList.clear();
            }
            SubtitleTextPart subtitleTextPart = new SubtitleTextPart();
            subtitleTextPart.text = text;
            subtitleTextPart.receiveTime = SystemClock.elapsedRealtime();
            mSubtitlePartList.add(subtitleTextPart);

            setSubtitleLayoutVisibility(true);

            initUIComponent();

            mIvSubtitle.setImageResource(
                    isAsrText ? R.drawable.ic_subtitle_user : R.drawable.ic_subtitle_robot
            );
        }

        private void setSubtitleLayoutVisibility(boolean isVisible) {
            findViewById(R.id.ll_subtitle).setVisibility(isVisible ? View.VISIBLE : View.GONE);
        }

        private void refreshSubtitle() {
            if (!mSubtitlePartList.isEmpty()) {
                long now = SystemClock.elapsedRealtime();
                StringBuilder displayTextBuilder = new StringBuilder();

                long lastDisplayEndTime = 0;
                for (SubtitleTextPart subtitleTextPart : mSubtitlePartList) {
                    if (isLastSubtitleOfAsr) {
                        displayTextBuilder.append(subtitleTextPart.text);
                    } else {
                        if (subtitleTextPart.displayEndTime != 0) {
                            lastDisplayEndTime = subtitleTextPart.displayEndTime;
                            displayTextBuilder.append(subtitleTextPart.text);
                        } else {
                            long displayStartMillis = Math.max(subtitleTextPart.receiveTime, lastDisplayEndTime);
                            long progress = now - displayStartMillis;
                            boolean containsChinese = containsChinese(subtitleTextPart.text);
                            int oneWordInterval = containsChinese ? CHINESE_WORD_INTERVAL : INTERNATIONAL_WORD_INTERVAL;

                            if (false) {
                                Log.i("AUIAICall", "refreshSubtitle part [progress: " + progress +
                                        ", lastDisplayEndTime: " + lastDisplayEndTime +
                                        ", receiveTime" + subtitleTextPart.receiveTime +
                                        ", now: " + now +
                                        ", containChinese: " + containsChinese +
                                        "]");
                            }
                            int displayCount = Math.min(subtitleTextPart.text.length(), (int)(progress/oneWordInterval));
                            displayTextBuilder.append(subtitleTextPart.text.substring(0, displayCount));
                            if (displayCount >= subtitleTextPart.text.length()) {
                                subtitleTextPart.displayEndTime = now;
                                lastDisplayEndTime = subtitleTextPart.displayEndTime;
                            } else {
                                break;
                            }
                        }
                    }
                }


                if (false) {
                    StringBuilder allTextBuilder = new StringBuilder();
                    for (SubtitleTextPart subtitleTextPart : mSubtitlePartList) {
                        allTextBuilder.append(subtitleTextPart.text);
                    }
                    Log.i("AUIAICall", "refreshSubtitle [isLastSubtitleOfAsr: " + isLastSubtitleOfAsr +
                            ", displayCount: " + displayTextBuilder.length() + " / " + allTextBuilder.length() +
                            ", displayTextBuilder: " + displayTextBuilder.toString() +
                            ", allTextBuilder: " + allTextBuilder.toString() + "]");

                }
                String displayText = displayTextBuilder.toString();
                { // 收缩字幕显示逻辑
                    int maxDisplayCapacity = getCropDisplayIndex(displayText); //initMaxDisplayCapacity();
                    if (displayText.length() <= maxDisplayCapacity) {
                        mTvSubtitle.setText(displayText);
                    } else {
                        SpannableString spannableString = new SpannableString(displayText.substring(0, maxDisplayCapacity) + TARGET_WORD);

                        spannableString.setSpan(
                                new ForegroundColorSpan(getResources().getColor(R.color.layout_base_light_blue)),
                                maxDisplayCapacity, spannableString.length(),
                                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);

                        mTvSubtitle.setText(spannableString);
                    }
                }
                { // 展开字幕显示逻辑
                    mTvFullScreenSubtitle.setText(displayText);
                }
            }
        }

        private int getCropDisplayIndex(String displayText) {
            int cropIndex = 0;
            if (!TextUtils.isEmpty(displayText)) {
                TextPaint textPaint = mTvSubtitle.getPaint();

                float targetWordMeasureWidth = textPaint.measureText(TARGET_WORD);
                float maxWidth = mTvSubtitle.getWidth() * mTvSubtitle.getMaxLines() - targetWordMeasureWidth*3f;
                float displayWidth = 0f;

                char displayCharArray[] = displayText.toCharArray();
                cropIndex = displayCharArray.length;
                for (int i = 0; i < displayCharArray.length; i++) {
                    String ch = String.valueOf(displayCharArray[i]);
                    displayWidth += textPaint.measureText(ch);
//                    Log.i("AUIAICall", "getCropDisplayIndex [index: " + i + ", str: " + ch + ", maxWidth: " + maxWidth + ", displayWidth" + displayWidth + "]");
                    if (maxWidth <= displayWidth) {
                        cropIndex = i - 1;
                        break;
                    }
                }
            }
            return cropIndex;
        }
        
        private void initUIComponent() {
            if (null == mIvSubtitle) {
                mIvSubtitle = findViewById(R.id.iv_subtitle);
            }
            if (null == mTvSubtitle) {
                mTvSubtitle = findViewById(R.id.tv_subtitle);
                mTvSubtitle.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        setFullScreenSubtitleVisibility(true);
                    }
                });
            }
            if (null == mLlFullScreenSubtitle) {
                mLlFullScreenSubtitle = findViewById(R.id.ll_full_screen_subtitle);
                mLlFullScreenSubtitle.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Log.i("AUIAICall", "mLlFullScreenSubtitle onClick");
                        setFullScreenSubtitleVisibility(false);
                    }
                });
            }
            if (null == mBtnCloseFullScreenSubtitle) {
                mBtnCloseFullScreenSubtitle = findViewById(R.id.btn_close_full_screen_subtitle);
                mBtnCloseFullScreenSubtitle.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Log.i("AUIAICall", "mBtnCloseFullScreenSubtitle onClick");
                        setFullScreenSubtitleVisibility(false);
                    }
                });
            }
            if (null == mSvFullScreenSubtitle) {
                mSvFullScreenSubtitle = findViewById(R.id.sv_full_screen_subtitle);
                mSvFullScreenSubtitle.setOnTouchListener(new View.OnTouchListener() {
                    @Override
                    public boolean onTouch(View v, MotionEvent event) {
                        Log.i("AUIAICall", "mSvFullScreenSubtitle onTouch : " + event.getAction());
                        if (event.getAction() == MotionEvent.ACTION_UP) {
                            setFullScreenSubtitleVisibility(false);
                        }
                        return false;
                    }
                });
            }
            if (null == mTvFullScreenSubtitle) {
                mTvFullScreenSubtitle = findViewById(R.id.tv_full_screen_subtitle);
                mTvFullScreenSubtitle.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Log.i("AUIAICall", "mTvFullScreenSubtitle onClick");
                    }
                });
            }
        }

        private void setFullScreenSubtitleVisibility(boolean visible) {
            if (null != mLlFullScreenSubtitle) {
                mLlFullScreenSubtitle.setVisibility(visible ? View.VISIBLE : View.GONE);
            }
        }

        private boolean containsChinese(String str) {
            // 中文字符的正则表达式
            String regex = "[\u4e00-\u9fa5]";
            return str.matches(".*" + regex + ".*");
        }
    }

}