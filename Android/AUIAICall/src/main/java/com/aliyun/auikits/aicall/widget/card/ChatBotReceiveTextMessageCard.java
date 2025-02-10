package com.aliyun.auikits.aicall.widget.card;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.constraintlayout.widget.ConstraintLayout;

import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.BaseCard;
import com.aliyun.auikits.aicall.bean.ChatBotChatMessage;
import com.aliyun.auikits.aicall.widget.PlayMessageAnimationView;
import com.aliyun.auikits.aicall.widget.SpeechAnimationView;
import com.aliyun.auikits.aicall.base.card.CardEntity;

public class ChatBotReceiveTextMessageCard extends BaseCard {

    private SpeechAnimationView mThinkingView;
    private TextView mReceiveTextContentView;
    private TextView mReceiveInterruptionView;
    private ImageView mReceiveTextMessageCopyImg;
    private PlayMessageAnimationView mReceiveTextMessagePlayImg;
    private Button mReceiveTextMessagePlayButton;
    private ConstraintLayout mReceiveTextMessageActionButtonLayout;

    public ChatBotReceiveTextMessageCard(Context context) {
        super(context);
    }

    @Override
    public void onCreate(Context context) {
        View root = LayoutInflater.from(context).inflate(R.layout.layout_auiaichat_receive_text_message_card, this, true);
        mThinkingView = (SpeechAnimationView)root.findViewById(R.id.chat_animation_view);
        mReceiveTextContentView = root.findViewById(R.id.chat_message_text);
        mReceiveTextMessageCopyImg = root.findViewById(R.id.chatbot_message_item_copy_ai);
        mReceiveTextMessagePlayImg = root.findViewById(R.id.ic_chatbot_message_play_ai);
        mReceiveTextMessageActionButtonLayout = root.findViewById(R.id.chat_msg_message_item_ai_button_layout);
        mReceiveInterruptionView = root.findViewById(R.id.chat_message_text_interruption_tips);
    }

    @Override
    public void onBind(CardEntity entity) {
        super.onBind(entity);
        if(null != entity.bizData && entity.bizData instanceof ChatBotChatMessage) {
            ChatBotChatMessage chatMessage = (ChatBotChatMessage) entity.bizData;
            if(chatMessage.getMessage() != null) {
                if(chatMessage.getMessage().messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Transfering) {
                    mThinkingView.setVisibility(View.VISIBLE);
                    mThinkingView.setAnimationType(SpeechAnimationView.AnimationType.CHATBOT_THINKING);
                    mReceiveTextMessageActionButtonLayout.setVisibility(View.GONE);
                    mReceiveTextContentView.setVisibility(View.GONE);
                }
                else  {
                    mReceiveTextContentView.setText(chatMessage.getMessage().text);
                    mThinkingView.setVisibility(View.GONE);
                    mReceiveTextMessageActionButtonLayout.setVisibility(View.VISIBLE);
                    mReceiveTextContentView.setVisibility(View.VISIBLE);
                }

                if(chatMessage.getMessage().messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Interrupted) {
                    mReceiveInterruptionView.setVisibility(View.VISIBLE);
                } else {
                    mReceiveInterruptionView.setVisibility(View.GONE);
                }
            }
        }
    }
}
