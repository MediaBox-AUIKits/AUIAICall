package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.card.CardListAdapter;
import com.aliyun.auikits.aicall.base.card.DefaultCardViewFactory;
import com.aliyun.auikits.aicall.base.feed.BizParameter;
import com.aliyun.auikits.aicall.base.feed.ContentViewModel;
import com.aliyun.auikits.aicall.model.AudioToneContentModel;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.util.AUIAICallClipboardUtils;
import com.aliyun.auikits.aicall.util.BizStatHelper;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.card.AudioToneCard;
import com.aliyun.auikits.aicall.widget.card.CardTypeDef;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemChildClickListener;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;
import com.scwang.smart.refresh.layout.SmartRefreshLayout;

import org.json.JSONObject;
import java.util.List;


public class AIChatBotSettingDialog {

    CardListAdapter mCardListAdapter;
    AudioToneContentModel mAudioToneContentModel;
    ContentViewModel mContentViewModel;
    BizParameter mBizParameter;

    public static String currentVoice = "";
    private static String mDefaultTitle;
    private static boolean isShouleShowReportingDialog = false;

    public static void show(Context context, ARTCAIChatEngine chatEngine, String currentRequestId, String agentId,
                            String userId, String sessionId, List<AudioToneData> audioToneList) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aichat_setting, null, false);
        AIChatBotSettingDialog aiChatSettingDialog = new AIChatBotSettingDialog(context, view, audioToneList);
        view.setTag(aiChatSettingDialog);

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setExpanded(true, DisplayUtil.dip2px(420))
                .setOverlayBackgroundResource(R.color.color_bg_mask_transparent_70)
                .setContentBackgroundResource(R.drawable.bg_rounded_setting_dialog)
                .setOnClickListener((dialog1, v) -> {
                    if(v.getId() == R.id.iv_close_setting) {
                        dialog1.dismiss();
                        return;
                    } else if(v.getId() == R.id.iv_reporting_issue) {
                        isShouleShowReportingDialog = true;
                        dialog1.dismiss();
                        return;
                    }
                    aiChatSettingDialog.onClick(v);
                })
                .setOnDismissListener(new OnDismissListener() {
                    @Override
                    public void onDismiss(DialogPlus dialog) {
                        if(isShouleShowReportingDialog) {
                            isShouleShowReportingDialog = false;

                            AICallReportingDialog.showDialog(context, new AICallReportingDialog.IReportingDialogDismissListener() {
                                @Override
                                public void onReportingSubmit(List<Integer> reportTypeStatIdList, String reportIssueDesc) {
                                    // commitReporting
                                    if (null == reportTypeStatIdList || reportTypeStatIdList.isEmpty()) {
                                        return;
                                    }
                                    try {
                                        {
                                            JSONObject args = new JSONObject();
                                            args.put("req_id", currentRequestId);
                                            args.put("aid", agentId);
                                            args.put("uid", userId);
                                            args.put("atype", "MessageChat");
                                            args.put("sid", sessionId);
                                            String round = chatEngine.currentChatRound();
                                            if(!TextUtils.isEmpty(round)) {
                                                args.put("round_type", round);
                                            }
                                            args.put("round_req_id", currentRequestId);

                                            StringBuilder idBuilder = new StringBuilder();
                                            for (int reportTypeId : reportTypeStatIdList) {
                                                if (idBuilder.length() > 0) {
                                                    idBuilder.append(",");
                                                }
                                                idBuilder.append(reportTypeId);
                                            }
                                            args.put("rep_type", idBuilder.toString());
                                            if (!reportIssueDesc.isEmpty()) {
                                                args.put("rep_desc", reportIssueDesc);
                                            }
                                            BizStatHelper.stat("2001", args.toString());
                                        }
                                        {
                                            JSONObject args = new JSONObject();

                                            String allLog = Logger.getAllLogRecordStr();
                                            args.put("log_str", allLog);
                                            BizStatHelper.stat("2002", args.toString());
                                        }
                                    } catch (Exception ex) {
                                        ex.printStackTrace();
                                    }
                                }

                                @Override
                                public void onDismiss(boolean hasSubmit) {
                                    if (hasSubmit) {
                                        String requestId = agentId;
                                        String content = context.getResources().getString(R.string.reporting_id_display, requestId);
                                        AICallNoticeDialog.showFunctionalDialog(context,
                                                null, false, content, true,
                                                R.string.copy, new AICallNoticeDialog.IActionHandle() {
                                                    @Override
                                                    public void handleAction() {
                                                        AUIAICallClipboardUtils.copyToClipboard(context, requestId);
                                                        ToastHelper.showToast(context, R.string.chat_bot_copy_text_tips, Toast.LENGTH_SHORT);
                                                    }
                                                }
                                        );
                                    }
                                }
                            });
                        }
                    }
                })
                .create();
        dialog.show();
    }

    private AIChatBotSettingDialog(Context context, View root, List<AudioToneData> audioToneList) {

        SmartRefreshLayout srlAudioToneList = root.findViewById(R.id.srl_audio_tone_list);
        srlAudioToneList.setEnableLoadMore(false);
        srlAudioToneList.setEnableRefresh(false);
        RecyclerView  rvAudioToneList = root.findViewById(R.id.rv_audio_tone_list);

        mDefaultTitle = context.getString(R.string.chat_bot_default_voice);

        TextView audioToneDetail = root.findViewById(R.id.tv_config_audio_tone_tips);
        audioToneDetail.setText(R.string.chat_bot_audio_tone_detail);
        if(audioToneList.size() == 0) {
            root.findViewById(R.id.ll_audio_tone_list).getLayoutParams().height = DisplayUtil.dip2px(( 56  + 24));
        }else {
            root.findViewById(R.id.ll_audio_tone_list).getLayoutParams().height = DisplayUtil.dip2px((audioToneList.size() * 56  + 24));
        }

        DefaultCardViewFactory factory = new DefaultCardViewFactory();
        factory.registerCardView(CardTypeDef.AUDIO_TONE_CARD, AudioToneCard.class);
        mCardListAdapter = new CardListAdapter(factory);
        rvAudioToneList.setLayoutManager(new LinearLayoutManager(root.getContext(), RecyclerView.VERTICAL, false));
        rvAudioToneList.setAdapter(mCardListAdapter);

        boolean couldSwitch = audioToneList.size() == 0 ? false:true;
        if(audioToneList.size() == 0) {
            AudioToneData audioTone = new AudioToneData("", mDefaultTitle);
            audioTone.setIconResId(R.drawable.ic_audio_tone_3);
            audioTone.setUsing(true);
            audioToneList.add(audioTone);
        }

        mAudioToneContentModel = new AudioToneContentModel(audioToneList);
        mContentViewModel = new ContentViewModel.Builder()
                .setContentModel(mAudioToneContentModel)
                .setBizParameter(mBizParameter)
                .setLoadMoreEnable(false)
                .build();

        if(couldSwitch) {
            mCardListAdapter.addChildClickViewIds(R.id.tv_audio_tone_selector);
            mCardListAdapter.setOnItemChildClickListener(new OnItemChildClickListener() {
                @Override
                public void onItemChildClick(BaseQuickAdapter adapter, View view, int position) {

                    CardEntity newCardEntity = (CardEntity) adapter.getItem(position);
                    AudioToneData newAudioToneData = (AudioToneData) newCardEntity.bizData;
                    if (!newAudioToneData.isUsing()) {
                        currentVoice = newAudioToneData.getAudioToneId();
                        for (int i = 0; i < adapter.getItemCount(); i++) {
                            CardEntity cardEntity = (CardEntity) adapter.getItem(i);
                            AudioToneData audioToneData = (AudioToneData) cardEntity.bizData;
                            if (audioToneData.isUsing()) {
                                audioToneData.setUsing(false);
                                mAudioToneContentModel.updateContent(cardEntity, i);
                            }
                        }

                        newAudioToneData.setUsing(true);
                        mAudioToneContentModel.updateContent(newCardEntity, position);
                    }
                }
            });
        }

        mContentViewModel.bindView(mCardListAdapter);
    }

    private void onClick(View v) {

    }
}
