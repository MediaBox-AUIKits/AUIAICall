package com.aliyun.auikits.aicall.widget.card;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.constraintlayout.widget.ConstraintLayout;

import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.BaseCard;
import com.aliyun.auikits.aicall.bean.ChatBotChatMessage;
import com.aliyun.auikits.aicall.widget.PlayMessageAnimationView;
import com.aliyun.auikits.aicall.widget.SpeechAnimationView;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.util.markwon.AUIAIMarkwonManager;

public class ChatBotReceiveTextMessageCard extends BaseCard {

    private SpeechAnimationView mThinkingView;
    private TextView mReceiveTextContentView;
    private TextView mReceiveInterruptionView;
    private ImageView mReceiveTextMessageCopyImg;
    private PlayMessageAnimationView mReceiveTextMessagePlayImg;
    private Button mReceiveTextMessagePlayButton;
    private ConstraintLayout mReceiveTextMessageActionButtonLayout;
    private ConstraintLayout mReceiveTextMessageLayout;
    private ConstraintLayout mReceiveThinkTextMessageLayout;
    private ImageView mReceiveThinkFinishImage;
    private TextView mReceiveThinkTitle;
    private TextView mReceiveThinkDesc;
    private ImageView mReceiveThinkTitleButton;
    private ConstraintLayout mReceiveThinkTextDescMessageLayout;
    private boolean isThinkingShow = true;
    private Context mContext = null;
    public ChatBotReceiveTextMessageCard(Context context) {
        super(context);
    }

    @Override
    public void onCreate(Context context) {
        mContext = context;
        View root = LayoutInflater.from(context).inflate(R.layout.layout_auiaichat_receive_text_message_card, this, true);
        mThinkingView = (SpeechAnimationView)root.findViewById(R.id.chat_animation_view);
        mReceiveTextContentView = root.findViewById(R.id.chat_message_text);
        mReceiveTextMessageCopyImg = root.findViewById(R.id.chatbot_message_item_copy_ai);
        mReceiveTextMessagePlayImg = root.findViewById(R.id.ic_chatbot_message_play_ai);
        mReceiveTextMessageActionButtonLayout = root.findViewById(R.id.chat_msg_message_item_ai_button_layout);
        mReceiveTextMessageLayout = root.findViewById(R.id.chat_msg_message_item_ai_text_layout);
        mReceiveInterruptionView = root.findViewById(R.id.chat_message_text_interruption_tips);
        mReceiveThinkTextMessageLayout = root.findViewById(R.id.chat_msg_message_item_ai_thinking_layout);
        mReceiveThinkFinishImage = root.findViewById(R.id.chat_msg_message_item_ai_thinking_finish_img);
        mReceiveThinkTitle = root.findViewById(R.id.chat_msg_message_item_ai_thinking_title);
        mReceiveThinkDesc = root.findViewById(R.id.chat_msg_message_item_ai_thinking_desc);
        mReceiveThinkTitleButton = root.findViewById(R.id.chat_msg_message_item_ai_thinking_title_button);
        mReceiveThinkTextDescMessageLayout = root.findViewById(R.id.chat_msg_message_item_ai_thinking_desc_layout);

        mReceiveThinkTitleButton.setOnClickListener(new View.OnClickListener() {
               @Override
               public void onClick(View v) {
                   isThinkingShow = !isThinkingShow;
                   if(isThinkingShow) {
                       mReceiveThinkTextDescMessageLayout.setVisibility(View.VISIBLE);
                       mReceiveThinkTitleButton.setImageResource(R.drawable.ic_chatbot_think_open);
                   } else {
                       mReceiveThinkTextDescMessageLayout.setVisibility(View.GONE);
                       mReceiveThinkTitleButton.setImageResource(R.drawable.ic_chatbot_think_close);
                   }
               }
        });

    }

    @Override
    public void onBind(CardEntity entity) {
        super.onBind(entity);
        if(null != entity.bizData && entity.bizData instanceof ChatBotChatMessage) {
            ChatBotChatMessage chatMessage = (ChatBotChatMessage) entity.bizData;
            String thinkText = chatMessage.getMessage().reasoningText;
            boolean isThinkingEnd = chatMessage.getMessage().isReasoningEnd;
            if(chatMessage.getMessage() != null) {
                if(chatMessage.getMessage().messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Transfering) {
                    mThinkingView.setVisibility(View.VISIBLE);
                    mThinkingView.setAnimationType(SpeechAnimationView.AnimationType.CHATBOT_THINKING);
                    mReceiveThinkTextMessageLayout.setVisibility(View.GONE);
                    mReceiveTextMessageLayout.setVisibility(View.GONE);
                    mReceiveTextContentView.setVisibility(View.GONE);

                    mReceiveTextMessageActionButtonLayout.setVisibility(View.GONE);
                } else  {
                    mThinkingView.setVisibility(View.GONE);
                    if(!TextUtils.isEmpty(thinkText)) {
                        //has thinking text
                        mReceiveThinkTextMessageLayout.setVisibility(View.VISIBLE);
                        if(isThinkingEnd) {
                            //think end show response text
                            mReceiveThinkFinishImage.setVisibility(View.VISIBLE);
                            mReceiveThinkTitle.setText(R.string.robot_thinking_finish_tips);
                            AUIAIMarkwonManager.getInstance(mContext).getMarkwon().setMarkdown(mReceiveTextContentView, chatMessage.getMessage().text);
                           // mReceiveTextContentView.setText(chatMessage.getMessage().text);
                            mReceiveTextMessageLayout.setVisibility(View.VISIBLE);
                            if(chatMessage.getMessage().messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Printing) {
                                mReceiveTextMessageActionButtonLayout.setVisibility(View.GONE);
                            } else {
                                mReceiveTextMessageActionButtonLayout.setVisibility(entity.isLastItem ? View.VISIBLE : View.GONE);
                            }
                            mReceiveTextContentView.setVisibility(View.VISIBLE);
                        } else {
                            mReceiveThinkFinishImage.setVisibility(View.GONE);
                            mReceiveThinkTitle.setText(R.string.robot_thinking_tips);
                            mReceiveTextMessageLayout.setVisibility(View.GONE);
                            mReceiveTextMessageActionButtonLayout.setVisibility(View.GONE);
                        }
                        mReceiveThinkDesc.setText(thinkText);
                    } else {
                        //no thinking text
                        mReceiveThinkTextMessageLayout.setVisibility(View.GONE);
                        AUIAIMarkwonManager.getInstance(mContext).getMarkwon().setMarkdown(mReceiveTextContentView, chatMessage.getMessage().text);
                        //mReceiveTextContentView.setText(chatMessage.getMessage().text);
                        if(chatMessage.getMessage().messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Printing) {
                            mReceiveTextMessageActionButtonLayout.setVisibility(View.GONE);
                        } else {
                            mReceiveTextMessageActionButtonLayout.setVisibility(entity.isLastItem ? View.VISIBLE : View.GONE);
                        }
                        mReceiveTextMessageLayout.setVisibility(View.VISIBLE);
                        mReceiveTextContentView.setVisibility(View.VISIBLE);
                    }
                }

                if(chatMessage.getMessage().messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Interrupted) {
                    if(!TextUtils.isEmpty(thinkText) && !isThinkingEnd) {
                        mReceiveThinkTitle.setText(R.string.robot_thinking_stop_tips);
                        if(entity.isLastItem) {
                            mReceiveTextMessageActionButtonLayout.setVisibility(View.VISIBLE);
                        } else {
                            mReceiveTextMessageActionButtonLayout.setVisibility(View.GONE);
                        }
                    } else {
                        mReceiveInterruptionView.setVisibility(View.VISIBLE);
                    }
                } else {
                    mReceiveInterruptionView.setVisibility(View.GONE);
                }
            }
        }
    }
}
