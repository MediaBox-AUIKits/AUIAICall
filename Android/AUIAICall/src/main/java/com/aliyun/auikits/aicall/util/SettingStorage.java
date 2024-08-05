package com.aliyun.auikits.aicall.util;

import static android.content.Context.MODE_PRIVATE;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

public class SettingStorage {
    private static final String FILE_NAME = "AI_CALL_SETTING_STORAGE";
    private static class LAZY_HOLDER {
        private static SettingStorage sInstance = new SettingStorage();
    }

    public static final String KEY_ROBOT_ID = "KEY_ROBOT_ID";
    public static final String KEY_AUDIO_DUMP_SWITCH = "KEY_AUDIO_DUMP_SWITCH";
    public static final String KEY_SHOW_EXTRA_DEBUG_CONFIG = "KEY_SHOW_EXTRA_DEBUG_CONFIG";
    public static final String KEY_APP_SERVER_TYPE = "KEY_APP_SERVER_TYPE";
    private SharedPreferences mSP = null;

    public static SettingStorage getInstance() {
        return LAZY_HOLDER.sInstance;
    }

    public void init(Context context) {
        if (mSP == null) {
            Context applicationContext = context.getApplicationContext();
            mSP = applicationContext.getSharedPreferences(FILE_NAME, MODE_PRIVATE);
        }
        Log.i("SettingStorage", "init: " + mSP);
    }

    public void set(String key, String value) {
        SharedPreferences.Editor editor = mSP.edit();
        editor.putString(key, value);
        editor.apply();
        Log.i("SettingStorage", "set " + key + ": " + value);
    }

    public String get(String key) {
        String value = mSP.getString(key, "");
        Log.i("SettingStorage", "get " + key + ": " + value);
        return value;
    }

    public boolean getBoolean(String key) {
        boolean value = mSP.getBoolean(key, false);
        Log.i("SettingStorage", "getBoolean " + key + ": " + value);
        return value;
    }

    public void setBoolean(String key, boolean value) {
        SharedPreferences.Editor editor = mSP.edit();
        editor.putBoolean(key, value);
        editor.apply();
        Log.i("SettingStorage", "setBoolean " + key + ": " + value);
    }
}
