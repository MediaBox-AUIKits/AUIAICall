package com.alivc.auicommon.core.assist;

import android.content.Context;

import java.lang.reflect.Method;

/**
 * @author puke
 * @version 2021/11/30
 */
public interface ConfigService {

    /**
     * Read config value
     *
     * @param configType api type
     * @param method     called method
     * @param args       parameters of called method
     * @return config value
     */
    Object readConfigValue(Class<?> configType, Method method, Object[] args) throws Throwable;

    /**
     * Open config page
     *
     * @param context Context
     */
    void openConfigPage(Context context);

    /**
     * Set open config page when shake device
     *
     * @param enable true: allow; false: disallow; (default value is true)
     */
    void allowOpenConfigWhenShake(boolean enable);
}
