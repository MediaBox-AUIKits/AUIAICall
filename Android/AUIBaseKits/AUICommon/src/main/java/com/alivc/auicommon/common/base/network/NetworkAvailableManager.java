package com.alivc.auicommon.common.base.network;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.alivc.auicommon.common.base.AppContext;
import com.alivc.auicommon.common.base.base.Consumer;
import com.alivc.auicommon.common.base.observable.Observable;

/**
 * 网络状态监听器, SDK中所有状态状态监听, 由该类统一对外分发
 *
 * @author puke
 * @version 2022/6/13
 */
public class NetworkAvailableManager extends Observable<OnNetworkAvailableChangeListener> {

    private static final byte[] sInstanceLock = new byte[0];
    @SuppressLint("StaticFieldLeak")
    private static NetworkAvailableManager sInstance;

    private final Context context;

    private NetworkAvailableManager() {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("android.net.conn.CONNECTIVITY_CHANGE");
        context = AppContext.getContext();
        NetworkChangeReceiver networkChangeReceiver = new NetworkChangeReceiver();
        context.registerReceiver(networkChangeReceiver, intentFilter);
    }

    public static NetworkAvailableManager instance() {
        if (sInstance == null) {
            synchronized (sInstanceLock) {
                if (sInstance == null) {
                    sInstance = new NetworkAvailableManager();
                }
            }
        }
        return sInstance;
    }

    private class NetworkChangeReceiver extends BroadcastReceiver {

        private boolean currentNetworkAvailable = isNetworkAvailable();

        @Override
        public void onReceive(Context context, Intent intent) {
            boolean networkAvailable = isNetworkAvailable();
            if (currentNetworkAvailable ^ networkAvailable) {
                currentNetworkAvailable = networkAvailable;
                dispatch(new Consumer<OnNetworkAvailableChangeListener>() {
                    @Override
                    public void accept(OnNetworkAvailableChangeListener listener) {
                        listener.onNetworkAvailableChanged(currentNetworkAvailable);
                    }
                });
            }
        }

        private boolean isNetworkAvailable() {
            ConnectivityManager connectivityManager = (ConnectivityManager) context
                    .getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
            return networkInfo != null && networkInfo.isAvailable();
        }
    }
}
