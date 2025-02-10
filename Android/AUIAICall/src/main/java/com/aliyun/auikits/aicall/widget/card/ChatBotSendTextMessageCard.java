package com.aliyun.auikits.aicall.widget.card;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.constraintlayout.widget.ConstraintLayout;

import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.BaseCard;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.bean.ChatBotChatMessage;
import com.aliyun.auikits.aicall.widget.PlayMessageAnimationView;

public class ChatBotSendTextMessageCard extends BaseCard {

    private Button mSendTextMessageStatusImage;
    private TextView mSendTextMessageContentTextView;
    private ConstraintLayout mSendTextMessageActionButtonLayout;
    private ImageView  mSendTextMessageCopyImageView;
    private PlayMessageAnimationView mSendTextMessagePlayImageView;

    public ChatBotSendTextMessageCard(Context context) {
        super(context);
    }

    @Override
    public void onCreate(Context context) {
        View  root = LayoutInflater.from(context).inflate(R.layout.layout_auiaichat_send_text_message_card, this, true);
        mSendTextMessageStatusImage = root.findViewById(R.id.chatbot_send_message_status);
        mSendTextMessageContentTextView = root.findViewById(R.id.chat_message_text);
        mSendTextMessageActionButtonLayout = root.findViewById(R.id.chat_msg_message_item_user_button_layout);
        mSendTextMessageCopyImageView = root.findViewById(R.id.chatbot_message_item_copy_user);
        mSendTextMessagePlayImageView = root.findViewById(R.id.ic_chatbot_message_play_user);
    }

    @Override
    public void onBind(CardEntity entuty) {
        super.onBind(entuty);

        if(null != entity.bizData && entity.bizData instanceof ChatBotChatMessage) {

            ChatBotChatMessage chatMessage = (ChatBotChatMessage) entity.bizData;
            if(chatMessage.getMessage() != null) {
                mSendTextMessageContentTextView.setText(chatMessage.getMessage().text);
                if(chatMessage.getMessage().messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Failed) {
                    mSendTextMessageStatusImage.setBackgroundResource(R.drawable.ic_chatbot_message_send_retry);
                    mSendTextMessageActionButtonLayout.setVisibility(View.GONE);
                    mSendTextMessageStatusImage.setVisibility(View.VISIBLE);
                }
                else if(chatMessage.getMessage().messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Finished) {
                    mSendTextMessageStatusImage.setVisibility(View.GONE);
                    mSendTextMessageActionButtonLayout.setVisibility(View.VISIBLE);
                }
                else {
                    mSendTextMessageStatusImage.setBackgroundResource(R.drawable.ic_chatbot_msg_send_loading);
                    mSendTextMessageActionButtonLayout.setVisibility(View.GONE);
                    mSendTextMessageStatusImage.setVisibility(View.VISIBLE);
                }
            }
        }

    }

}
