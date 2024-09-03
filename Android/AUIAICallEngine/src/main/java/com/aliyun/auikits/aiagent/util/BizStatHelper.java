package com.aliyun.auikits.aiagent.util;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.aliyun.auikits.aiagent.network.DefaultOkHttpFactory;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class BizStatHelper {
    private static final String URL = "https://alivc-aio.cn-hangzhou.log.aliyuncs.com/logstores/ai_agent/track";

    private final static boolean DEBUG = false;

    private static class OneLog {
        String event;
        long stm;
        String args;
    }

    private static ArrayList<OneLog> sBufferList = new ArrayList();
    private static boolean sHasUpload = true;
    private static Context sContext = null;
    private static Handler sHandler = null;
    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

    public static void init(Context context) {
        sContext = context;
        sHandler = new Handler(Looper.getMainLooper());
    }

    /**
     *
     * @param event
     * @param args
     */
    public static void stat(String event, String args) {
        if (DEBUG) {
            Log.d("AUIAICall", "BizStatHelper stat [event: " +
                    event + ", " + args + "]");
        }

        OneLog oneLog = new OneLog();
        oneLog.event = event;
        oneLog.stm = System.currentTimeMillis();
        oneLog.args = args;

        boolean needUpload = false;
        synchronized (BizStatHelper.class) {
            sBufferList.add(oneLog);
            if (sHasUpload) {
                sHasUpload = false;
                needUpload = true;
            }
        }

        if (needUpload) {
            sHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    upload();
                }
            }, 100);
        }
    }

    private static void upload() {
        final ArrayList<OneLog> tmpList;
        synchronized (BizStatHelper.class) {
            tmpList = sBufferList;
            sBufferList = new ArrayList<>();
            sHasUpload = true;
        }

        if (null != tmpList && tmpList.size() > 0) {
            try {
                JSONObject bodyJsonObject = new JSONObject();
                bodyJsonObject.put("__topic__", "");
                bodyJsonObject.put("__source__", "");

                JSONArray logJsonArray = new JSONArray();
                bodyJsonObject.put("__logs__", logJsonArray);

                for (OneLog oneLog : tmpList) {
                    JSONObject oneLogJson = new JSONObject();
                    oneLogJson.put("event", oneLog.event);
                    oneLogJson.put("stm", String.valueOf(oneLog.stm));
                    oneLogJson.put("args", oneLog.args);
                    logJsonArray.put(oneLogJson);
                }

                Map<String, String> tags = getStatTags();
                JSONObject tagsJson = new JSONObject();
                for (Map.Entry<String, String> tagEntry : tags.entrySet()) {
                    String tagKey = tagEntry.getKey();
                    String tagValue = tagEntry.getValue();
                    tagsJson.put(tagKey, tagValue);
                }
                bodyJsonObject.put("__tags__", tagsJson);
                final String body = bodyJsonObject.toString();

                Map<String, String> headers = new HashMap<>();
                headers.put("x-log-apiversion", "0.6.0");
                headers.put("x-log-bodyrawsize", String.valueOf(body.length()));

                if (DEBUG) {
                    Log.d("AUIAICall", "BizStatHelper upload [body@" + body.hashCode() + ": " + body + "]");
                }

                RequestBody requestBody = RequestBody.create(
                        body,
                        JSON);
                Request request = new Request.Builder()
                        .url(URL)
                        .header("x-log-apiversion", "0.6.0")
                        .header("x-log-bodyrawsize", String.valueOf(body.length()))
                        .post(requestBody)
                        .build();
                DefaultOkHttpFactory.getHttpClient().newCall(request).enqueue(new Callback() {

                    @Override
                    public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {

                    }

                    @Override
                    public void onFailure(@NonNull Call call, @NonNull IOException e) {

                    }
                });
            } catch (JSONException ex) {
                ex.printStackTrace();
            }
        }
    }

    /**
     * 公参
     */
    private static Map<String, String> getStatTags() {
        Map<String, String> tags = new HashMap<>();
        try {
            if (null != sContext) {
                tags.put("tt", getTerminalType());
                tags.put("db", Build.BRAND);
                tags.put("d_manu", Build.MANUFACTURER);
                tags.put("dm", Build.MODEL);
                tags.put("os", "android");
                tags.put("osv", String.valueOf(Build.VERSION.SDK_INT));
                tags.put("appid", sContext.getPackageName());
                tags.put("appname", getAppName());
                tags.put("appver", getAppVersion());
                tags.put("nt", "");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return tags;
    }

    public static synchronized String getAppName() {
        String appName = "";
        try {
            PackageManager packageManager = sContext.getPackageManager();
            PackageInfo packageInfo = packageManager.getPackageInfo(
                    sContext.getPackageName(), 0);
            int labelRes = packageInfo.applicationInfo.labelRes;
            appName = sContext.getResources().getString(labelRes);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return appName;
    }

    /**
     * 获取当前apk的版本名
     * @return
     */
    public static String getAppVersion() {
        String versionName = "";
        try {
            //获取软件版本号，对应AndroidManifest.xml下android:versionName
            versionName = sContext.getPackageManager().
                    getPackageInfo(sContext.getPackageName(), 0).versionName;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return versionName;
    }

    private static String getTerminalType() {
        String ret = "phone";
        if (null != sContext && null != sContext.getResources() && null != sContext.getResources().getConfiguration()) {
            int screenLayout = sContext.getResources().getConfiguration().screenLayout;
            if ((screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) > Configuration.SCREENLAYOUT_SIZE_LARGE) {
                ret = "pad";
            } else {
                ret = "phone";
            }
        }
        return ret;
    }

}
