package com.aliyun.auikits.aicall.widget;
import android.content.Context;
import android.text.Layout;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.card.CardListAdapter;
import com.aliyun.auikits.aicall.base.card.DefaultCardViewFactory;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.model.AudioToneContentModel;
import com.aliyun.auikits.aicall.base.feed.ContentViewModel;
import com.aliyun.auikits.aicall.base.feed.BizParameter;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.aliyun.auikits.aicall.widget.card.AudioToneCard;
import com.aliyun.auikits.aicall.widget.card.CardTypeDef;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemChildClickListener;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;
import com.scwang.smart.refresh.layout.SmartRefreshLayout;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AICallPSTNSettingDialog {

    CardListAdapter mCardListAdapter;
    AudioToneContentModel mAudioToneContentModel;
    ContentViewModel mContentViewModel;
    BizParameter mBizParameter;

    public static String currentVoice = "";
    public static String currentAudioToneId = "";

    private static String mDefaultTitle;

    public interface AICallPSTNVoiceChangeListener {
        void onVoiceChange(String voice) ;
    }

    public static List<AudioToneData> getDefaultAudioToneList(Context context) {
        Map<String, String> audioToneList = new HashMap<String, String>() {{
            put("", context.getString(R.string.chat_bot_default_voice));
            put("1185", "云峰");
            put("11", "云穹");
            put("1397", "云薇");
            put("1151", "云玲");
        }};

        List<AudioToneData> mAgentVoiceIdList = new ArrayList<AudioToneData>();

        int index = 0;
        for(Map.Entry<String, String> entry : audioToneList.entrySet()) {
            String voiceId = entry.getKey();
            String voiceTitle = entry.getValue();
            AudioToneData audioTone = new AudioToneData(voiceId, voiceTitle);
            if(index % 2 == 0) {
                audioTone.setIconResId(R.drawable.ic_audio_tone_3);
            } else if(index % 2 == 1) {
                audioTone.setIconResId(R.drawable.ic_audio_tone_4);
            }
            mAgentVoiceIdList.add(audioTone);
            index++;
        }

        if(TextUtils.isEmpty(currentVoice)) {
            currentVoice = mAgentVoiceIdList.get(0).getTitle();
            mAgentVoiceIdList.get(0).setUsing(true);
        } else {
            for(AudioToneData data : mAgentVoiceIdList) {
                if(data.getTitle().equals(currentVoice)) {
                    data.setUsing(true);
                    break;
                }
            }
        }

        return mAgentVoiceIdList;
    }

    public static void show(Context context, List<AudioToneData> audioToneList, AICallPSTNVoiceChangeListener listener) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aipstn_setting, null, false);
        AICallPSTNSettingDialog aiSettingDialog = new AICallPSTNSettingDialog(context, view, audioToneList, listener);
        view.setTag(aiSettingDialog);

        View audioToneConfig = view.findViewById(R.id.ll_audio_tone_config);
        audioToneConfig.setVisibility(View.GONE);

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setExpanded(true, DisplayUtil.dip2px(340))
                .setOverlayBackgroundResource(R.color.color_bg_mask_transparent_70)
                .setContentBackgroundResource(R.drawable.bg_rounded_setting_dialog)
                .setOnClickListener((dialog1, v) -> {
                    if(v.getId() == R.id.iv_close_setting){
                        dialog1.dismiss();
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

    private AICallPSTNSettingDialog(Context context, View root, List<AudioToneData> audioToneList, AICallPSTNVoiceChangeListener listener) {

        SmartRefreshLayout srlAudioToneList = root.findViewById(R.id.srl_audio_tone_list);
        srlAudioToneList.setEnableLoadMore(false);
        srlAudioToneList.setEnableRefresh(false);
        RecyclerView rvAudioToneList = root.findViewById(R.id.rv_audio_tone_list);
        root.findViewById(R.id.ll_audio_tone_config).setVisibility(View.VISIBLE);
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
                        currentVoice = newAudioToneData.getTitle();
                        currentAudioToneId = newAudioToneData.getAudioToneId();
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
                        currentVoice = newAudioToneData.getTitle();
                        if(listener != null) {
                            listener.onVoiceChange(currentVoice);
                        }
                    }
                }
            });
        }

        mContentViewModel.bindView(mCardListAdapter);
    }
}
