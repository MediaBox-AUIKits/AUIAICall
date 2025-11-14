package com.aliyun.auikits.aicall;


import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
import com.alibaba.sdk.android.oss.callback.OSSProgressCallback;
import com.alibaba.sdk.android.oss.common.auth.OSSCredentialProvider;
import com.alibaba.sdk.android.oss.common.auth.OSSStsTokenCredentialProvider;
import com.alibaba.sdk.android.oss.internal.OSSAsyncTask;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.aliyun.auikits.aiagent.ARTCAIChatStreamRecorder;
import com.aliyun.auikits.aiagent.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;
import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aiagent.util.PCMDumpUtil;
import com.aliyun.auikits.aicall.util.AUIAICallAgentDebug;
import com.aliyun.auikits.aicall.util.AUIAICallAgentIdConfig;
import com.aliyun.auikits.aicall.util.AUIAICallClipboardUtils;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.AppServiceConst;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.TimeUtil;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.AIAgentSettingDialog;
import com.aliyun.auikits.aicall.widget.AICallNoticeDialog;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Random;

public class AUIAICallVoicePrintRecordActivity extends AppCompatActivity {
    private static final String TAG = "AUIAICallVoicePrintRecordActivity";
    private String fileName = null;
    private String filePath = null;
    private boolean isRecording = false;
    private static ARTCAICallServiceImpl.AppServerService mAppServerService = null;
    private String mUserId = null;
    private String mAuthorization = null;
    private AUIAICallVoicePrintOSSPut mOSSPut = null;
    private TextView mVoicePrintInfoTipeDesc = null;
    private TextView mVoicePrintReadDesc = null;
    private TextView mVoicePrintRecognizing = null;
    private ImageView mVoicePrintUploading = null;
    private TextView mVoicePrintRecordTimeTips = null;
    private AUIAICallVoicePrintMediaRecorder mMediaRecorder = null;
    private boolean mUIProgressing = false;
    private long mStartRecordMillis = 0;
    private Handler mHandler = null;

    public interface IAUIAICallVoicePrintOSSPutListener {
        void onSuccess(String filePath);
        void onFail();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_auiaicall_voiceprint_record);

        mHandler = new Handler();

        if (null != getIntent() && null != getIntent().getExtras()) {
            mUserId = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, null);
            mAuthorization = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, null);
        }

        getOssBucket();
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

                    if(mOSSPut != null) {
                        mOSSPut.startOSSPut(filePath, fileName, new IAUIAICallVoicePrintOSSPutListener() {
                            @Override
                            public void onSuccess(String filePath) {
                                getVoicePrintRecognize(filePath);
                            }

                            @Override
                            public void onFail() {
                                notifyRecognizeError("oss upload file failed");

                            }
                        });
                    }

                    mVoicePrintInfoTipeDesc.setVisibility(View.GONE);
                    mVoicePrintReadDesc.setVisibility(View.GONE);
                    mVoicePrintRecordTimeTips.setVisibility(View.GONE);
                    mVoicePrintRecognizing.setVisibility(View.VISIBLE);
                    mVoicePrintUploading.setVisibility(View.VISIBLE);
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



    public String gerRandomId() {
        Random random = new Random();
        return String.valueOf(random.nextInt(1000000));
    }

    private void getVoicePrintRecognize(String filePath) {
        if(mAppServerService != null) {
            mAppServerService = null;
        }

        boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);

        String mAppServer = null;
        if(usePreHost) {
            mAppServer = AUIAICallAgentDebug.PRE_HOST;
        } else {
            mAppServer = AppServiceConst.HOST;
        }

        if(mAppServerService == null) {
            mAppServerService = new ARTCAICallServiceImpl.AppServerService(mAppServer);
        }

        if(mAppServerService != null) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("user_id", mUserId);
                jsonObject.put("region", AUIAICallAgentIdConfig.getRegion());
                String voiceprintId = SettingStorage.getInstance().get(SettingStorage.KEY_VOICE_PRINT_ID);
                if(TextUtils.isEmpty(voiceprintId)){
                    voiceprintId = mUserId;
                }
                jsonObject.put("voiceprint_id", voiceprintId);
                JSONObject voiceprintObject = new JSONObject();
                voiceprintObject.put("Type", "url");
                voiceprintObject.put("Data", filePath);
                voiceprintObject.put("Format", "wav");
                jsonObject.put("input", voiceprintObject.toString());
                mAppServerService.postAsync(mAppServer, "/api/v2/aiagent/setAIAgentVoiceprint", mAuthorization, jsonObject, new IARTCAICallService.IARTCAICallServiceCallback() {
                    @Override
                    public void onSuccess(JSONObject jsonObject) {
                        Logger.i("getVoicePrintRecognize onSuccess:" + jsonObject.toString());
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_VOICE_PRINT_RECORD_ALRAEDY, true);
                        if(jsonObject.has("voiceprint_id")) {
                            SettingStorage.getInstance().set(SettingStorage.KEY_VOICE_PRINT_ID, jsonObject.optString("voiceprint_id"));
                        }
                        new Handler(Looper.getMainLooper()).post(new Runnable() {
                            @Override
                            public void run() {
                                AIAgentSettingDialog.updateDialogContent();
                                AICallNoticeDialog.showDialog(AUIAICallVoicePrintRecordActivity.this,
                                        0, false, R.string.voiceprint_put_success, true, new OnDismissListener() {
                                            @Override
                                            public void onDismiss(DialogPlus dialog) {
                                                finish();
                                            }
                                        });
                            }
                        });
                    }

                    @Override
                    public void onFail(int errorCode, String errorMsg) {
                        notifyRecognizeError(errorMsg);
                    }
                });
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    private void getOssBucket() {

        String mAppServer =  AppServiceConst.HOST;;

        if(mAppServerService == null) {
            mAppServerService = new ARTCAICallServiceImpl.AppServerService(mAppServer);
        }

        if(mAppServerService != null) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("user_id", mUserId);
                mAppServerService.postAsync(mAppServer, "/api/v2/aiagent/getOssConfig", mAuthorization, jsonObject, new IARTCAICallService.IARTCAICallServiceCallback() {
                    @Override
                    public void onSuccess(JSONObject jsonObject) {
                       Logger.i("getOssBucket onSuccess:" + jsonObject.toString());
                        mOSSPut = new AUIAICallVoicePrintOSSPut(jsonObject);
                    }

                    @Override
                    public void onFail(int errorCode, String errorMsg) {
                        Logger.e("getOssBucket error:" + errorCode + ", msg: " + errorMsg);
                    }
                });
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    private class AUIAICallVoicePrintOSSPut {
        private String bucket;
        private String region;
        private String accessKeyId;
        private String accessKeySecret;
        private String securityToken;
        private String basePath;



        public AUIAICallVoicePrintOSSPut(JSONObject jsonObject) {
            try {
                if(jsonObject.has("bucket")) {
                    this.bucket = jsonObject.getString("bucket");
                }
                if(jsonObject.has("region")) {
                    this.region = jsonObject.getString("region");
                }
                if(jsonObject.has("access_key_id")) {
                    this.accessKeyId = jsonObject.getString("access_key_id");
                }
                if(jsonObject.has("access_key_secret")) {
                    this.accessKeySecret = jsonObject.getString("access_key_secret");
                }
                if(jsonObject.has("sts_token")) {
                    this.securityToken = jsonObject.getString("sts_token");
                }
                if(jsonObject.has("base_path")) {
                    this.basePath = jsonObject.getString("base_path");
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        public String getEndPoint() {
            return "https://" + region + ".aliyuncs.com";
        }

        public void startOSSPut(String filePath, String fileName, IAUIAICallVoicePrintOSSPutListener listener) {
            if(!TextUtils.isEmpty(filePath)) {
                OSSCredentialProvider credentialProvider = new OSSStsTokenCredentialProvider(accessKeyId, accessKeySecret, securityToken);

                // 创建OSSClient实例。
                OSSClient oss = new OSSClient(getApplicationContext(), getEndPoint(), credentialProvider);
                oss.setRegion(region);

                String objectKey = basePath + "/" + fileName;

                PutObjectRequest put = new PutObjectRequest(bucket, objectKey, filePath);

                // 异步上传时可以设置进度回调。
                put.setProgressCallback(new OSSProgressCallback<PutObjectRequest>() {
                    @Override
                    public void onProgress(PutObjectRequest request, long currentSize, long totalSize) {
                    }
                });

                OSSAsyncTask task = oss.asyncPutObject(put, new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {
                    @Override
                    public void onSuccess(PutObjectRequest request, PutObjectResult result) {

                        try {
                            String ossUrl = oss.presignConstrainedObjectURL(bucket, objectKey, 3600);
                            if(listener != null) {
                                listener.onSuccess(ossUrl);
                            }
                        } catch (ClientException e) {
                            e.printStackTrace();
                        }
                    }

                    @Override
                    public void onFailure(PutObjectRequest request, ClientException clientExcepion, ServiceException serviceException) {
                        // 请求异常。
                        if (clientExcepion != null) {
                            // 本地异常，如网络异常等。
                            clientExcepion.printStackTrace();
                        }
                        if (serviceException != null) {
                            // 服务异常。
                            Logger.e(serviceException.getErrorCode());
                            Logger.e( serviceException.getRequestId());
                            Logger.e(serviceException.getHostId());
                            Logger.e(serviceException.getRawMessage());
                        }

                        if(listener != null) {
                            listener.onFail();
                        }
                    }
                });
            }
        }
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

            fileName = "/voideprintrecording_" + gerRandomId() + ".wav";
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
