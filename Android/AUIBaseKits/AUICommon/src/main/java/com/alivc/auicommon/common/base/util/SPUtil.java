package com.alivc.auicommon.common.base.util;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.AppContext;

/**
 * Created by KyleCe on 2022/1/18
 */
public class SPUtil {
    private static final String SP_NAME = "vPaaS_android_sp";

    private static SharedPreferences getSp(String spName) {
        return AppContext.getContext().getSharedPreferences(spName, Context.MODE_PRIVATE);
    }

    public static void set(String spName, String key, String value) {
        getSp(spName).edit().putString(key, value).apply();
    }

    public static void remove(String spName, String key) {
        getSp(spName).edit().remove(key).apply();
    }

    public static String get(String spName, String key, String defValue) {
        return getSp(spName).getString(key, defValue);
    }

    public static class Permission {
        private static final String KEY_PERMISSION_REQUESTED_YET_PREFIX = "key_permission_not_requested_yet_prefix_";

        public static boolean hasRequestedAlreadyAfterInstalled(String pageName) {
            return getSp(SP_NAME).getBoolean(KEY_PERMISSION_REQUESTED_YET_PREFIX + pageName, false);
        }

        public static void markRequestedAlreadyAfterInstalled(String pageName) {
            getSp(SP_NAME).edit().putBoolean(KEY_PERMISSION_REQUESTED_YET_PREFIX + pageName, true).apply();
        }
    }

    public static class Secret {
        private static final String KEY_SECRETE_PREFIX = "key_secrete_prefix_";
        private static final String KEY_SECRETE_BEAN = KEY_SECRETE_PREFIX + "bean_json_string";

        public static void storeAppIdConfig(@NonNull String config) {
            getSp(SP_NAME).edit().putString(KEY_SECRETE_BEAN, config).apply();
        }

        public static String getAppIdConfig() {
            return getSp(SP_NAME).getString(KEY_SECRETE_BEAN, "");
        }
    }

    public static class RemoteResource {
        private static final String KEY_REMOTE_RESOURCE_PREFIX = "key_remote_resource_prefix_";
        private static final String KEY_REMOTE_RESOURCE_BEAUTY_PRO_DOWNLOADED_PATH = KEY_REMOTE_RESOURCE_PREFIX + "beauty_pro_downloaded_path";
        private static final String KEY_REMOTE_RESOURCE_BEAUTY_PRO_PATH = KEY_REMOTE_RESOURCE_PREFIX + "beauty_pro_path";

        public static void storeBeautyProDownloadedPath(@Nullable String path) {
            getSp(SP_NAME).edit().putString(KEY_REMOTE_RESOURCE_BEAUTY_PRO_DOWNLOADED_PATH, path).apply();
        }

        public static void removeBeautyProDownloadedPath() {
            getSp(SP_NAME).edit().remove(KEY_REMOTE_RESOURCE_BEAUTY_PRO_DOWNLOADED_PATH).apply();
        }

        public static String getBeautyProDownloadedPath() {
            return getSp(SP_NAME).getString(KEY_REMOTE_RESOURCE_BEAUTY_PRO_DOWNLOADED_PATH, "");
        }

        public static void storeBeautyProResPath(@Nullable String path) {
            getSp(SP_NAME).edit().putString(KEY_REMOTE_RESOURCE_BEAUTY_PRO_PATH, path).apply();
        }

        public static void removeBeautyProResPath() {
            getSp(SP_NAME).edit().remove(KEY_REMOTE_RESOURCE_BEAUTY_PRO_PATH).apply();
        }

        public static String getBeautyProResPath() {
            return getSp(SP_NAME).getString(KEY_REMOTE_RESOURCE_BEAUTY_PRO_PATH, "");
        }
    }

    public static class Guide {
        private static final String KEY_GUIDE_PREFIX = "key_guide_prefix_";
        private static final String KEY_PRESENTED = KEY_GUIDE_PREFIX + "presented";

        public static void incScaleHintPresented(int count) {
            getSp(SP_NAME).edit().putInt(KEY_PRESENTED, count).apply();
        }

        public static int getScaleHintPresentTimes() {
            return getSp(SP_NAME).getInt(KEY_PRESENTED, 0);
        }
    }

    public static class Goods360 {
        private static final String KEY_GOODS_360_PREFIX = "key_goods_360_";
        private static final String KEY_DOWNLOADED_AND_UNZIPPED = KEY_GOODS_360_PREFIX + "downloaded_and_unzipped";

        public static void markDownloadedAndUnzipped(String uuid) {
            getSp(SP_NAME).edit().putBoolean(KEY_DOWNLOADED_AND_UNZIPPED + "_" + uuid, true).apply();
        }

        public static boolean isDownloadedAndUnzipped(String uuid) {
            return getSp(SP_NAME).getBoolean(KEY_DOWNLOADED_AND_UNZIPPED + "_" + uuid, false);
        }
    }
}
