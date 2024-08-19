package com.aliyun.auikits.aicall;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.SystemClock;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.Toast;

import com.alibaba.android.arouter.facade.annotation.Route;
import com.aliyun.auikits.aicall.util.PermissionUtils;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;
import com.permissionx.guolindev.PermissionX;

@Route(path = "/aicall/AUIAICallEntranceActivity")
public class AUIAICallEntranceActivity extends AppCompatActivity {

    private long mLastSettingTapMillis = 0;
    private long mLastSettingTapCount = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        SettingStorage.getInstance().init(this);

        setContentView(R.layout.activity_auiaicall);
        findViewById(R.id.btn_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        findViewById(R.id.btn_create_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                jumpToInCallActivity();
            }
        });
        findViewById(R.id.btn_more).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showRobotIdDialog();
            }
        });

        PermissionX.init(this)
                .permissions(PermissionUtils.getPermissions())
                .request((allGranted, grantedList, deniedList) -> {
                    if(!allGranted) {
                        ToastHelper.showToast(AUIAICallEntranceActivity.this, R.string.permission_tips, Toast.LENGTH_SHORT);
                        finish();
                    } else {
                        onAllPermissionGranted();
                    }
                });

    }

    private void jumpToInCallActivity() {
        Intent intent = new Intent(this, AUIAICallInCallActivity.class);
        startActivity(intent);
    }

    private void onAllPermissionGranted() {

    }

    private void showRobotIdDialog() {
        View view = LayoutInflater.from(this).inflate(R.layout.dialog_aicall_entrance_setting, null, false);

        boolean showExtraDebugConfig = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHOW_EXTRA_DEBUG_CONFIG);

        ((EditText)view.findViewById(R.id.et_robot_id)).setText(SettingStorage.getInstance().get(SettingStorage.KEY_ROBOT_ID));
        ((Switch)view.findViewById(R.id.sv_audio_dump_tip)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH));
        ((Switch)view.findViewById(R.id.sv_server_type)).setChecked(SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE));

        if (!showExtraDebugConfig) {
            view.findViewById(R.id.ll_audio_dump).setVisibility(View.GONE);
            view.findViewById(R.id.ll_server_type).setVisibility(View.GONE);
        }

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(this)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.CENTER)
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnClickListener((dialog1, v) -> {
                    if (v.getId() == R.id.btn_confirm) {
                        String robotId = ((EditText)findViewById(R.id.et_robot_id)).getText().toString();
                        SettingStorage.getInstance().set(SettingStorage.KEY_ROBOT_ID, robotId);

                        boolean isAudioDumpEnable = ((Switch)view.findViewById(R.id.sv_audio_dump_tip)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH, isAudioDumpEnable);

                        boolean usePreAppServer = ((Switch)view.findViewById(R.id.sv_server_type)).isChecked();
                        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_APP_SERVER_TYPE, usePreAppServer);
                    }
                    if (v.getId() == R.id.btn_confirm || v.getId() == R.id.btn_cancel) {
                        dialog1.dismiss();
                    }
                    if (v.getId() == R.id.tv_dialog_title) {
                        onSettingDialogTitleClicked();
                    }
                })
                .setOnDismissListener(new OnDismissListener() {
                    @Override
                    public void onDismiss(DialogPlus dialog) {

                    }
                })
                .create();
        dialog.show();
    }

    private void onSettingDialogTitleClicked() {
        long now = SystemClock.elapsedRealtime();
        if (now - mLastSettingTapMillis > 500 || mLastSettingTapMillis == 0) {
            mLastSettingTapCount = 1;
        } else {
            mLastSettingTapCount++;
        }
        mLastSettingTapMillis = now;

        if (mLastSettingTapCount >= 3) {
            mLastSettingTapCount = 0;
            mLastSettingTapMillis = 0;
            boolean showExtraConfig = !SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHOW_EXTRA_DEBUG_CONFIG);

            if (showExtraConfig) {
                ToastHelper.showToast(this, R.string.debug_mode_enable, Toast.LENGTH_SHORT);
            } else {
                ToastHelper.showToast(this, R.string.debug_mode_disable, Toast.LENGTH_SHORT);
            }
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_SHOW_EXTRA_DEBUG_CONFIG, showExtraConfig);
            if (!showExtraConfig) {
                onExtraDebugConfigDisable();
            }
        }
    }

    private void onExtraDebugConfigDisable() {
        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_AUDIO_DUMP_SWITCH, false);
        SettingStorage.getInstance().setBoolean(SettingStorage.KEY_APP_SERVER_TYPE, false);
    }
}