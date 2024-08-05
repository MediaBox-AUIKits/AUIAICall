package com.alivc.auicommon.core.assist;

import android.content.Context;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

/**
 * @author puke
 * @version 2021/8/30
 */
public class Assist {

    private static final Map<Class<?>, Object> configInstances = new HashMap<>();

    private static ConfigService configService;

    /**
     * Open config page
     *
     * @param context Context
     */
    public static void openConfigPage(Context context) {
        getConfigService().openConfigPage(context);
    }

    /**
     * Set open config page when shake device
     *
     * @param enable true: allow; false: disallow; (default value is true)
     */
    public static void allowOpenConfigWhenShake(boolean enable) {
        getConfigService().allowOpenConfigWhenShake(enable);
    }

    /**
     * Get config service instance
     *
     * @param configType Java interface of config type
     * @param <T>        config type
     * @return config service instance
     */
    @SuppressWarnings("unchecked")
    public static <T> T getConfig(final Class<T> configType) {
        Object instance = configInstances.get(configType);
        if (instance != null) {
            return (T) instance;
        }

        ClassLoader classLoader = configType.getClassLoader();
        T configInstance = (T) Proxy.newProxyInstance(classLoader, new Class[]{configType},
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        try {
                            return getConfigService().readConfigValue(configType, method, args);
                        } catch (Exception e) {
                            String message = String.format(
                                    "Invoke error at %s#%s", configType.getName(), method.getName());
                            throw new RuntimeException(message, e);
                        }
                    }
                }
        );
        configInstances.put(configType, configInstance);
        return configInstance;
    }

    private static ConfigService getConfigService() {
        if (configService == null) {
            configService = new DefaultConfigService();
        }
        return configService;
    }

    public static void setConfigService(ConfigService configService) {
        if (Assist.configService != null) {
            // Allow set only one time
            throw new RuntimeException("ConfigService already set.");
        }
        Assist.configService = configService;
    }
}
