package com.aliyun.auikits.aicall.util;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * 智能体场景配置远端更新管理器
 */
public class AUIAICallAgentConfigUpdater {

    private static final String TAG = "AgentConfigUpdater";
    
    // CDN 配置文件地址
    private static final String CDN_BASE_URL = "xxx";
    
    // 本地缓存目录
    private static final String CACHE_DIR_NAME = "agent_config_cache";
    
    
    // 版本号 key（用于判断是否需要更新）
    private static final String KEY_VERSION = "version";
    
    private static AUIAICallAgentConfigUpdater sInstance;
    private Context mContext;
    private Handler mMainHandler;
    
    public interface UpdateCallback {
        /**
         * 配置更新成功
         * @param isUpdated 是否有新版本更新
         */
        void onSuccess(boolean isUpdated);
        
        /**
         * 配置更新失败（网络错误等）
         * @param errorMsg 错误信息
         */
        void onFailure(String errorMsg);
    }
    
    private AUIAICallAgentConfigUpdater(Context context) {
        mContext = context.getApplicationContext();
        mMainHandler = new Handler(Looper.getMainLooper());
    }
    
    public static AUIAICallAgentConfigUpdater getInstance(Context context) {
        if (sInstance == null) {
            synchronized (AUIAICallAgentConfigUpdater.class) {
                if (sInstance == null) {
                    sInstance = new AUIAICallAgentConfigUpdater(context);
                }
            }
        }
        return sInstance;
    }
    
    /**
     * 重新加载配置
     * 1. 先从本地加载（Assets 或缓存）
     * 2. 异步从远端更新（仅线上环境）
     * @param fileName 配置文件名
     * @param isPreEnv 是否预发环境
     * @param callback 更新回调
     */
    public void reloadConfig(String fileName, boolean isPreEnv, UpdateCallback callback) {
        if (isPreEnv) {
            // 预发环境：只从 Assets 本地读取，不更新
            Log.i(TAG, "Pre environment, load from local assets only");
            if (callback != null) {
                mMainHandler.post(() -> callback.onSuccess(false));
            }
            return;
        }
        
        // 线上环境：异步从远端更新
        updateConfigFromRemote(fileName, callback);
    }
    

    
    /**
     * 从远端 CDN 异步更新配置文件
     */
    private void updateConfigFromRemote(String fileName, UpdateCallback callback) {
        new Thread(() -> {
            HttpURLConnection connection = null;
            try {
                String urlString = CDN_BASE_URL + fileName;
                Log.i(TAG, "Fetching config from: " + urlString);
                
                URL url = new URL(urlString);
                connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("GET");
                connection.setConnectTimeout(10000);
                connection.setReadTimeout(10000);
                // 禁用缓存，确保获取最新配置
                connection.setUseCaches(false);
                connection.addRequestProperty("Cache-Control", "no-cache");
                
                int responseCode = connection.getResponseCode();
                if (responseCode != HttpURLConnection.HTTP_OK) {
                    String errorMsg = "HTTP error code: " + responseCode;
                    Log.e(TAG, errorMsg);
                    notifyFailure(callback, errorMsg);
                    return;
                }
                
                // 读取响应内容
                InputStream inputStream = connection.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
                StringBuilder builder = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    builder.append(line);
                }
                reader.close();
                
                String jsonContent = builder.toString();
                
                // 解析并校验 JSON 格式
                if (!isValidJson(jsonContent)) {
                    String errorMsg = "Invalid JSON format";
                    Log.e(TAG, errorMsg);
                    notifyFailure(callback, errorMsg);
                    return;
                }
                
                // 检查版本号，决定是否更新
                boolean shouldUpdate = checkAndUpdateVersion(fileName, jsonContent);
                
                if (shouldUpdate) {
                    // 保存到本地缓存
                    saveToCache(fileName, jsonContent);
                    Log.i(TAG, "Config updated successfully: " + fileName);
                    notifySuccess(callback, true);
                } else {
                    Log.i(TAG, "Config version not changed, skip update");
                    notifySuccess(callback, false);
                }
                
            } catch (Exception e) {
                String errorMsg = "Update failed: " + e.getMessage();
                Log.e(TAG, errorMsg, e);
                notifyFailure(callback, errorMsg);
            } finally {
                if (connection != null) {
                    connection.disconnect();
                }
            }
        }).start();
    }
    
    /**
     * 校验 JSON 格式是否有效
     */
    private boolean isValidJson(String jsonContent) {
        if (jsonContent == null || jsonContent.trim().isEmpty()) {
            return false;
        }
        try {
            new JSONObject(jsonContent);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * 检查版本号并判断是否需要更新
     * @return true 表示需要更新（远端版本 >= 本地版本，或首次下载）
     */
    private boolean checkAndUpdateVersion(String fileName, String newContent) {
        try {
            JSONObject newJson = new JSONObject(newContent);
            int newVersion = newJson.optInt(KEY_VERSION, 0);
            
            // 读取本地缓存的版本号
            String cachedContent = loadFromCache(fileName);
            if (cachedContent == null || cachedContent.isEmpty()) {
                // 本地没有缓存，直接更新
                Log.i(TAG, "No local cache, download from CDN, version: " + newVersion);
                return true;
            }
            
            JSONObject cachedJson = new JSONObject(cachedContent);
            int cachedVersion = cachedJson.optInt(KEY_VERSION, 0);
            
            // 比较版本号：远端版本 >= 本地版本时使用远端
            if (newVersion >= cachedVersion) {
                if (newVersion > cachedVersion) {
                    Log.i(TAG, "Version updated: " + cachedVersion + " -> " + newVersion);
                } else {
                    Log.i(TAG, "Version unchanged (" + cachedVersion + "), but use CDN config");
                }
                return true;
            } else {
                // 本地版本 > 远端版本，使用本地版本
                Log.i(TAG, "Local version (" + cachedVersion + ") > CDN version (" + newVersion + "), keep local");
                return false;
            }
            
        } catch (Exception e) {
            Log.e(TAG, "Check version failed", e);
            // 出错时也认为需要更新
            return true;
        }
    }
    
    /**
     * 保存配置到本地缓存
     */
    private void saveToCache(String fileName, String content) {
        FileOutputStream fos = null;
        try {
            File cacheDir = new File(mContext.getFilesDir(), CACHE_DIR_NAME);
            if (!cacheDir.exists()) {
                cacheDir.mkdirs();
            }
            
            File cacheFile = new File(cacheDir, fileName);
            fos = new FileOutputStream(cacheFile);
            fos.write(content.getBytes("UTF-8"));
            fos.flush();
            
            Log.i(TAG, "Config saved to: " + cacheFile.getAbsolutePath());
        } catch (Exception e) {
            Log.e(TAG, "Save cache failed", e);
        } finally {
            if (fos != null) {
                try {
                    fos.close();
                } catch (Exception ignored) {
                }
            }
        }
    }
    
    /**
     * 从本地缓存读取配置
     */
    private String loadFromCache(String fileName) {
        FileInputStream fis = null;
        try {
            File cacheFile = new File(mContext.getFilesDir(), CACHE_DIR_NAME + "/" + fileName);
            if (!cacheFile.exists()) {
                return null;
            }
            
            fis = new FileInputStream(cacheFile);
            BufferedReader reader = new BufferedReader(new InputStreamReader(fis));
            StringBuilder builder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
            return builder.toString();
        } catch (Exception e) {
            Log.e(TAG, "Load cache failed", e);
            return null;
        } finally {
            if (fis != null) {
                try {
                    fis.close();
                } catch (Exception ignored) {
                }
            }
        }
    }
    
    /**
     * 获取配置内容（优先从缓存，其次从 Assets）
     */
    public String getConfig(String fileName) {
        // 优先从缓存读取
        String cachedContent = loadFromCache(fileName);
        if (cachedContent != null && !cachedContent.isEmpty()) {
            Log.i(TAG, "Load config from cache: " + fileName);
            return cachedContent;
        }
        
        // 缓存不存在，从 Assets 读取
        Log.i(TAG, "Load config from assets: " + fileName);
        return loadFromAssets(fileName);
    }
    
    /**
     * 从 Assets 读取配置（兜底方案）
     */
    private String loadFromAssets(String fileName) {
        try {
            String assetPath = "AgentConfig/" + fileName;
            InputStream is = mContext.getAssets().open(assetPath);
            BufferedReader reader = new BufferedReader(new InputStreamReader(is));
            StringBuilder builder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
            reader.close();
            return builder.toString();
        } catch (Exception e) {
            Log.e(TAG, "Load from assets failed", e);
            return null;
        }
    }
    
    /**
     * 清除本地缓存
     */
    public void clearCache() {
        try {
            File cacheDir = new File(mContext.getFilesDir(), CACHE_DIR_NAME);
            if (cacheDir.exists() && cacheDir.isDirectory()) {
                File[] files = cacheDir.listFiles();
                if (files != null) {
                    for (File file : files) {
                        file.delete();
                    }
                }
            }
            Log.i(TAG, "Cache cleared");
        } catch (Exception e) {
            Log.e(TAG, "Clear cache failed", e);
        }
    }
    
    private void notifySuccess(UpdateCallback callback, boolean isUpdated) {
        if (callback != null) {
            mMainHandler.post(() -> callback.onSuccess(isUpdated));
        }
    }
    
    private void notifyFailure(UpdateCallback callback, String errorMsg) {
        if (callback != null) {
            mMainHandler.post(() -> callback.onFailure(errorMsg));
        }
    }
}
