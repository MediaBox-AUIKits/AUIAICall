package com.aliyun.auikits.aicall.demo;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.widget.ListAdapter;
import android.widget.ListView;
import androidx.appcompat.app.AppCompatActivity;

import com.aliyun.auikits.aicall.demo.utils.PermissionUtils;

public abstract class BaseDebugActivity extends AppCompatActivity {
    private DebugInfoListAdapter mDebugInfoAdapter;

    private ListView mDebugInfoListView;
    private int mLine = 1;

    protected Handler mUIHandler = new Handler(Looper.getMainLooper());

    private Runnable mScrollToEndTask = new Runnable() {
        @Override
        public final void run() {
            mDebugInfoListView.smoothScrollToPosition(mDebugInfoAdapter == null ? 0 : mDebugInfoAdapter.getCount());
        }
    };

    public abstract int getLayoutResId();

    protected abstract String getTag();

    @Override
    public void onCreate( Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getLayoutResId());
        this.mDebugInfoListView = (ListView) findViewById(R.id.debug_info_list);
        DebugInfoListAdapter debugInfoListAdapter = new DebugInfoListAdapter(getApplicationContext());
        this.mDebugInfoAdapter = debugInfoListAdapter;
        ListView listView = this.mDebugInfoListView;
        if (listView != null) {
            listView.setAdapter((ListAdapter) debugInfoListAdapter);
        }
        if (!PermissionUtils.checkPermissionsGroup(getApplicationContext(), PermissionUtils.getPermissions())) {
            PermissionUtils.requestPermissions(this, PermissionUtils.getPermissions(), 1000);
        } else if (BuildConfig.DEBUG) {
            showDebugLayout();
        } else {
            hideDebugLayout();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,  String[] permissions,  int[] grantResults) {
        if (requestCode == 1000) {
            if (!PermissionUtils.checkPermissionsGroup(getApplicationContext(), PermissionUtils.getPermissions())) {
                throw new RuntimeException("permission denied!!! please try again!!!");
            }
            return;
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    public final void addDebugInfo( final String info) {
        Log.d(getTag(), info);
        runOnUiThread(new Runnable() {
            @Override
            public final void run() {
                StringBuilder sb = new StringBuilder();
                mDebugInfoAdapter.addInfo(sb.append(mLine).append(": ").append(info).toString());
                mLine++;
            }
        });
        this.mUIHandler.removeCallbacks(this.mScrollToEndTask);
        this.mUIHandler.postDelayed(this.mScrollToEndTask, 100L);
    }

    private final void hideDebugLayout() {
        ListView listView = this.mDebugInfoListView;
        if (listView == null) {
            return;
        }
        listView.setVisibility(View.GONE);
    }

    private final void showDebugLayout() {
        ListView listView = this.mDebugInfoListView;
        if (listView == null) {
            return;
        }
        listView.setVisibility(View.VISIBLE);
    }
}