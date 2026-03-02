package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.orhanobut.dialogplus.ViewHolder;
import com.orhanobut.dialogplus.DialogPlus;

import org.json.JSONException;
import org.json.JSONObject;

public class AICallDebugDialog {
    public static void show(Context context, ARTCAICallEngine engine) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aicall_custom_debug_setting, null, false);
        ViewHolder viewHolder = new ViewHolder(view);

        EditText editTextAppServer = view.findViewById(R.id.et_debug_send_custom_message_to_server);
        EditText editTextllmPrompt = view.findViewById(R.id.et_debug_update_llm_prompt);
        EditText editTextCustomCapture = view.findViewById(R.id.et_debug_update_custom_capture);
        EditText editTextVcrConfig = view.findViewById(R.id.et_debug_vcr_update);
        EditText editTextBailianParams = view.findViewById(R.id.et_debug_bailian_params_update);
        EditText editTTSSpeed = view.findViewById(R.id.et_debug_tts_speed);
        EditText editAsrMaxSilence = view.findViewById(R.id.et_debug_asr_max_silence);

        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setExpanded(true, DisplayUtil.dip2px(600))
                .setOverlayBackgroundResource(R.color.color_bg_mask_transparent_70)
                .setContentBackgroundResource(android.R.color.transparent)
                .setOnClickListener((dialog1, v) -> {
                    if(v.getId() == R.id.iv_close_debug_setting) {
                        dialog1.dismiss();
                        return;
                    }
                    
                    if(v.getId() == R.id.debug_send_custom_message_to_server) {
                        String message = editTextAppServer.getText().toString();
                        if(!TextUtils.isEmpty(message)) {
                            engine.sendCustomMessageToServer(message);
                        }
                    } else if(v.getId() == R.id.debug_update_llm_prompt) {
                        String prompt = editTextllmPrompt.getText().toString();
                        if(!TextUtils.isEmpty(prompt)) {
                            engine.updateLlmSystemPrompt(prompt);
                        }
                    } else if(v.getId() == R.id.debug_send_single_custom_capture) {
                        String text = editTextCustomCapture.getText().toString();
                        engine.startVisionCustomCapture(new ARTCAICallEngine.ARTCAICallVisionCustomCaptureRequest(text, false, true, 5, 2, 2, ""));
                    } else if(v.getId() == R.id.debug_send_continus_custom_capture) {
                        String text = editTextCustomCapture.getText().toString();
                        engine.startVisionCustomCapture(new ARTCAICallEngine.ARTCAICallVisionCustomCaptureRequest(text, false, false, 5, 2, 100, ""));
                    } else if(v.getId() == R.id.debug_stop_custom_capture) {
                        engine.stopVisionCustomCapture();
                    } else if(v.getId() == R.id.debug_send_continus_custom_capture_enable_asr) {
                        String text = editTextCustomCapture.getText().toString();
                        engine.startVisionCustomCapture(new ARTCAICallEngine.ARTCAICallVisionCustomCaptureRequest(text, true, false, 5, 2, 100, ""));
                    } else if(v.getId() == R.id.debug_mute_agent_audio) {
                        engine.muteAgentAudioPlaying(true);
                    } else if(v.getId() == R.id.debug_unmute_agent_audio) {
                        engine.muteAgentAudioPlaying(false);
                    } else if(v.getId() == R.id.debug_send_text_to_agent) {
                        engine.sendTextToAgent(new ARTCAICallEngine.ARTCAICallSendTextToAgentRequest("今天天气怎么样"));
                    } else if(v.getId() == R.id.debug_update_vcr_config) {
                        String vcrConfigStr = editTextVcrConfig.getText().toString();
                        if(!TextUtils.isEmpty(vcrConfigStr)) {
                            try {
                                JSONObject jsonObject = new JSONObject(vcrConfigStr);

                                engine.updateVcrConfig(new ARTCAICallEngine.ARTCAICallAgentVcrConfig(jsonObject));
                            }catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                    } else if (v.getId() == R.id.debug_update_update_bailian_params) {
                        String bailianParams = editTextBailianParams.getText().toString();
                        if(!TextUtils.isEmpty(bailianParams)) {
                            engine.updateBailianAppParams(bailianParams);
                        }
                    } else if (v.getId() == R.id.debug_update_tts_speed) {
                        String ttsSpeed = editTTSSpeed.getText().toString();
                        if(!TextUtils.isEmpty(ttsSpeed)) {
                            try {
                                engine.updateTtsSpeechRate(Double.parseDouble(ttsSpeed));
                            } catch (NumberFormatException e) {
                                e.printStackTrace();
                            }
                        }
                    } else if (v.getId() == R.id.debug_update_asr_max_silence) {
                        String asrMaxSilence = editAsrMaxSilence.getText().toString();
                        if(!TextUtils.isEmpty(asrMaxSilence)) {
                            try {
                                engine.updateAsrMaxSilence(Integer.parseInt(asrMaxSilence));
                            } catch (NumberFormatException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                })
                .create();
        dialog.show();

    }
}
