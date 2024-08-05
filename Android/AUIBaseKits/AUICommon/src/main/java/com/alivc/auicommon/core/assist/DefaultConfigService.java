package com.alivc.auicommon.core.assist;

import android.content.Context;
import android.util.Log;

import java.lang.reflect.Method;

/**
 * @author puke
 * @version 2021/11/30
 */
public class DefaultConfigService implements ConfigService {

    private static final String TAG = DefaultConfigService.class.getSimpleName();

    @Override
    public Object readConfigValue(Class<?> configType, Method method, Object[] args) throws Throwable {
        Property property = method.getAnnotation(Property.class);
        if (property == null) {
            throw new RuntimeException(String.format(
                    "No %s annotation found at %s#%s",
                    Property.class.getSimpleName(), configType.getName(), method.getName()
            ));
        }

        String defaultValue = property.defaultValue();
        return TypeConverter.convert(defaultValue, method.getReturnType());
    }

    @Override
    public void openConfigPage(Context context) {
        Log.e(TAG, "You can't open config page by default config service.");
    }

    @Override
    public void allowOpenConfigWhenShake(boolean enable) {
        Log.e(TAG, "You can't call allowOpenConfigWhenShake by default config service.");
    }
}
