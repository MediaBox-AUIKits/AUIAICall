package com.alivc.auicommon.common.base.util;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.text.TextUtils;
import android.widget.Toast;

import androidx.annotation.AnyThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import com.alivc.auicommon.common.base.AppContext;
import com.alivc.auicommon.common.base.log.Logger;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

/**
 * @author puke
 * @version 2021/5/8
 */
public class CommonUtil {
    public static final String OS = "Android";

    /**
     * @param context 上下文
     * @return 版本号
     */
    public static String getVersionCode(Context context) {
        PackageManager packageManager = context.getPackageManager();
        PackageInfo packageInfo;
        String versionCode = "";
        try {
            packageInfo = packageManager.getPackageInfo(context.getPackageName(), 0);
            versionCode = packageInfo.versionCode + "";
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return versionCode;
    }

    /**
     * @param context 上下文
     * @return 版本名称
     */
    public static String getVersionName(Context context) {
        PackageManager packageManager = context.getPackageManager();
        PackageInfo packageInfo;
        String versionName = "";
        try {
            packageInfo = packageManager.getPackageInfo(context.getPackageName(), 0);
            versionName = packageInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return versionName;
    }

    /**
     * @return 获取设备唯一ID
     */
    public static String getDeviceId() {
        return DeviceIdUtil.getDeviceId(AppContext.getContext());
    }

    @AnyThread
    public static void showDebugToast(final Context context, final String toast) {
//        if (!BuildConfig.DEBUG) {
//            return;
//        }
        showToast(context, "[仅Debug展示]:" + toast);
    }

    @AnyThread
    public static void showToast(final Context context, final @StringRes int id) {
        showToast(context, context.getResources().getString(id));
    }

    @AnyThread
    public static void showToast(final Context context, final String toast) {
        showToast(context, toast, Toast.LENGTH_SHORT);
    }

    @AnyThread
    public static void showDebugToastLong(final Context context, final String toast) {
//        if (!BuildConfig.DEBUG) {
//            return;
//        }
        showToast(context, "[仅Debug展示]:" + toast, Toast.LENGTH_SHORT);
    }

    @AnyThread
    public static void showToastLong(final Context context, final @StringRes int id) {
        showToast(context, context.getResources().getString(id));
    }

    @AnyThread
    public static void showToastLong(final Context context, final String toast) {
        showToast(context, toast, Toast.LENGTH_LONG);
    }

    @AnyThread
    public static void showToast(final Context context, final String toast, final int duration) {
        if (context == null || TextUtils.isEmpty(toast)) {
            return;
        }

        Logger.i("showToast: " + toast);
        ThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(context, toast, duration).show();
            }
        });
    }

    @NonNull
    public static String parseFormatString(@Nullable Long ts, String format) {
        if (ts == null) {
            return "";
        }
        if (ts <= 0 || TextUtils.isEmpty(format)) {
            return String.valueOf(ts);
        }
        return new SimpleDateFormat(format, Locale.getDefault()).format(new Date(ts));
    }

    @NonNull
    public static String parseHourMinuteSeconds(long millis) {
        try {
            return String.format(Locale.getDefault(), "%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millis),
                    TimeUnit.MILLISECONDS.toMinutes(millis) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis)),
                    TimeUnit.MILLISECONDS.toSeconds(millis) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis)));
        } catch (Throwable ignore) {
            return String.valueOf(millis);
        }
    }

    public static boolean isDebug(Context context) {
        try {
            ApplicationInfo info = context.getApplicationInfo();
            return (info.flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
        } catch (Exception ignored) {
        }
        return false;
    }

    /**
     * 获取当前app名称
     *
     * @param context
     * @return
     */
    public static String getAppName(Context context) {
        try {
            PackageManager packageManager = context.getPackageManager();
            PackageInfo packageInfo = packageManager.getPackageInfo(
                    context.getPackageName(), 0);
            int labelRes = packageInfo.applicationInfo.labelRes;
            return context.getResources().getString(labelRes);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
