package com.alivc.auicommon.common.base.util;

import android.content.Context;
import android.os.Build;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author puke
 * @version 2022/1/18
 */
class DeviceIdUtil {

    private static final List<? extends Module> MODULES = Arrays.asList(
            new ImeiModule(),
            new AndroidIdModule(),
            new SerialModule(),
            new HardwareModule()
    );

    public static String getDeviceId(Context context) {
        List<String> moduleIdsList = new ArrayList<>();
        for (Module module : MODULES) {
            String id;
            try {
                id = module.getId(context);
            } catch (Throwable throwable) {
                id = module.getClass().getName();
            }
            String md5OfModule = getMD5(id);
            moduleIdsList.add(md5OfModule);
        }
        String joinedModuleId = TextUtils.join("", moduleIdsList);
        return getMD5(joinedModuleId);
    }

    private static String getMD5(String str) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(str.getBytes());
            return new BigInteger(1, md.digest()).toString(16);
        } catch (Exception e) {
            throw new RuntimeException("MD5加密出现错误");
        }
    }

    private interface Module {
        String getId(Context context) throws Throwable;
    }

    private static class ImeiModule implements Module {

        @Override
        public String getId(Context context) throws Throwable {
            TelephonyManager telephonyManager =
                    (TelephonyManager) context.getSystemService(TelephonyManager.class.getName());
            return telephonyManager.getDeviceId();
        }
    }

    private static class AndroidIdModule implements Module {

        @Override
        public String getId(Context context) throws Throwable {
            return Settings.System.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        }
    }

    private static class SerialModule implements Module {

        @Override
        public String getId(Context context) throws Throwable {
            return Build.class.getField("SERIAL").get(null).toString();
        }
    }

    private static class HardwareModule implements Module {

        @Override
        public String getId(Context context) throws Throwable {
            return "35"
                    + (Build.BOARD.length() % 10)
                    + (Build.BRAND.length() % 10)
                    + (Build.CPU_ABI.length() % 10)
                    + (Build.DEVICE.length() % 10)
                    + (Build.MANUFACTURER.length() % 10)
                    + (Build.MODEL.length() % 10)
                    + (Build.PRODUCT.length() % 10);
        }
    }
}
