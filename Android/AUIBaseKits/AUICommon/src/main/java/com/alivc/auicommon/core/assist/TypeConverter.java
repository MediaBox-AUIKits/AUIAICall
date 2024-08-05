package com.alivc.auicommon.core.assist;

import java.lang.reflect.Method;

/**
 * @author puke
 * @version 2021/11/30
 */
public class TypeConverter {

    public static Object convert(String value, Class<?> targetType) throws Throwable {
        if (targetType == String.class) {
            return value;
        } else if (targetType == boolean.class || targetType == Boolean.class) {
            return Boolean.parseBoolean(value);
        } else if (targetType == int.class || targetType == Integer.class) {
            return Integer.parseInt(value);
        } else if (targetType == double.class || targetType == Double.class) {
            return Double.parseDouble(value);
        } else if (targetType == long.class || targetType == Long.class) {
            return Long.parseLong(value);
        } else if (Enum.class.isAssignableFrom(targetType)) {
            Method valueOfMethod = targetType.getMethod("valueOf", String.class);
            return valueOfMethod.invoke(null, value);
        } else {
            throw new RuntimeException(String.format(
                    "The target type [%s] is not supported", targetType.getName()));
        }
    }
}
