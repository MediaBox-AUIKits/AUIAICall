package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;
import com.orhanobut.dialogplus.DialogPlus;

public class AICallDebugDialog {
    public static void show(Context context, ARTCAICallEngine engine) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aicall_custom_debug_setting, null, false);
        ViewHolder viewHolder = new ViewHolder(view);

        EditText editTextAppServer = view.findViewById(R.id.et_debug_send_custom_message_to_server);
        EditText editTextllmPrompt = view.findViewById(R.id.et_debug_update_llm_prompt);
        EditText editTextCustomCapture = view.findViewById(R.id.et_debug_update_custom_capture);

        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setExpanded(true, DisplayUtil.dip2px(430))
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnClickListener((dialog1, v) -> {
                    if(v.getId() == R.id.debug_send_custom_message_to_server) {
                        engine.sendCustomMessageToServer(editTextAppServer.getText().toString());
                    } else if(v.getId() == R.id.debug_update_llm_prompt) {
                        engine.updateLlmSystemPrompt(editTextllmPrompt.getText().toString());
                    } else if(v.getId() == R.id.debug_send_single_custom_capture) {
                        engine.startVisionCustomCapture(new ARTCAICallEngine.ARTCAICallVisionCustomCaptureRequest(editTextCustomCapture.getText().toString(), false, true, 5, 2, 2, ""));
                    } else if(v.getId() == R.id.debug_send_continus_custom_capture) {
                        engine.startVisionCustomCapture(new ARTCAICallEngine.ARTCAICallVisionCustomCaptureRequest(editTextCustomCapture.getText().toString(), false, false, 5, 2, 100, ""));
                    } else if(v.getId() == R.id.debug_stop_custom_capture) {
                        engine.stopVisionCustomCapture();
                    } else if(v.getId() == R.id.debug_send_continus_custom_capture_enable_asr) {
                        engine.startVisionCustomCapture(new ARTCAICallEngine.ARTCAICallVisionCustomCaptureRequest(editTextCustomCapture.getText().toString(), true, false, 5, 2, 100, ""));
                    }
                    dialog1.dismiss();
                })
                .create();
        dialog.show();

    }
}
