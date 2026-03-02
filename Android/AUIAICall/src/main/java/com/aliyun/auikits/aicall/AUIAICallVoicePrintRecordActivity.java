package com.aliyun.auikits.aicall;


import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.SystemClock;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import com.aliyun.auikits.aiagent.ARTCAIChatStreamRecorder;
import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.TimeUtil;
import com.aliyun.auikits.aicall.util.ToastHelper;

import com.aliyun.auikits.aicall.widget.AICallNoticeDialog;
import com.aliyun.auikits.aicall.voiceprint.AUIAICallVoiceprintManager;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;

public class AUIAICallVoicePrintRecordActivity extends AppCompatActivity {
    private static final String TAG = "AUIAICallVoicePrintRecordActivity";
    private String fileName = null;
    private String filePath = null;
    private boolean isRecording = false;
    private String mUserId = null;
    private String mAuthorization = null;
    private TextView mVoicePrintInfoTipeDesc = null;
    private TextView mVoicePrintReadDesc = null;
    private TextView mVoicePrintRecognizing = null;
    private ImageView mVoicePrintUploading = null;
    private TextView mVoicePrintRecordTimeTips = null;
    private AUIAICallVoicePrintMediaRecorder mMediaRecorder = null;
    private boolean mUIProgressing = false;
    private long mStartRecordMillis = 0;
    private Handler mHandler = null;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_auiaicall_voiceprint_record);

        mHandler = new Handler();

        if (null != getIntent() && null != getIntent().getExtras()) {
            mUserId = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, null);
            mAuthorization = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, null);
        }

        // 初始化声纹管理器
        AUIAICallVoiceprintManager mgr = AUIAICallVoiceprintManager.getInstance();
        mgr.init(getApplicationContext());
        mgr.setUserId(mUserId);
        boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);
        mgr.setPreEnv(usePreHost);
        mgr.switchVoiceprintMode(false);

        mVoicePrintInfoTipeDesc = findViewById(R.id.tv_voiceprint_info_tipe_desc);
        mVoicePrintReadDesc = findViewById(R.id.tv_read_tips);
        mVoicePrintRecognizing = findViewById(R.id.tv_push_to_recognizing);
        mVoicePrintUploading = findViewById(R.id.iv_voiceprint_uploading);
        mVoicePrintRecordTimeTips = findViewById(R.id.tv_voiceprint_record_time);

        findViewById(R.id.btn_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        findViewById(R.id.iv_close).setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        initPushToTalkButton();

    }

    private void notifyRecognizeError(String errorMsg) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {

                AICallNoticeDialog.showFunctionalDialogEx(AUIAICallVoicePrintRecordActivity.this,
                        getResources().getString(R.string.voiceprint_put_failed), true, errorMsg, true,
                        false, new AICallNoticeDialog.IActionHandle() {
                            @Override
                            public void handleAction() {
                                mVoicePrintInfoTipeDesc.setVisibility(View.VISIBLE);
                                mVoicePrintReadDesc.setVisibility(View.VISIBLE);
                                mVoicePrintRecordTimeTips.setText(R.string.voiceprint_record_time_desc);
                                mVoicePrintRecordTimeTips.setVisibility(View.VISIBLE);
                                mVoicePrintRecognizing.setVisibility(View.GONE);
                                mVoicePrintUploading.setVisibility(View.GONE);
                            }
                        }
                );
            }
        });

    }


    protected void initPushToTalkButton() {
        ViewGroup llPushToTalk = findViewById(R.id.btn_push_to_record);

        llPushToTalk.setOnTouchListener(new View.OnTouchListener() {
            static final int MSG_AUTO_FINISH_PUSH_TO_RECORD = 8888;
            static final int AUTO_FINISH_PUSH_TO_RECORD_TIME = 60000;
            long startTalkMillis = 0;
            Handler uiHandler = new Handler(Looper.getMainLooper()) {
                @Override
                public void handleMessage(@NonNull Message msg) {
                    super.handleMessage(msg);

                    if (msg.what == MSG_AUTO_FINISH_PUSH_TO_RECORD) {
                        onFinishTalk(true);
                    }
                }
            };
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    onStartTalk();
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    onFinishTalk(false);
                }
                return true;
            }

            private void onStartTalk() {
                startTalkMillis = SystemClock.uptimeMillis();
                uiHandler.sendEmptyMessageDelayed(MSG_AUTO_FINISH_PUSH_TO_RECORD, AUTO_FINISH_PUSH_TO_RECORD_TIME);

                if(isRecording) return;

                if(mMediaRecorder == null) {
                    mMediaRecorder = new AUIAICallVoicePrintMediaRecorder(AUIAICallVoicePrintRecordActivity.this);
                }

                isRecording = true;

                mMediaRecorder.startRecording();
                startUIUpdateProgress();

                ImageView ivPushToTalk = findViewById(R.id.iv_push_to_record);
                ivPushToTalk.setImageResource(R.drawable.ic_microphone_speaking);
            }
            private void onFinishTalk(boolean auto) {
                Log.i("initPushToTalkButton",  "onFinishTalk");
                if (startTalkMillis != 0) {

                    if (!isRecording) return;

                    isRecording = false;

                    if(mMediaRecorder != null) {
                        mMediaRecorder.stopRecording();
                        mMediaRecorder = null;
                    }

                    ImageView ivPushToTalk = findViewById(R.id.iv_push_to_record);
                    ivPushToTalk.setImageResource(R.drawable.ic_microphone_idle);

                    stopUIUpdateProgress();
                    long talkTime = SystemClock.uptimeMillis() - startTalkMillis;
                    startTalkMillis = 0;
                    if (talkTime < 12 * 1000) { // 大于12s才会发送
                        ToastHelper.showToast(AUIAICallVoicePrintRecordActivity.this, R.string.voiceprint_record_less_time, Toast.LENGTH_SHORT);
                        mVoicePrintRecordTimeTips.setText(R.string.voiceprint_record_time_desc);
                        return;
                    }

                    mVoicePrintInfoTipeDesc.setVisibility(View.GONE);
                    mVoicePrintReadDesc.setVisibility(View.GONE);
                    mVoicePrintRecordTimeTips.setVisibility(View.GONE);
                    mVoicePrintRecognizing.setVisibility(View.VISIBLE);
                    mVoicePrintUploading.setVisibility(View.VISIBLE);

                    // 使用声纹管理器进行预注册
                    AUIAICallVoiceprintManager.getInstance().startPreRegister(
                        filePath,
                        mAuthorization,
                        (success, errorMsg) -> {
                            new Handler(Looper.getMainLooper()).post(() -> {
                                if (success) {
                                    AICallNoticeDialog.showDialog(AUIAICallVoicePrintRecordActivity.this,
                                            0, false, R.string.voiceprint_put_success, true, dialog -> finish());
                                } else {
                                    notifyRecognizeError(errorMsg);
                                }
                            });
                        }
                    );
                }
                if (!auto) {
                    uiHandler.removeMessages(MSG_AUTO_FINISH_PUSH_TO_RECORD);
                }
            }

            private void startUIUpdateProgress() {
                mUIProgressing = true;
                mStartRecordMillis = SystemClock.elapsedRealtime();
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
                    long duration = mStartRecordMillis > 0 ? SystemClock.elapsedRealtime() - mStartRecordMillis : 0;
                    if(duration >= 1000) {
                        String str = getString(R.string.voiceprint_recording) + " " + TimeUtil.videoPrintRecordFormatDuration(duration) + " S";
                        mVoicePrintRecordTimeTips.setText(str);
                    }


                    if (duration > 1 * 60 * 1000) {
                        hasNextRun = false;
                        onFinishTalk(false);
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

        });
    }

    private class AUIAICallVoicePrintMediaRecorder {

        private static final int RECORD_SAMPLATE = 16000;
        private static final int RECORD_CHANNEL = 1;
        private ARTCAIChatStreamRecorder mARTCAIChatStreamRecorder = null;
        ByteArrayOutputStream mPCMData ;

        private ARTCAIChatStreamRecorder.IARTCAIChatStreamRecorderCallback mAIChatRecorderCallback = new ARTCAIChatStreamRecorder.IARTCAIChatStreamRecorderCallback(){
            @Override
            public void onStreamRecorderAvaiable(String requestId, byte[] audioBuffer, int channels, int sample_rate) {
                if(audioBuffer.length > 0 ) {
                    mPCMData.write(audioBuffer, 0, audioBuffer.length);
                }
            }
            @Override
            public void onStreamRecorderError(String requestId, int errorCode, String errorMsg) {
                Logger.e("onStreamRecorderError, requestId: " + requestId + ", errorCode: " + errorCode + ", errorMsg: " + errorMsg);
            }
        };
        public AUIAICallVoicePrintMediaRecorder(Context context) {
        }

        public void startRecording() {

            if(mARTCAIChatStreamRecorder == null) {
                mARTCAIChatStreamRecorder = new ARTCAIChatStreamRecorder(AUIAICallVoicePrintRecordActivity.this, RECORD_SAMPLATE, RECORD_CHANNEL, "voiceprintrecord");
                mARTCAIChatStreamRecorder.setStreamRecordCallback(mAIChatRecorderCallback);
            }

            mPCMData = new ByteArrayOutputStream();

            mARTCAIChatStreamRecorder.startRecord();

        }

        public void stopRecording() {
            if(mARTCAIChatStreamRecorder != null) {
                mARTCAIChatStreamRecorder.stopRecord();
                mARTCAIChatStreamRecorder = null;
            }

            fileName = "/voideprintrecording_" + System.currentTimeMillis() + ".wav";
            File outputFile = new File(AUIAICallVoicePrintRecordActivity.this.getExternalFilesDir(null), fileName);
            Logger.i("PCMDumpUtil: " + outputFile.getAbsolutePath());
            filePath = outputFile.getAbsolutePath();

            try{
                FileOutputStream out = new FileOutputStream(filePath);
                byte[] pcmBytes = mPCMData.toByteArray();

                int totalDataLen = pcmBytes.length + 36; // 头部长度
                int byteRate = 16000 * 2; // 采样频率 * 16位音频 * 1通道
                out.write("RIFF".getBytes()); // Chunk ID
                out.write(intToByteArray(totalDataLen)); // Chunk Size
                out.write("WAVE".getBytes()); // Format
                out.write("fmt ".getBytes()); // Subchunk1 ID
                out.write(intToByteArray(16)); // Subchunk1 Size
                out.write(shortToByteArray((short) 1)); // AudioFormat
                out.write(shortToByteArray((short) 1)); // NumChannels
                out.write(intToByteArray(16000)); // SampleRate
                out.write(intToByteArray(byteRate)); // ByteRate
                out.write(shortToByteArray((short) 2)); // BlockAlign
                out.write(shortToByteArray((short) 16)); // BitsPerSample
                out.write("data".getBytes()); // Subchunk2 ID
                out.write(intToByteArray(pcmBytes.length)); // Subchunk2 Size
                out.write(pcmBytes);
                out.flush();
                out.close();
                out = null;
                outputFile = null;

            }
            catch (Exception e) {
                e.printStackTrace();
            }

            mPCMData = null;

        }

        private byte[] intToByteArray(int value) {
            return new byte[]{
                    (byte) (value & 0xff),
                    (byte) ((value >> 8) & 0xff),
                    (byte) ((value >> 16) & 0xff),
                    (byte) ((value >> 24) & 0xff)
            };
        }

        private byte[] shortToByteArray(short value) {
            return new byte[]{
                    (byte) (value & 0xff),
                    (byte) ((value >> 8) & 0xff)
            };
        }

    }

}
