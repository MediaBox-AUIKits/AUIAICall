package com.aliyun.auikits.aicall.widget.card;

import static androidx.core.content.ContextCompat.startActivity;

import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aiagent.ARTCAIChatAttachmentUploader;
import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.AUIAIChatExternalViewActivity;
import com.aliyun.auikits.aicall.AUIAIChatInChatActivity;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.BaseCard;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.card.CardListAdapter;
import com.aliyun.auikits.aicall.base.card.DefaultCardViewFactory;
import com.aliyun.auikits.aicall.base.feed.ContentViewModel;
import com.aliyun.auikits.aicall.bean.ChatBotChatMessage;
import com.aliyun.auikits.aicall.bean.ChatBotSelectedFileAttachment;
import com.aliyun.auikits.aicall.model.ChatBotSelectImagesContentModel;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.markwon.AUIAIMarkwonManager;
import com.aliyun.auikits.aicall.widget.PlayMessageAnimationView;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemClickListener;
import com.chad.library.adapter.base.listener.OnItemLongClickListener;

public class ChatBotSendTextMessageCard extends BaseCard {

    public interface OnMessageItemLongClickListener {
        void onMessageItemLongClick();
    }

    private Button mSendTextMessageStatusImage;
    private TextView mSendTextMessageContentTextView;
    private ConstraintLayout mSendTextMessageActionButtonLayout;
    private ImageView  mSendTextMessageCopyImageView;
    private PlayMessageAnimationView mSendTextMessagePlayImageView;
    private Context mContext = null;
    private LinearLayout mSendTextLayout;
    public RecyclerView mSendImagesListView;
    private CardListAdapter mSendImagesListAdapter;
    private ChatBotSelectImagesContentModel mSendImagesContentModel;
    private ContentViewModel mSendImageViewModel;
    private boolean mImageLoaded = false;
    private ConstraintLayout mSendMessageLayout;
    private OnMessageItemLongClickListener listener;
    private int mImageSize = 0;

    public ChatBotSendTextMessageCard(Context context) {
        super(context);
    }

    public void setOnMessageItemLongClickListener(OnMessageItemLongClickListener listener) {
        this.listener = listener;
    }

    @Override
    public void onCreate(Context context) {
        mContext = context;
        View  root = LayoutInflater.from(context).inflate(R.layout.layout_auiaichat_send_text_message_card, this, true);
        mSendTextMessageStatusImage = root.findViewById(R.id.chatbot_send_message_status);
        mSendTextMessageContentTextView = root.findViewById(R.id.chat_message_text);
        mSendTextMessageActionButtonLayout = root.findViewById(R.id.chat_msg_message_item_user_button_layout);
        mSendTextMessageCopyImageView = root.findViewById(R.id.chatbot_message_item_copy_user);
        mSendTextMessagePlayImageView = root.findViewById(R.id.ic_chatbot_message_play_user);
        mSendTextLayout = root.findViewById(R.id.chatbot_send_message_item_text_layout);
        mSendImagesListView = root.findViewById(R.id.chatbot_send_image_list);
        mSendMessageLayout = root.findViewById(R.id.chatbot_send_message_item);
        mSendImagesListView.addItemDecoration(new ItemSpacingDecoration((int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, 8, getResources().getDisplayMetrics())));
    }

    @Override
    public void onBind(CardEntity entuty) {
        super.onBind(entuty);

        if(null != entity.bizData && entity.bizData instanceof ChatBotChatMessage) {

            ChatBotChatMessage chatMessage = (ChatBotChatMessage) entity.bizData;
            if(chatMessage.getMessage() != null) {

                String text = chatMessage.getMessage().text;

                if(TextUtils.isEmpty(text)) {
                    mSendTextLayout.setVisibility(View.GONE);
                } else {
                    mSendTextLayout.setVisibility(View.VISIBLE);
                }
                AUIAIMarkwonManager.getInstance(mContext).getMarkwon().setMarkdown(mSendTextMessageContentTextView, chatMessage.getMessage().text);
                //mSendTextMessageContentTextView.setText(chatMessage.getMessage().text);

                if(chatMessage.getMessage().attachmentList != null && chatMessage.getMessage().attachmentList.size() > 0) {

                    if(!mImageLoaded) {
                        mImageLoaded = true;
                        DefaultCardViewFactory factory = new DefaultCardViewFactory();
                        factory.registerCardView(CardTypeDef.CHATBOT_SEND_IMAGE_ITEM_CARD, ChatBotSentItemImageCard.class);
                        mSendImagesListAdapter = new CardListAdapter(factory);
                        mSendImagesListAdapter.setAutoScrollToBottom(false);
                        mSendImagesListView.setAdapter(mSendImagesListAdapter);
                        mSendImagesListView.setLayoutManager(new LinearLayoutManager(mContext, RecyclerView.HORIZONTAL, false));
                        mSendImagesListView.setItemAnimator(null);
                        mSendImagesContentModel = new ChatBotSelectImagesContentModel(null, CardTypeDef.CHATBOT_SEND_IMAGE_ITEM_CARD);
                        mSendImageViewModel = new ContentViewModel.Builder()
                                .setContentModel(mSendImagesContentModel)
                                .setLoadMoreEnable(false)
                                .build();
                        mSendImageViewModel.bindView(mSendImagesListAdapter);
                        for (ARTCAIChatAttachmentUploader.ARTCAIChatAttachment attachment : chatMessage.getMessage().attachmentList) {
                            ChatBotSelectedFileAttachment selectedFileAttachment = new ChatBotSelectedFileAttachment(attachment.attachmentId, getType(attachment.attachmentType), attachment.path);
                            mSendImagesContentModel.addSelectedImage(selectedFileAttachment);
                        }
                    } else {
                        mSendImagesListAdapter.setNewData(null);
                        for (ARTCAIChatAttachmentUploader.ARTCAIChatAttachment attachment : chatMessage.getMessage().attachmentList) {
                            ChatBotSelectedFileAttachment selectedFileAttachment = new ChatBotSelectedFileAttachment(attachment.attachmentId, getType(attachment.attachmentType), attachment.path);
                            mSendImagesContentModel.addSelectedImage(selectedFileAttachment);
                        }
                    }

                    mSendImagesListAdapter.setOnItemLongClickListener(new OnItemLongClickListener() {
                        @Override
                        public boolean onItemLongClick(@NonNull BaseQuickAdapter adapter, @NonNull View view, int position) {
                            if(listener != null) {
                                listener.onMessageItemLongClick();
                            }
                            return false;
                        }
                    });

                    mSendImagesListAdapter.setOnItemClickListener(new OnItemClickListener() {
                        @Override
                        public void onItemClick(@NonNull BaseQuickAdapter<?, ?> adapter, @NonNull View view, int position) {

                            if(position >= 0 && position < chatMessage.getMessage().attachmentList.size()) {
                                showDetailImage(chatMessage.getMessage().attachmentList.get(position));
                            }
                        }
                    });

                    mSendImagesListView.setVisibility(View.VISIBLE);

                    //调整位置和尺寸
                    LinearLayout.LayoutParams imagesLayoutParams = (LinearLayout.LayoutParams) mSendImagesListView.getLayoutParams();
                    if(!TextUtils.isEmpty(text)) {
                        imagesLayoutParams.bottomMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 8, getResources().getDisplayMetrics());
                    }
                    int attachSize = chatMessage.getMessage().attachmentList.size();
                    LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) mSendMessageLayout.getLayoutParams();
                    LinearLayout.LayoutParams textLayoutParams = (LinearLayout.LayoutParams) mSendTextLayout.getLayoutParams();
                    if(attachSize  == 4) {
                        layoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 0, getResources().getDisplayMetrics());
                        textLayoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 12, getResources().getDisplayMetrics());
                        imagesLayoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 0, getResources().getDisplayMetrics());
                    } else if(attachSize  > 4) {
                        layoutParams.leftMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 0, getResources().getDisplayMetrics());
                        textLayoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 12, getResources().getDisplayMetrics());
                        textLayoutParams.leftMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 32, getResources().getDisplayMetrics());
                        imagesLayoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 0, getResources().getDisplayMetrics());
                    } else {
                        layoutParams.leftMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 32, getResources().getDisplayMetrics());
                        layoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 12, getResources().getDisplayMetrics());
                        textLayoutParams.leftMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 0, getResources().getDisplayMetrics());
                        textLayoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 0, getResources().getDisplayMetrics());
                        imagesLayoutParams.rightMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 12, getResources().getDisplayMetrics());
                    }
                    mSendMessageLayout.setLayoutParams(layoutParams);
                    mSendTextLayout.setLayoutParams(textLayoutParams);
                    mSendImagesListView.setLayoutParams(imagesLayoutParams);
                    mImageSize = attachSize;

                } else {
                    mSendImagesListView.setVisibility(View.GONE);
                }

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

    private void showDetailImage(ARTCAIChatAttachmentUploader.ARTCAIChatAttachment attachment) {
        if(attachment != null && !TextUtils.isEmpty(attachment.path)) {
            Intent intent = new Intent(mContext, AUIAIChatExternalViewActivity.class);
            intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_EXTERNAL_IMAGE_URL, attachment.path);
            startActivity(mContext, intent, null);
        }
    }

    private ChatBotSelectedFileAttachment.ChatBotAttachmentType getType(ARTCAIChatAttachmentUploader.ARTCAIChatAttachmentType type) {
        switch (type) {
            case Image:
                return ChatBotSelectedFileAttachment.ChatBotAttachmentType.Image;
            case Audio:
                return ChatBotSelectedFileAttachment.ChatBotAttachmentType.Audio;
            case Video:
                return ChatBotSelectedFileAttachment.ChatBotAttachmentType.Video;
            case Other:
                return ChatBotSelectedFileAttachment.ChatBotAttachmentType.Other;
            default:
                return ChatBotSelectedFileAttachment.ChatBotAttachmentType.None;
        }
    }

    private class ItemSpacingDecoration extends RecyclerView.ItemDecoration {
        private final int spacing;

        public ItemSpacingDecoration(int spacingInPx) {
            this.spacing = spacingInPx;
        }

        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                                   @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            // 获取当前项的位置
            int position = parent.getChildAdapterPosition(view);

            // 如果不是第一个项，则设置顶部间距
            if ((position > 0) && (position < mImageSize - 1)) {
                outRect.left = (int) TypedValue.applyDimension(
                        TypedValue.COMPLEX_UNIT_DIP, 8, getResources().getDisplayMetrics());
            } else if(position == 0) {
                outRect.left = (int) TypedValue.applyDimension(
                        TypedValue.COMPLEX_UNIT_DIP, 32, getResources().getDisplayMetrics());;
            } else if(position == mImageSize -1 ){
                outRect.left = (int) TypedValue.applyDimension(
                        TypedValue.COMPLEX_UNIT_DIP, 8, getResources().getDisplayMetrics());
                if(mImageSize >= 4) {
                    outRect.right = (int) TypedValue.applyDimension(
                            TypedValue.COMPLEX_UNIT_DIP, 12, getResources().getDisplayMetrics());
                }
            }
        }
    }

}
