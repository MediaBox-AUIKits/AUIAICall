package com.alivc.auimessage;

import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auimessage.annotation.IgnoreMapping;
import com.alivc.auimessage.annotation.MessageType;
import com.alivc.auimessage.listener.MessageListener;

import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.Map;

/**
 * 消息-类型 映射
 *
 * @author puke
 * @version 2022/8/31
 */
public class AUIMessageTypeMapping {

    private static final String TAG = "MessageTypeMapping";
    private static final Map<Integer, CallbackInfo> TYPE_2_CALLBACK_INFO = new HashMap<>();
    private static final Map<Class<?>, Integer> MODEL_CLASS_2_TYPE = new HashMap<>();

    static {
        for (Method method : MessageListener.class.getDeclaredMethods()) {
            // 忽略映射
            if (method.getAnnotation(IgnoreMapping.class) != null) {
                Logger.i(TAG, String.format("忽略映射: %s", method.getName()));
                continue;
            }

            // 获取回调方法中AUIMessage参数的泛型T的类型
            Type parameterType = method.getGenericParameterTypes()[0];
            Class<?> actualType = (Class<?>) ((ParameterizedType) parameterType).getActualTypeArguments()[0];

            // 组装回调信息
            CallbackInfo callbackInfo = new CallbackInfo(actualType, method);

            // 获取消息实体的注解信息
            MessageType messageType = actualType.getAnnotation(MessageType.class);
            if (messageType == null) {
                // 该错误类型, 运行期尽早抛出
                throw new RuntimeException(String.format("类 %s 未添加 %s 注解",
                        actualType.getName(), MessageType.class.getName()));
            }

            // 缓存
            int type = messageType.value();
            TYPE_2_CALLBACK_INFO.put(type, callbackInfo);
            MODEL_CLASS_2_TYPE.put(actualType, type);
            Logger.i(TAG, String.format(
                    "MessageTypeMapping, type=%s, method=%s, class=%s",
                    type, method.getName(), actualType.getName()
            ));
        }
    }

    static CallbackInfo getCallbackInfoFromType(int type) {
        return TYPE_2_CALLBACK_INFO.get(type);
    }

    public static Integer getTypeFromModelClass(Class<?> modelClass) {
        return MODEL_CLASS_2_TYPE.get(modelClass);
    }

    static class CallbackInfo {
        final Class<?> modelClass;
        final Method callbackMethod;

        CallbackInfo(Class<?> modelClass, Method callbackMethod) {
            this.modelClass = modelClass;
            this.callbackMethod = callbackMethod;
        }
    }
}
