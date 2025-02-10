package com.aliyun.auikits.aicall.widget;

import android.content.Context;
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
import com.aliyun.auikits.aicall.base.feed.BizParameter;
import com.aliyun.auikits.aicall.base.feed.ContentViewModel;
import com.aliyun.auikits.aicall.model.AudioToneContentModel;
import com.aliyun.auikits.aicall.bean.AudioToneData;
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
import java.util.List;


public class AIChatBotSettingDialog {

    CardListAdapter mCardListAdapter;
    AudioToneContentModel mAudioToneContentModel;
    ContentViewModel mContentViewModel;
    BizParameter mBizParameter;

    public static String currentVoice = "";
    private static String mDefaultTitle;

    public static void show(Context context, List<AudioToneData> audioToneList) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aichat_setting, null, false);
        AIChatBotSettingDialog aiChatSettingDialog = new AIChatBotSettingDialog(context, view, audioToneList);
        view.setTag(aiChatSettingDialog);

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setExpanded(true, DisplayUtil.dip2px(420))
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnDismissListener(new OnDismissListener() {
                    @Override
                    public void onDismiss(DialogPlus dialog) {

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
            root.findViewById(R.id.ll_audio_tone_list).getLayoutParams().height = DisplayUtil.dip2px(( 48  + 24));
        }else {
            root.findViewById(R.id.ll_audio_tone_list).getLayoutParams().height = DisplayUtil.dip2px((audioToneList.size() * 48  + 24));
        }

        DefaultCardViewFactory factory = new DefaultCardViewFactory();
        factory.registerCardView(CardTypeDef.AUDIO_TONE_CARD, AudioToneCard.class);
        mCardListAdapter = new CardListAdapter(factory);
        rvAudioToneList.setLayoutManager(new LinearLayoutManager(root.getContext(), RecyclerView.VERTICAL, false));
        rvAudioToneList.setAdapter(mCardListAdapter);

        boolean couldSwitch = audioToneList.size() == 0 ? false:true;
        if(audioToneList.size() == 0) {
            AudioToneData audioTone = new AudioToneData("", mDefaultTitle);
            audioTone.setIconResId(R.drawable.ic_audio_tone_0);
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
