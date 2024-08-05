package com.aliyun.auikits.aicall.core.base.network;

import android.util.Log;

import androidx.annotation.NonNull;

import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;

public class DefaultOkHttpFactory {
    private static final int READ_TIME_OUT = 15;
    private static final int WRITE_TIME_OUT = 15;
    private static final int CONNECT_TIME_OUT = 15;
    private static OkHttpClient okHttpClient = null;
    public static OkHttpClient getHttpClient() {
        if(okHttpClient == null) {
            HttpLoggingInterceptor logging = new HttpLoggingInterceptor(new HttpLoggingInterceptor.Logger() {
                @Override
                public void log(@NonNull String s) {
                    Log.v("OkHttpNetwork", s);
                }
            });
//            if(BuildConfig.DEBUG) {
//                logging.setLevel(HttpLoggingInterceptor.Level.BODY);
//            } else {
//                logging.setLevel(HttpLoggingInterceptor.Level.BASIC);
//            }
            logging.setLevel(HttpLoggingInterceptor.Level.BODY);

            OkHttpClient.Builder builder = new OkHttpClient.Builder()
                    .connectTimeout(CONNECT_TIME_OUT, TimeUnit.SECONDS)
                    .readTimeout(READ_TIME_OUT, TimeUnit.SECONDS)
                    .writeTimeout(WRITE_TIME_OUT, TimeUnit.SECONDS)
                    .addInterceptor(logging)
                    .retryOnConnectionFailure(true);
            okHttpClient = builder.build();
        }

        return okHttpClient;
    }
}
