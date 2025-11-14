package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.aliyun.auikits.aicall.AUIAICallEntranceActivity;
import com.aliyun.auikits.aicall.AUIAICallVoicePrintRecordActivity;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;

public class AIAgentSettingDialog {
    TextView mNoEmotional = null;
    TextView mEmotional = null;
    TextView mVoicePrintTitle = null;
    TextView mVoicePrintDesc = null;
    LinearLayout mVoicePrintStatus = null;
    Switch mVoicePrintSwitch = null;
    static DialogPlus mDialog = null;

    // 为了重用类似 AICallReportingDialog 的样式
    public interface IAIVoicePrintRecordListener {
        void onClick();
    }
    public static void show(Context context, IAIVoicePrintRecordListener listener) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_auiconfig_setting, null, false);

        AIAgentSettingDialog aiAgentSettingDialog = new AIAgentSettingDialog(view);
        ViewHolder viewHolder = new ViewHolder(view);
        mDialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setExpanded(true, DisplayUtil.dip2px(330))
                .setOverlayBackgroundResource(R.color.color_bg_mask_transparent_70)
                .setContentBackgroundResource(R.drawable.bg_rounded_setting_dialog)
                .setOnClickListener((dialog1, v) -> {
                    if(v.getId() == R.id.iv_record_voice_select) {
                        if(listener != null) {
                            listener.onClick();
                        }
                    } else if(v.getId() == R.id.iv_close_setting){
                        dialog1.dismiss();
                    }else {
                        aiAgentSettingDialog.onClick(v);
                    }
                })
                .setOnDismissListener(new OnDismissListener() {
                    @Override
                    public void onDismiss(DialogPlus dialog) {

                    }
                })
                .create();
        mDialog.show();

    }

    public static void updateDialogContent() {
        if(mDialog != null && mDialog.isShowing()) {

            View dialogView = mDialog.getHolderView();
            if(dialogView != null) {
                boolean voicePrintId = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_VOICE_PRINT_RECORD_ALRAEDY, false);

                TextView voicePrintTitle = dialogView.findViewById(R.id.tv_voiceprint_record_status);
                TextView voicePrintDesc = dialogView.findViewById(R.id.btn_record_voiceprint);

                if(voicePrintTitle != null && voicePrintDesc != null) {
                    if(voicePrintId) {
                        voicePrintTitle.setText(R.string.voiceprint_info_title);
                        voicePrintDesc.setText(R.string.voiceprint_rerecord);

                    } else {
                        voicePrintTitle.setText(R.string.voiceprint_info_tipe_cannot_use);
                        voicePrintDesc.setText(R.string.voiceprint_info_record);
                    }
                }
            }
        }


    }

    private AIAgentSettingDialog(View root) {
        mNoEmotional = root.findViewById(R.id.tv_mode_not_emotional);
        mEmotional = root.findViewById(R.id.tv_mode_yes_emotional);
        mVoicePrintTitle = root.findViewById(R.id.tv_voiceprint_record_status);
        mVoicePrintDesc = root.findViewById(R.id.btn_record_voiceprint);
        mVoicePrintStatus = root.findViewById(R.id.ll_voiceprint_status);
        mVoicePrintSwitch = root.findViewById(R.id.sv_voiceprint_switch);
        boolean defaultEmotion = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_EMOTION, SettingStorage.DEFAULT_BOOT_ENABLE_EMOTION);
        mNoEmotional.setSelected(!defaultEmotion);
        mEmotional.setSelected(defaultEmotion);

        boolean openVoicePrint = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_BOOT_ENABLE_VOICE_PRINT, SettingStorage.DEFAULT_ENABLE_VOICE_PRINT);
        if(openVoicePrint) {
            mVoicePrintSwitch.setChecked(true);
            mVoicePrintStatus.setVisibility(View.VISIBLE);
        } else {
            mVoicePrintSwitch.setChecked(false);
            mVoicePrintStatus.setVisibility(View.GONE);
        }

        boolean voicePrintId = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_VOICE_PRINT_RECORD_ALRAEDY, false);
        if(voicePrintId) {
            mVoicePrintTitle.setText(R.string.voiceprint_info_title);
            mVoicePrintDesc.setText(R.string.voiceprint_rerecord);

        } else {
            mVoicePrintTitle.setText(R.string.voiceprint_info_tipe_cannot_use);
            mVoicePrintDesc.setText(R.string.voiceprint_info_record);
        }
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
        else if(v.getId() == R.id.sv_voiceprint_switch) {
            if(mVoicePrintSwitch.isChecked()) {
                SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_VOICE_PRINT, true);
                mVoicePrintStatus.setVisibility(View.VISIBLE);
            }
            else {
                SettingStorage.getInstance().setBoolean(SettingStorage.KEY_BOOT_ENABLE_VOICE_PRINT, false);
                mVoicePrintStatus.setVisibility(View.GONE);
            }
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
