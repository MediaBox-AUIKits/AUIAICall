package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Switch;
import android.widget.TextView;

import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;

public class AIAgentSettingDialog {
    TextView mNoEmotional = null;
    TextView mEmotional = null;
    public static void show(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_auiconfig_setting, null, false);

        AIAgentSettingDialog aiAgentSettingDialog = new AIAgentSettingDialog(view);
        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setExpanded(true, DisplayUtil.dip2px(180))
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnClickListener((dialog1, v) -> {
                    aiAgentSettingDialog.onClick(v);
                })
                .setOnDismissListener(new OnDismissListener() {
                    @Override
                    public void onDismiss(DialogPlus dialog) {

                    }
                })
                .create();
        dialog.show();

    }

    private AIAgentSettingDialog(View root) {
        mNoEmotional = root.findViewById(R.id.tv_mode_not_emotional);
        mEmotional = root.findViewById(R.id.tv_mode_yes_emotional);
        boolean defaultEmotion = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_EMOTION, SettingStorage.DEFAULT_BOOT_ENABLE_EMOTION);
        mNoEmotional.setSelected(!defaultEmotion);
        mEmotional.setSelected(defaultEmotion);
    }

    private void onClick(View v) {

        if(v.getId() == R.id.tv_mode_not_emotional) {
            mEmotional.setSelected(false);
            mNoEmotional.setSelected(true);

        }
        else if(v.getId() == R.id.tv_mode_yes_emotional) {
            mEmotional.setSelected(true);
            mNoEmotional.setSelected(false);
        }

        if(mEmotional.isSelected() && !mNoEmotional.isSelected())
        {
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_EMOTION, true);
        }
        else if(!mEmotional.isSelected() && mNoEmotional.isSelected())
        {
            SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_EMOTION, false);
        }
    }
}
