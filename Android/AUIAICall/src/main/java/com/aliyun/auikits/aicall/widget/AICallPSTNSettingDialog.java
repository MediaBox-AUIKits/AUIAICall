package com.aliyun.auikits.aicall.widget;
import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aicall.BuildConfig;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.card.CardListAdapter;
import com.aliyun.auikits.aicall.base.card.DefaultCardViewFactory;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.model.AudioToneContentModel;
import com.aliyun.auikits.aicall.base.feed.ContentViewModel;
import com.aliyun.auikits.aicall.base.feed.BizParameter;
import com.aliyun.auikits.aicall.util.AUIAICallAgentScenarioConfig;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.aliyun.auikits.aicall.util.SettingStorage;
import com.aliyun.auikits.aicall.widget.card.AudioToneCard;
import com.aliyun.auikits.aicall.widget.card.CardTypeDef;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.util.Logger;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemChildClickListener;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;
import com.scwang.smart.refresh.layout.SmartRefreshLayout;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
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
    private static String currentAgentId = "";

    private static String mDefaultTitle;

    public interface AICallPSTNVoiceChangeListener {
        void onVoiceChange(String voice) ;
    }

    public static List<AudioToneData> getDefaultAudioToneList(Context context) {
        List<AudioToneData> mAgentVoiceIdList = new ArrayList<AudioToneData>();

        // 添加voice_id 为空的默认音色
        AudioToneData defaultVoice = new AudioToneData("", context.getString(R.string.chat_bot_default_voice));
        defaultVoice.setIconResId(R.drawable.ic_audio_tone_1);
        mAgentVoiceIdList.add(defaultVoice);

        // 设置默认选中状态
        if (TextUtils.isEmpty(currentVoice)) {
            currentVoice = defaultVoice.getTitle();
            defaultVoice.setUsing(true);
        } else {
            // 如果已有选中状态，检查是否匹配默认音色
            if (defaultVoice.getTitle().equals(currentVoice)) {
                defaultVoice.setUsing(true);
            }
        }

        return mAgentVoiceIdList;
    }

    /**
     * 从配置文件读取音色列表（电话呼出场景使用）
     * @param context 上下文
     * @param agentId 智能体ID
     * @return 音色列表，第一个为"默认音色"（voice_id=""），后面为 voice_styles 中的音色
     */
    public static List<AudioToneData> getAudioToneListFromConfig(Context context, String agentId) {
        if (TextUtils.isEmpty(agentId)) {
            return getDefaultAudioToneList(context);
        }

        // 使用统一管理类获取音色列表
        List<AudioToneData> voiceList = AUIAICallAgentScenarioConfig.getVoiceStylesForAgent(
                context,
                agentId,
                ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent
        );

        if (voiceList.isEmpty()) {
            return getDefaultAudioToneList(context);
        }

        // 在列表最前面插入一个"默认音色"选项（voice_id=""）
        AudioToneData defaultVoice = new AudioToneData("", context.getString(R.string.chat_bot_default_voice));
        defaultVoice.setIconResId(R.drawable.ic_audio_tone_1);
        voiceList.add(0, defaultVoice);

        // 检查是否切换了场景（agentId 变化）
        boolean isScenarioChanged = !agentId.equals(currentAgentId);
        if (isScenarioChanged) {
            // 切换场景时，重置为新场景的 voice_styles[0]
            currentAgentId = agentId;
            voiceList.get(1).setUsing(true);
            currentVoice = voiceList.get(1).getTitle();
            currentAudioToneId = voiceList.get(1).getAudioToneId();
            return voiceList;
        }

        // 同一场景内，设置选中状态
        if (TextUtils.isEmpty(currentVoice) || TextUtils.isEmpty(currentAudioToneId)) {
            // 首次进入：默认选中 voice_styles[0]（即列表中的第二个，索引为1），与场景选择页显示的音色保持一致
            voiceList.get(1).setUsing(true);
            currentVoice = voiceList.get(1).getTitle();
            currentAudioToneId = voiceList.get(1).getAudioToneId();
        } else {
            // 查找之前选中的音色
            boolean found = false;
            for (AudioToneData data : voiceList) {
                if (data.getAudioToneId().equals(currentAudioToneId)) {
                    data.setUsing(true);
                    found = true;
                    break;
                }
            }
            // 如果之前选中的音色不在列表中，默认选中 voice_styles[0]（列表索引1）
            if (!found) {
                voiceList.get(1).setUsing(true);
                currentVoice = voiceList.get(1).getTitle();
                currentAudioToneId = voiceList.get(1).getAudioToneId();
            }
        }

        return voiceList;
    }

    public static void show(Context context, List<AudioToneData> audioToneList, AICallPSTNVoiceChangeListener listener) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aipstn_setting, null, false);
        AICallPSTNSettingDialog aiSettingDialog = new AICallPSTNSettingDialog(context, view, audioToneList, listener);
        view.setTag(aiSettingDialog);

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
        mDefaultTitle = context.getString(R.string.chat_bot_default_voice);
        
        // 设置RecyclerView的padding，确保最后一个item有足够空间显示
        rvAudioToneList.setPadding(0, 0, 0, DisplayUtil.dip2px(16));
        rvAudioToneList.setClipToPadding(false);
        rvAudioToneList.setOverScrollMode(View.OVER_SCROLL_NEVER);

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
