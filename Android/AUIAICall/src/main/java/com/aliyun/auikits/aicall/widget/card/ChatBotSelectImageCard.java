package com.aliyun.auikits.aicall.widget.card;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.BaseCard;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.bean.ChatBotSelectedFileAttachment;
import com.bumptech.glide.Glide;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.lang.ref.WeakReference;

public class ChatBotSelectImageCard extends BaseCard {

    private ImageView photoImage;
    private WeakReference<Context> mContextRef;
    private ProgressBar progressBar;
    private ImageView uploadFailedImage;

    public ChatBotSelectImageCard(Context context) {
        super(context);
        this.setLayoutParams(new RecyclerView.LayoutParams(RecyclerView.LayoutParams.WRAP_CONTENT, RecyclerView.LayoutParams.WRAP_CONTENT));

    }

    @Override
    public void onCreate(Context context) {
        this.mContextRef = new WeakReference<>(context);
        View  root = LayoutInflater.from(context).inflate(R.layout.layout_auiaichat_in_chat_selected_image, this, true);
        photoImage = root.findViewById(R.id.chatbot_selected_image);
        progressBar = root.findViewById(R.id.chatbot_imageprogress_bar);
        uploadFailedImage = root.findViewById(R.id.chatbot_image_upload_failed);
    }

    @Override
    public void onBind(CardEntity entity) {
        super.onBind(entity);

        if(null != entity.bizData && entity.bizData instanceof ChatBotSelectedFileAttachment) {
            ChatBotSelectedFileAttachment attachment = (ChatBotSelectedFileAttachment)entity.bizData;

            if(attachment.attachmentUri != null && attachment.attachmentType == ChatBotSelectedFileAttachment.ChatBotAttachmentType.Image) {
                Glide.with(this)
                        .load(attachment.attachmentUri)
                        .into(photoImage);
            }

            if(attachment.uploadFailed) {
                uploadFailedImage.setVisibility(View.VISIBLE);
            } else {
                uploadFailedImage.setVisibility(View.GONE);
            }

            if(attachment.progress < 100) {
                float process = 40 + attachment.progress;
                if(process > 100)
                    process = 100;
                progressBar.setVisibility(View.VISIBLE);
                progressBar.setProgress((int) (process ));
            } else {
                progressBar.setVisibility(View.GONE);
            }

        }
    }
}
