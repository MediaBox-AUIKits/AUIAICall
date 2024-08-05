package com.alivc.auicommon.core.utils;

import android.graphics.Color;
import android.text.TextUtils;

import androidx.annotation.Nullable;

import java.util.Random;

/**
 * @author puke
 * @version 2021/5/21
 */
public class ColorUtil {

    private static final Random random = new Random();

    public static int randomColor(long seed) {
        Random random = new Random();
        random.setSeed(seed);
        return Color.rgb(
                random.nextInt(255),
                random.nextInt(255),
                random.nextInt(255)
        );
    }

    public static int randomColor() {
        return Color.rgb(
                random.nextInt(255),
                random.nextInt(255),
                random.nextInt(255)
        );
    }

    @Nullable
    public static Integer parseColor(String colorStr) {
        if (TextUtils.isEmpty(colorStr)) {
            return null;
        }
        try {
            return Color.parseColor(colorStr);
        } catch (Throwable ignore) {
            return null;
        }
    }
}
