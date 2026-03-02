package com.aliyun.auikits.aicall.voiceprint;

import android.content.Context;
import android.text.TextUtils;

import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
import com.alibaba.sdk.android.oss.common.auth.OSSCredentialProvider;
import com.alibaba.sdk.android.oss.common.auth.OSSStsTokenCredentialProvider;
import com.alibaba.sdk.android.oss.internal.OSSAsyncTask;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.aliyun.auikits.aiagent.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;
import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.util.AppServiceConst;
import com.aliyun.auikits.aicall.util.AUIAICallAgentDebug;
import com.aliyun.auikits.aicall.util.SettingStorage;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

/**
 * 声纹管理器，统一管理声纹配置、注册、删除等操作
 */
public class AUIAICallVoiceprintManager {

    private static AUIAICallVoiceprintManager sInstance = new AUIAICallVoiceprintManager();

    public static AUIAICallVoiceprintManager getInstance() {
        return sInstance;
    }

    private Context appContext;
    private ARTCAICallServiceImpl.AppServerService appServerService;

    // 声纹开关
    private boolean isEnable = true;

    // 声纹模式：false 预注册，true 无感注册
    private boolean isAutoRegister = false;

    // 当前用户ID
    private String userId = "";

    // 是否预发环境
    private boolean isPreEnv = false;

    // 预注册声纹数据
    private AUIAICallVoiceprintItem preRegisterVoiceprintItem = null;

    // 无感注册声纹数据
    private AUIAICallVoiceprintItem autoRegisterVoiceprintItem = null;

    // 当前通话使用的声纹 ID（临时缓存，用于无感注册回调）
    private String currentVoiceprintId = null;

    private AUIAICallVoiceprintManager() {
    }

    /**
     * 初始化，传入 Application Context
     */
    public void init(Context context) {
        this.appContext = context.getApplicationContext();
    }

    /**
     * 设置用户ID，会触发数据加载
     */
    public void setUserId(String userId) {
        if (TextUtils.equals(this.userId, userId)) {
            return;
        }
        this.userId = userId;
        if (!loadData()) {
            reset();
        }
    }

    /**
     * 设置环境（预发/线上），会触发数据重新加载
     */
    public void setPreEnv(boolean preEnv) {
        if (this.isPreEnv == preEnv) {
            return;
        }
        this.isPreEnv = preEnv;
        if (!loadData()) {
            reset();
        }
        this.appServerService = null;
    }

    /**
     * 获取声纹区域，固定返回 cn-shanghai
     */
    public String getRegion() {
        return "cn-shanghai";
    }

    /**
     * 获取声纹开关状态
     */
    public boolean isEnable() {
        return isEnable;
    }

    /**
     * 设置声纹开关
     */
    public void enableVoiceprint(boolean enable) {
        this.isEnable = enable;
        saveData();
    }

    /**
     * 获取当前注册模式
     * @return false 预注册，true 无感注册
     */
    public boolean isAutoRegister() {
        return isAutoRegister;
    }

    /**
     * 切换声纹注册模式
     * @param autoRegister false 预注册，true 无感注册
     */
    public void switchVoiceprintMode(boolean autoRegister) {
        this.isAutoRegister = autoRegister;
        saveData();
    }

    /**
     * 判断当前模式下是否已注册声纹
     */
    public boolean isRegistedVoiceprint() {
        if (isAutoRegister) {
            return autoRegisterVoiceprintItem != null;
        }
        return preRegisterVoiceprintItem != null;
    }

    /**
     * 获取当前模式下的声纹ID
     */
    public String getVoiceprintId() {
        if (isAutoRegister) {
            return autoRegisterVoiceprintItem != null ? autoRegisterVoiceprintItem.getVoiceprintId() : null;
        }
        return preRegisterVoiceprintItem != null ? preRegisterVoiceprintItem.getVoiceprintId() : null;
    }

    /**
     * 获取声纹配置文件存储目录
     */
    private File getDirectory() {
        if (appContext == null) {
            return null;
        }
        File dir = new File(appContext.getFilesDir(), "voiceprint");
        if (!dir.exists()) {
            boolean ok = dir.mkdirs();
            if (!ok) {
                Logger.e("Failed to create voiceprint directory: " + dir.getAbsolutePath());
            }
        }
        return dir;
    }

    /**
     * 获取当前用户+环境的声纹配置文件
     */
    private File getDataFile() {
        File dir = getDirectory();
        if (dir == null) {
            return null;
        }
        String suffix = isPreEnv ? "_data_pre.json" : "_data.json";
        return new File(dir, userId + suffix);
    }

    /**
     * 重置所有声纹状态
     */
    private void reset() {
        isEnable = true;
        isAutoRegister = false;
        preRegisterVoiceprintItem = null;
        autoRegisterVoiceprintItem = null;
    }

    /**
     * 从 JSON 文件加载声纹配置
     */
    private boolean loadData() {
        if (TextUtils.isEmpty(userId) || appContext == null) {
            return false;
        }
        File file = getDataFile();
        if (file == null || !file.exists()) {
            return false;
        }
        FileInputStream fis = null;
        try {
            fis = new FileInputStream(file);
            byte[] buf = new byte[(int) file.length()];
            int len = fis.read(buf);
            if (len <= 0) {
                return false;
            }
            String jsonStr = new String(buf, 0, len, "UTF-8");
            JSONObject obj = new JSONObject(jsonStr);
            
            reset();
            
            isEnable = obj.optBoolean("Enable", true);
            isAutoRegister = obj.optBoolean("AutoRegister", false);
            
            if (obj.has("Item")) {
                preRegisterVoiceprintItem = new AUIAICallVoiceprintItem(obj.getJSONObject("Item"));
            }
            if (obj.has("AutoItem")) {
                autoRegisterVoiceprintItem = new AUIAICallVoiceprintItem(obj.getJSONObject("AutoItem"));
            }
            
            Logger.i("Load preRegisterVoiceprintId: " + 
                    (preRegisterVoiceprintItem != null ? preRegisterVoiceprintItem.getVoiceprintId() : "未注册") +
                    " {uid: " + userId + ", pre: " + isPreEnv + "}");
            Logger.i("Load autoRegisterVoiceprintId: " + 
                    (autoRegisterVoiceprintItem != null ? autoRegisterVoiceprintItem.getVoiceprintId() : "未注册") +
                    " {uid: " + userId + ", pre: " + isPreEnv + "}");
            return true;
        } catch (Exception e) {
            Logger.e("Load data failed: " + e.getMessage());
        } finally {
            if (fis != null) {
                try {
                    fis.close();
                } catch (Exception ignore) {
                }
            }
        }
        return false;
    }

    /**
     * 保存声纹配置到 JSON 文件
     */
    private void saveData() {
        if (TextUtils.isEmpty(userId) || appContext == null) {
            return;
        }
        File file = getDataFile();
        if (file == null) {
            return;
        }
        FileOutputStream fos = null;
        try {
            JSONObject obj = new JSONObject();
            obj.put("Enable", isEnable);
            obj.put("AutoRegister", isAutoRegister);
            
            if (preRegisterVoiceprintItem != null) {
                obj.put("Item", preRegisterVoiceprintItem.toJson());
            }
            if (autoRegisterVoiceprintItem != null) {
                obj.put("AutoItem", autoRegisterVoiceprintItem.toJson());
            }
            
            fos = new FileOutputStream(file, false);
            fos.write(obj.toString().getBytes("UTF-8"));
            fos.flush();
            
            Logger.i("Save preRegisterVoiceprintId: " + 
                    (preRegisterVoiceprintItem != null ? preRegisterVoiceprintItem.getVoiceprintId() : "未注册") +
                    " {uid: " + userId + ", pre: " + isPreEnv + "}");
            Logger.i("Save autoRegisterVoiceprintId: " + 
                    (autoRegisterVoiceprintItem != null ? autoRegisterVoiceprintItem.getVoiceprintId() : "未注册") +
                    " {uid: " + userId + ", pre: " + isPreEnv + "}");
        } catch (Exception e) {
            Logger.e("Save data failed: " + e.getMessage());
        } finally {
            if (fos != null) {
                try {
                    fos.close();
                } catch (Exception ignore) {
                }
            }
        }
    }

    /**
     * 获取或创建 AppServerService
     */
    private ARTCAICallServiceImpl.AppServerService getAppServerService() {
        if (appServerService != null) {
            return appServerService;
        }
        // 使用 Manager 自身的 isPreEnv 状态，确保与数据文件路径保持一致
        String host = isPreEnv ? AUIAICallAgentDebug.PRE_HOST : AppServiceConst.HOST;
        appServerService = new ARTCAICallServiceImpl.AppServerService(host);
        Logger.i("Create AppServerService with host: " + host + " (isPreEnv: " + isPreEnv + ")");
        return appServerService;
    }

    /**
     * 声纹操作回调接口
     */
    public interface VoiceprintCallback {
        void onResult(boolean success, String errorMsg);
    }

    /**
     * 预注册声纹：录音 → OSS上传 → 服务端注册
     */
    public void startPreRegister(String wavFilePath, String authorization, VoiceprintCallback callback) {
        if (TextUtils.isEmpty(userId)) {
            if (callback != null) {
                callback.onResult(false, "userId is empty");
            }
            return;
        }

        // 第一步：获取 OSS 配置
        requestOssConfig(authorization, (ossConfig, errorMsg) -> {
            if (ossConfig == null) {
                if (callback != null) {
                    callback.onResult(false, errorMsg);
                }
                return;
            }

            // 第二步：上传到 OSS
            uploadFileToOss(wavFilePath, ossConfig, (ossUrl, error) -> {
                if (ossUrl == null) {
                    if (callback != null) {
                        callback.onResult(false, error);
                    }
                    return;
                }

                // 第三步：注册声纹
                registerVoiceprint(ossUrl, authorization, (voiceprintId, error1) -> {
                    if (voiceprintId == null) {
                        if (callback != null) {
                            callback.onResult(false, error1);
                        }
                        return;
                    }

                    // 第四步：保存到本地 JSON
                    AUIAICallVoiceprintItem item = new AUIAICallVoiceprintItem(voiceprintId);
                    item.setFilePath(wavFilePath);
                    item.setOssUrl(ossUrl);
                    preRegisterVoiceprintItem = item;
                    saveData();

                    if (callback != null) {
                        callback.onResult(true, null);
                    }
                });
            });
        });
    }

    /**
     * 请求 OSS 配置
     */
    private void requestOssConfig(String authorization, OssConfigCallback callback) {
        try {
            JSONObject body = new JSONObject();
            body.put("user_id", userId);
            getAppServerService().postAsync(
                    null,
                    "/api/v2/aiagent/getOssConfig",
                    authorization,
                    body,
                    new IARTCAICallService.IARTCAICallServiceCallback() {
                        @Override
                        public void onSuccess(JSONObject jsonObject) {
                            if (callback != null) {
                                callback.onResult(jsonObject, null);
                            }
                        }

                        @Override
                        public void onFail(int errorCode, String errorMsg) {
                            if (callback != null) {
                                callback.onResult(null, errorMsg);
                            }
                        }
                    }
            );
        } catch (JSONException e) {
            if (callback != null) {
                callback.onResult(null, e.getMessage());
            }
        }
    }

    /**
     * 上传文件到 OSS
     */
    private void uploadFileToOss(String wavFilePath, JSONObject ossConfig, OssUploadCallback callback) {
        try {
            String bucket = ossConfig.optString("bucket", "");
            String region = ossConfig.optString("region", "");
            String accessKeyId = ossConfig.optString("access_key_id", "");
            String accessKeySecret = ossConfig.optString("access_key_secret", "");
            String securityToken = ossConfig.optString("sts_token", "");
            String basePath = ossConfig.optString("base_path", "");

            String endpoint = "https://" + region + ".aliyuncs.com";
            String objectKey = basePath + "/" + new File(wavFilePath).getName();

            OSSCredentialProvider credentialProvider = new OSSStsTokenCredentialProvider(
                    accessKeyId, accessKeySecret, securityToken);
            OSSClient oss = new OSSClient(appContext, endpoint, credentialProvider);
            oss.setRegion(region);

            PutObjectRequest put = new PutObjectRequest(bucket, objectKey, wavFilePath);

            OSSAsyncTask task = oss.asyncPutObject(put, new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {
                @Override
                public void onSuccess(PutObjectRequest request, PutObjectResult result) {
                    try {
                        String ossUrl = oss.presignConstrainedObjectURL(bucket, objectKey, 3600);
                        if (callback != null) {
                            callback.onResult(ossUrl, null);
                        }
                    } catch (ClientException e) {
                        if (callback != null) {
                            callback.onResult(null, e.getMessage());
                        }
                    }
                }

                @Override
                public void onFailure(PutObjectRequest request, ClientException clientException, ServiceException serviceException) {
                    String errorMsg = "Unknown error";
                    if (clientException != null) {
                        errorMsg = clientException.getMessage();
                    } else if (serviceException != null) {
                        errorMsg = serviceException.getRawMessage();
                    }
                    if (callback != null) {
                        callback.onResult(null, errorMsg);
                    }
                }
            });
        } catch (Exception e) {
            if (callback != null) {
                callback.onResult(null, e.getMessage());
            }
        }
    }

    /**
     * 注册声纹
     */
    private void registerVoiceprint(String audioOssUrl, String authorization, VoiceprintIdCallback callback) {
        try {
            String voiceprintId = userId + "_" + System.currentTimeMillis();
            
            JSONObject input = new JSONObject();
            input.put("Type", "oss");
            input.put("Data", audioOssUrl);
            input.put("Format", "wav");

            JSONObject body = new JSONObject();
            body.put("user_id", userId);
            body.put("region", getRegion());
            body.put("voiceprint_id", voiceprintId);
            body.put("input", input.toString());

            getAppServerService().postAsync(
                    null,
                    "/api/v2/aiagent/setAIAgentVoiceprint",
                    authorization,
                    body,
                    new IARTCAICallService.IARTCAICallServiceCallback() {
                        @Override
                        public void onSuccess(JSONObject jsonObject) {
                            String id = jsonObject.optString("voiceprint_id", null);
                            if (TextUtils.isEmpty(id)) {
                                if (callback != null) {
                                    callback.onResult(null, jsonObject.toString());
                                }
                            } else {
                                if (callback != null) {
                                    callback.onResult(id, null);
                                }
                            }
                        }

                        @Override
                        public void onFail(int errorCode, String errorMsg) {
                            if (callback != null) {
                                callback.onResult(null, errorMsg);
                            }
                        }
                    }
            );
        } catch (JSONException e) {
            if (callback != null) {
                callback.onResult(null, e.getMessage());
            }
        }
    }

    /**
     * 生成声纹ID，用于无感注册模式
     */
    public String generateVoiceprintId() {
        currentVoiceprintId = userId + "_" + System.currentTimeMillis();
        Logger.i("Generated voiceprint ID for current call: " + currentVoiceprintId);
        return currentVoiceprintId;
    }

    /**
     * 获取当前通话使用的声纹 ID（可能是刚生成的临时 ID）
     */
    public String getCurrentVoiceprintId() {
        return currentVoiceprintId;
    }

    /**
     * 无感注册模式：声纹注册完成时调用
     */
    public void onAutoRegisted(String voiceprintId) {
        if (!isAutoRegister) {
            Logger.i("Skip onAutoRegisted: not in auto-register mode");
            return;
        }
        
        if (TextUtils.isEmpty(voiceprintId)) {
            Logger.w("Skip onAutoRegisted: voiceprintId is empty");
            return;
        }
        
        // 验证 ID 是否匹配当前通话生成的 ID
        if (currentVoiceprintId != null && !TextUtils.equals(currentVoiceprintId, voiceprintId)) {
            Logger.w("VoiceprintId mismatch! Expected: " + currentVoiceprintId + ", Got: " + voiceprintId);
        }
        
        if (autoRegisterVoiceprintItem != null) {
            if (TextUtils.equals(autoRegisterVoiceprintItem.getVoiceprintId(), voiceprintId)) {
                Logger.i("Auto-register voiceprint already saved: " + voiceprintId);
                currentVoiceprintId = null;  // 清除临时 ID
                return;
            } else {
                Logger.w("Auto register voiceprintId changed, old: " +
                        autoRegisterVoiceprintItem.getVoiceprintId() + ", new: " + voiceprintId);
            }
        }
        
        autoRegisterVoiceprintItem = new AUIAICallVoiceprintItem(voiceprintId);
        saveData();
        currentVoiceprintId = null;  // 清除临时 ID
        Logger.i("Auto-register voiceprint saved successfully: " + voiceprintId);
    }

    /**
     * 删除无感注册的声纹（乐观删除策略：先删除本地，再通知服务端）
     */
    public void removeAutoRegister(String authorization, VoiceprintCallback callback) {
        if (autoRegisterVoiceprintItem == null) {
            if (callback != null) {
                callback.onResult(true, null);
            }
            return;
        }

        final String voiceprintId = autoRegisterVoiceprintItem.getVoiceprintId();
        
        autoRegisterVoiceprintItem = null;
        saveData();
        Logger.i("Auto-register voiceprint removed locally: " + voiceprintId);
        
        // 立即回调成功，不等待服务端响应
        if (callback != null) {
            callback.onResult(true, null);
        }
        
        // 尝试通知服务端清除
        try {
            JSONObject body = new JSONObject();
            body.put("user_id", userId);
            body.put("region", getRegion());
            body.put("voiceprint_id", voiceprintId);
            body.put("registration_mode", "Implicit");

            Logger.i("Notifying server to clear auto-register voiceprint: " + voiceprintId);

            getAppServerService().postAsync(
                    null,
                    "/api/v2/aiagent/clearAIAgentVoiceprint",
                    authorization,
                    body,
                    new IARTCAICallService.IARTCAICallServiceCallback() {
                        @Override
                        public void onSuccess(JSONObject response) {
                            int code = response.optInt("code", -1);
                            String message = response.optString("message", "");
                            if (code == 200) {
                                Logger.i("Server cleared auto-register voiceprint successfully");
                            } else {
                                Logger.w("Server clear failed with code: " + code + ", message: " + message);
                            }
                        }

                        @Override
                        public void onFail(int errorCode, String errorMsg) {
                            // 服务端清除失败不影响用户体验，只记录日志
                            Logger.w("Server clear voiceprint failed (ignored): errorCode=" + errorCode + ", errorMsg=" + errorMsg);
                        }
                    }
            );
        } catch (JSONException e) {
            Logger.w("Failed to build server clear request (ignored): " + e.getMessage());
        }
    }

    /**
     * 删除预注册的声纹
     */
    public void removePreRegister(String authorization, VoiceprintCallback callback) {
        if (preRegisterVoiceprintItem == null) {
            if (callback != null) {
                callback.onResult(true, null);
            }
            return;
        }

        final String voiceprintId = preRegisterVoiceprintItem.getVoiceprintId();
        try {
            JSONObject body = new JSONObject();
            body.put("user_id", userId);
            body.put("region", getRegion());
            body.put("voiceprint_id", voiceprintId);
            body.put("registration_mode", "Explicit");

            Logger.i("Clearing pre-register voiceprint, voiceprintId: " + voiceprintId);

            getAppServerService().postAsync(
                    null,
                    "/api/v2/aiagent/clearAIAgentVoiceprint",
                    authorization,
                    body,
                    new IARTCAICallService.IARTCAICallServiceCallback() {
                        @Override
                        public void onSuccess(JSONObject response) {
                            int code = response.optInt("code", -1);
                            String message = response.optString("message", "");
                            Logger.i("clearAIAgentVoiceprint result: code=" + code + ", message=" + message);

                            if (code == 200) {
                                preRegisterVoiceprintItem = null;
                                saveData();
                                Logger.i("Pre-register voiceprint cleared successfully");
                                if (callback != null) {
                                    callback.onResult(true, null);
                                }
                            } else {
                                Logger.w("clearAIAgentVoiceprint returned non-200 code: " + code);
                                if (callback != null) {
                                    callback.onResult(false, message);
                                }
                            }
                        }

                        @Override
                        public void onFail(int errorCode, String errorMsg) {
                            Logger.e("clearAIAgentVoiceprint onFail: errorCode=" + errorCode + ", errorMsg=" + errorMsg);
                            if (callback != null) {
                                callback.onResult(false, errorMsg);
                            }
                        }
                    }
            );
        } catch (JSONException e) {
            Logger.e("removePreRegister exception: " + e.getMessage());
            if (callback != null) {
                callback.onResult(false, e.getMessage());
            }
        }
    }

    // 内部回调接口
    private interface OssConfigCallback {
        void onResult(JSONObject ossConfig, String error);
    }

    private interface OssUploadCallback {
        void onResult(String ossUrl, String error);
    }

    private interface VoiceprintIdCallback {
        void onResult(String voiceprintId, String error);
    }
}
