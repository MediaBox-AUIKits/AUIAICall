package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aicall.BuildConfig;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.card.CardListAdapter;
import com.aliyun.auikits.aicall.base.card.DefaultCardViewFactory;
import com.aliyun.auikits.aicall.base.feed.AbsContentModel;
import com.aliyun.auikits.aicall.base.feed.BizParameter;
import com.aliyun.auikits.aicall.base.feed.ContentViewModel;
import com.aliyun.auikits.aicall.base.feed.IBizCallback;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.aliyun.auikits.aicall.widget.card.AudioToneCard;
import com.aliyun.auikits.aicall.widget.card.CardTypeDef;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemChildClickListener;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;
import com.scwang.smart.refresh.layout.SmartRefreshLayout;

import java.util.ArrayList;
import java.util.List;

public class AICallSettingDialog {
    private static final boolean IS_VOICE_PRINT_FUNCTION_SHOWN = BuildConfig.TEST_ENV_MODE;

    CardListAdapter mCardListAdapter;
    AudioToneContentModel mAudioToneContentModel;
    ContentViewModel mContentViewModel;
    BizParameter mBizParameter;
    ARTCAICallEngine mARTCAICallEngine;
    boolean mIsAvatarAgent;
    boolean mIsVoicePrintRecognized;
    TextView mTvNaturalConversion = null;
    TextView mTvPushToTalk = null;
    ViewGroup mVgInterruptConfig = null;
    ViewGroup mVgVoicePrintStatus = null;


    public static void show(Context context, ARTCAICallEngine aRTCAICallEngine, boolean isAvatarAgent, boolean isVoicePrintRecognized) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aicall_setting, null, false);
        AICallSettingDialog aiCallSettingDialog = new AICallSettingDialog(view, aRTCAICallEngine, isAvatarAgent, isVoicePrintRecognized);
        view.setTag(aiCallSettingDialog);

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setExpanded(true, DisplayUtil.dip2px(420))
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnClickListener((dialog1, v) -> {
                    aiCallSettingDialog.onClick(v);
                })
                .setOnDismissListener(new OnDismissListener() {
                    @Override
                    public void onDismiss(DialogPlus dialog) {

                    }
                })
                .create();
        dialog.show();
    }

    private static class AudioToneContentModel extends AbsContentModel<CardEntity> {
        private ARTCAICallEngine mARTCAiCallEngine = null;

        public AudioToneContentModel(ARTCAICallEngine artcaiCallEngine) {
            mARTCAiCallEngine = artcaiCallEngine;
        }

        @Override
        public void initData(BizParameter parameter, IBizCallback<CardEntity> callback) {
            String currentAudioId = mARTCAiCallEngine.getRobotVoiceId();
//            if (currentAudioId.isEmpty()) {
//                currentAudioId = "zhixiaoxia";
//            }

            List<AudioToneData> cardDataList = new ArrayList<>();
            AudioToneData audioToneData1 = new AudioToneData("zhixiaobai", "Zhi Xiao Bai");
            audioToneData1.setIconResId(R.drawable.ic_audio_tone);
            audioToneData1.setUsing(currentAudioId.equals(audioToneData1.getAudioToneId()));
            cardDataList.add(audioToneData1);

            AudioToneData audioToneData2 = new AudioToneData("zhixiaoxia", "Zhi Xiao Xia");
            audioToneData2.setIconResId(R.drawable.ic_audio_tone);
            audioToneData2.setUsing(currentAudioId.equals(audioToneData2.getAudioToneId()));
            cardDataList.add(audioToneData2);

            AudioToneData audioToneData3 = new AudioToneData("abin", "A Bin");
            audioToneData3.setIconResId(R.drawable.ic_audio_tone);
            audioToneData3.setUsing(currentAudioId.equals(audioToneData3.getAudioToneId()));
            cardDataList.add(audioToneData3);

            List<CardEntity> cardEntities = new ArrayList<>();
            for (AudioToneData audioToneData : cardDataList) {
                CardEntity cardEntity = new CardEntity();
                cardEntity.cardType = CardTypeDef.AUDIO_TONE_CARD;
                cardEntity.bizData = audioToneData;
                cardEntities.add(cardEntity);
            }
            callback.onSuccess(cardEntities);
        }

        @Override
        public void updateContent(CardEntity data, int pos) {
            super.updateContent(data, pos);
        }

        @Override
        public void fetchData(boolean isPullToRefresh, BizParameter parameter, IBizCallback<CardEntity> callback) {
        }
    }

    private AICallSettingDialog(View root, ARTCAICallEngine aRTCAICallEngine, boolean isAvatarAgent,
                                boolean isVoicePrintRecognized) {
        mARTCAICallEngine = aRTCAICallEngine;
        mIsAvatarAgent = isAvatarAgent;
        mIsVoicePrintRecognized = isVoicePrintRecognized;

        initInterruptButton(root);
        initVoicePrintButton(root);
        initConversionModeButton(root);

        if (mIsAvatarAgent) {
            root.findViewById(R.id.ll_audio_tone_config).setVisibility(View.GONE);
            root.findViewById(R.id.ll_audio_tone_list).setVisibility(View.GONE);
        } else {
            root.findViewById(R.id.ll_audio_tone_config).setVisibility(View.VISIBLE);
            root.findViewById(R.id.ll_audio_tone_list).setVisibility(View.VISIBLE);

            SmartRefreshLayout srlAudioToneList = root.findViewById(R.id.srl_audio_tone_list);
            srlAudioToneList.setEnableLoadMore(false);
            srlAudioToneList.setEnableRefresh(false);
            RecyclerView rvAudioToneList = root.findViewById(R.id.rv_audio_tone_list);

            DefaultCardViewFactory factory = new DefaultCardViewFactory();
            factory.registerCardView(CardTypeDef.AUDIO_TONE_CARD, AudioToneCard.class);
            mCardListAdapter = new CardListAdapter(factory);
            rvAudioToneList.setLayoutManager(new LinearLayoutManager(root.getContext(), RecyclerView.VERTICAL, false));
            rvAudioToneList.setAdapter(mCardListAdapter);

            mAudioToneContentModel = new AudioToneContentModel(mARTCAICallEngine);
            mContentViewModel = new ContentViewModel.Builder()
                    .setContentModel(mAudioToneContentModel)
                    .setBizParameter(mBizParameter)
                    .setLoadMoreEnable(false)
                    .build();

            mCardListAdapter.addChildClickViewIds(R.id.tv_audio_tone_selector);
            mCardListAdapter.setOnItemChildClickListener(new OnItemChildClickListener() {
                @Override
                public void onItemChildClick(BaseQuickAdapter adapter, View view, int position) {

                    CardEntity newCardEntity = (CardEntity) adapter.getItem(position);
                    AudioToneData newAudioToneData = (AudioToneData) newCardEntity.bizData;
                    if (!newAudioToneData.isUsing()) {
                        boolean ret = mARTCAICallEngine.switchRobotVoice(newAudioToneData.getAudioToneId());

                        if (ret) {
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
                        } else {
                            ToastHelper.showToast(view.getContext(), R.string.tips_notice_before_connected, Toast.LENGTH_SHORT);
                        }
                    }
                }
            });

            mContentViewModel.bindView(mCardListAdapter);
        }
    }

    private void initInterruptButton(View root) {
        mVgInterruptConfig = root.findViewById(R.id.ll_interrupt_config);
        Switch svInterruptConfig = root.findViewById(R.id.sv_interrupt_config);
        svInterruptConfig.setChecked(mARTCAICallEngine.isVoiceInterruptEnable());
        svInterruptConfig.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (!mARTCAICallEngine.enableVoiceInterrupt(isChecked)) {
                    buttonView.setChecked(!isChecked);
                    ToastHelper.showToast(buttonView.getContext(), R.string.tips_notice_before_connected, Toast.LENGTH_SHORT);
                } else {
                    ToastHelper.showToast(buttonView.getContext(),
                            isChecked ? R.string.config_interrupt_title_open_toast : R.string.config_interrupt_title_close_toast,
                            Toast.LENGTH_SHORT);
                }
            }
        });
    }

    private void initVoicePrintButton(View root) {
        if (IS_VOICE_PRINT_FUNCTION_SHOWN) {
            Switch svVoicePrint = root.findViewById(R.id.sv_voiceprint);
            svVoicePrint.setChecked(mARTCAICallEngine.isUsingVoicePrint());
            svVoicePrint.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (!mARTCAICallEngine.useVoicePrint(isChecked)) {
                        buttonView.setChecked(!isChecked);
                        ToastHelper.showToast(buttonView.getContext(), R.string.tips_notice_before_connected, Toast.LENGTH_SHORT);
                    } else {
                        ToastHelper.showToast(buttonView.getContext(),
                                isChecked ? R.string.voiceprint_enable : R.string.voiceprint_disable,
                                Toast.LENGTH_SHORT);
                    }
                }
            });

            mVgVoicePrintStatus = root.findViewById(R.id.ll_voiceprint_status);
            mVgVoicePrintStatus.setVisibility(mIsVoicePrintRecognized ? View.VISIBLE : View.GONE);
        }
        root.findViewById(R.id.ll_voiceprint).setVisibility(IS_VOICE_PRINT_FUNCTION_SHOWN ?
                View.VISIBLE : View.GONE);
    }

    private void initConversionModeButton(View root) {
        mTvNaturalConversion = root.findViewById(R.id.tv_mode_natural_conversation);
        mTvPushToTalk = root.findViewById(R.id.tv_mode_push_to_talk);
        if (mARTCAICallEngine.isPushToTalkEnable()) {
            mTvNaturalConversion.setSelected(false);
            mTvPushToTalk.setSelected(true);

            mVgInterruptConfig.setVisibility(View.GONE);
        } else {
            mTvNaturalConversion.setSelected(true);
            mTvPushToTalk.setSelected(false);

            mVgInterruptConfig.setVisibility(View.VISIBLE);
        }
    }

    private void onClick(View v) {
        if (v.getId() == R.id.tv_mode_natural_conversation) {
            mARTCAICallEngine.enablePushToTalk(false);

            mTvNaturalConversion.setSelected(true);
            mTvPushToTalk.setSelected(false);

            mVgInterruptConfig.setVisibility(View.VISIBLE);
        } else if (v.getId() == R.id.tv_mode_push_to_talk) {
            mARTCAICallEngine.enablePushToTalk(true);

            mTvNaturalConversion.setSelected(false);
            mTvPushToTalk.setSelected(true);

            mVgInterruptConfig.setVisibility(View.GONE);
        } else if (v.getId() == R.id.btn_delete_voiceprint) {
            mARTCAICallEngine.clearVoicePrint();

            mVgVoicePrintStatus.setVisibility(View.GONE);
        }

    }

}
