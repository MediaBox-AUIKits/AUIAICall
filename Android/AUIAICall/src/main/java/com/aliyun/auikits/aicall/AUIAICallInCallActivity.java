package com.aliyun.auikits.aicall;

import static com.aliyun.auikits.aicall.core.ARTCAICallEngine.ARTCAICallRobotState.Listening;
import static com.aliyun.auikits.aicall.core.ARTCAICallEngine.ARTCAICallRobotState.Speaking;
import static com.aliyun.auikits.aicall.core.ARTCAICallEngine.ARTCAICallRobotState.Thinking;

import androidx.appcompat.app.AppCompatActivity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.aliyun.auikits.aicall.core.ARTCAICallEngine;
import com.aliyun.auikits.aicall.core.ARTCAICallEngineImpl;
import com.aliyun.auikits.aicall.service.ForegroundAliveService;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.TimeUtil;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.AICallSettingDialog;
import com.aliyun.auikits.aicall.widget.SpeechAnimationView;

import java.util.UUID;

public class AUIAICallInCallActivity extends AppCompatActivity {
    private static final boolean IS_SUBTITLE_ENABLE = false;
    private static String sUserId = null;

    private Handler mHandler = null;
    private boolean mDurationUpdating = false;
    private long mCallConnectedMillis = 0;

    private ARTCAICallEngine mARTCAICallEngine = null;

    private ARTCAICallEngine.AICallState mCallState;
    private ARTCAICallEngine.AICallErrorCode mAICallErrorCode = ARTCAICallEngine.AICallErrorCode.None;
    private ARTCAICallEngine.ARTCAICallRobotState mRobotState = Listening;
    private boolean isUserSpeaking = false;
    private long mLastBackButtonExitMillis = 0;

    private ImageView mIvSubtitle = null;
    private TextView mTvSubtitle = null;

    private ARTCAICallEngine.IARTCAICallEngineCallback mARTCAIEngineCallback = new ARTCAICallEngine.IARTCAICallEngineCallback() {
        @Override
        public void onAICallEngineStateChanged(ARTCAICallEngine.AICallState oldCallState, ARTCAICallEngine.AICallState newCallState, ARTCAICallEngine.AICallErrorCode errorCode) {
            switch (newCallState) {
                case None:
                    break;
                case Connecting:
                    break;
                case Connected:
                    startDurationUpdateProgress();
                    break;
                case Over:
                    stopDurationUpdateProgress();
                    break;
                case Error:
                    break;
                default:
                    break;
            }
            mCallState = newCallState;
            updateUIByEngineState();
            updateForegroundAliveService();
        }

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
                if (isSentenceEnd) {
                    updateSubtitle(true, text);
                }
            } else {
                setSubtitleLayoutVisibility(false);
            }
        }

        @Override
        public void onRobotSubtitleNotify(String text, int userAsrSentenceId) {
            Log.i("AUIAICALL", "onRobotSubtitleNotify: [userAsrSentenceId: " + userAsrSentenceId + ", text: " + text + "]");

            if (IS_SUBTITLE_ENABLE) {
                updateSubtitle(false, text);
            } else {
                setSubtitleLayoutVisibility(false);
            }
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
                AICallSettingDialog.show(AUIAICallInCallActivity.this, mARTCAICallEngine);
            }
        });
        findViewById(R.id.btn_stop_call).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mARTCAICallEngine.handup();
                finish();
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

        mARTCAICallEngine = new ARTCAICallEngineImpl(this, generateUserId());
        ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig = new ARTCAICallEngine.ARTCAICallConfig();
        artcaiCallConfig.robotId = SettingStorage.getInstance().get(SettingStorage.KEY_ROBOT_ID);
        artcaiCallConfig.enableAudioDump = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH);
        artcaiCallConfig.usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE);
        mARTCAICallEngine.init(artcaiCallConfig);
        mARTCAICallEngine.setEngineCallback(mARTCAIEngineCallback);
        mARTCAICallEngine.start();
        updateSpeakerButtonUI();
    }

    @Override
    public void onBackPressed() {
        long nowMillis = SystemClock.elapsedRealtime();
        long duration = nowMillis - mLastBackButtonExitMillis;
        final long DOUBLE_PRESS_THRESHOLD = 1000;
        if (duration <= DOUBLE_PRESS_THRESHOLD) {
            mARTCAICallEngine.handup();
            super.onBackPressed();
        } else {
            ToastHelper.showToast(this, R.string.tips_exit, Toast.LENGTH_SHORT);
        }
        mLastBackButtonExitMillis = nowMillis;
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

    private void startDurationUpdateProgress() {
        mDurationUpdating = true;
        mCallConnectedMillis = SystemClock.elapsedRealtime();
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                updateCallDuration();
            }
        });
    }

    private void stopDurationUpdateProgress() {
        mDurationUpdating = false;
    }

    private void updateCallDuration() {
        if (mDurationUpdating) {
            long duration = mCallConnectedMillis > 0 ? SystemClock.elapsedRealtime() - mCallConnectedMillis : 0;
            ((TextView)findViewById(R.id.tv_call_duration)).setText(TimeUtil.formatDuration(duration));

            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    updateCallDuration();
                }
            });
        }
    }

    private void updateForegroundAliveService() {
        if ( mCallState == ARTCAICallEngine.AICallState.Connected) {
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

        if (mCallState == ARTCAICallEngine.AICallState.Connecting) {
            resId = R.string.call_connection_tips;
            needSetText = true;
        } else if (mCallState == ARTCAICallEngine.AICallState.Connected) {
            if (mRobotState == Thinking) {
                resId = R.string.robot_thinking_tips;
                needSetText = true;
            } else if (mRobotState == Speaking) {
                resId = R.string.robot_speaking_tips;
                needSetText = true;
            } else if (mRobotState == Listening) {
                resId = R.string.robot_listening_tips;
                needSetText = true;
            }
        } else if (mCallState == ARTCAICallEngine.AICallState.Error) {
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
                default:
                    resId = R.string.call_error_default;
                    break;
            }
            needSetText = true;
        }

        TextView tvCallTips = (TextView) findViewById(R.id.tv_call_tips);
        if (needSetText) {
            tvCallTips.setText(resId);
        } else {
            tvCallTips.setText("");
        }
    }

    private void updateSpeechAnimationType() {
        Log.i("AUIAICALL", "updateSpeechAnimationType: [robotState: " + mRobotState + ", isUserSpeaking: " + isUserSpeaking + "]");
        SpeechAnimationView speechAnimationView = ((SpeechAnimationView)findViewById(R.id.speech_animation_view));
        if (mRobotState == Thinking) {
            speechAnimationView.setAnimationType(SpeechAnimationView.AnimationType.ROBOT_THINKING);
        } else if (mRobotState == Speaking) {
            speechAnimationView.setAnimationType(SpeechAnimationView.AnimationType.ROBOT_SPEAKING);
        } else if (mRobotState == Listening) {
            speechAnimationView.setAnimationType(
                    isUserSpeaking ?
                            SpeechAnimationView.AnimationType.LISTENING :
                            SpeechAnimationView.AnimationType.WAITING
            );
        }
    }

    private void updateSubtitle(boolean isUser, String text) {
        setSubtitleLayoutVisibility(true);
        if (null == mIvSubtitle) {
            mIvSubtitle = findViewById(R.id.iv_subtitle);
        }
        if (null == mTvSubtitle) {
            mTvSubtitle = findViewById(R.id.tv_subtitle);
        }

        mIvSubtitle.setImageResource(
                isUser ?
                R.drawable.ic_subtitle_user :
                R.drawable.ic_subtitle_robot
        );

        mTvSubtitle.setText(text);
    }

    private void setSubtitleLayoutVisibility(boolean isVisible) {
        findViewById(R.id.ll_subtitle).setVisibility(isVisible ? View.VISIBLE : View.GONE);
    }
}