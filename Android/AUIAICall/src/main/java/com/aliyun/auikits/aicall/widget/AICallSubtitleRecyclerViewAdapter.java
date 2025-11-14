package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;
import com.aliyun.auikits.aicall.R;

import java.util.ArrayList;
import java.util.List;


// 字幕显示适配器
public class AICallSubtitleRecyclerViewAdapter extends RecyclerView.Adapter<AICallSubtitleRecyclerViewAdapter.SubtitleItemViewHolder>{

    private final List<AICallSubtitleMessageItem> mSubtitleMessageItemList;
    private final Context mContext;

    public AICallSubtitleRecyclerViewAdapter(Context context) {
        mContext = context;
        mSubtitleMessageItemList = new ArrayList<>();
    }

    public AICallSubtitleRecyclerViewAdapter(Context context, List<AICallSubtitleMessageItem> subtitleMessageItemList) {
        mContext = context;
        mSubtitleMessageItemList = subtitleMessageItemList;
    }

    @NonNull
    @Override
    public AICallSubtitleRecyclerViewAdapter.SubtitleItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.layout_subtitle_message_item, parent, false);
        return new SubtitleItemViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull AICallSubtitleRecyclerViewAdapter.SubtitleItemViewHolder holder, int position) {
        AICallSubtitleMessageItem subtitleMessageItem = mSubtitleMessageItemList.get(position);
        holder.mTvSubtitleItem.setText(subtitleMessageItem.getText());

        // 根据消息为AI的消息或者用户的消息设置不同的颜色
        if (subtitleMessageItem.isAsrText()) {
            holder.mTvSubtitleItem.setTextColor(ContextCompat.getColor(mContext, R.color.color_text));
        } else {
            holder.mTvSubtitleItem.setTextColor(ContextCompat.getColor(mContext, R.color.color_text_tertiary));
        }
    }

    @Override
    public int getItemCount() {
        return mSubtitleMessageItemList.size();
    }

    // 添加一条字幕记录
    public void addSubtitleItem(AICallSubtitleMessageItem subtitleMessageItem) {
        mSubtitleMessageItemList.add(subtitleMessageItem);
        notifyItemInserted(mSubtitleMessageItemList.size() - 1);
    }

    // 追加更新一条字幕记录
    public void appendToLastSubtitle(AICallSubtitleMessageItem subtitleMessageItem) {
        if (!mSubtitleMessageItemList.isEmpty()) {
            AICallSubtitleMessageItem lastSubtitleMessageItem = mSubtitleMessageItemList.get(mSubtitleMessageItemList.size() - 1);
            lastSubtitleMessageItem.setText(lastSubtitleMessageItem.getText() + subtitleMessageItem.getText());
            lastSubtitleMessageItem.setDisplayEndTime(subtitleMessageItem.getDisplayEndTime());
            notifyItemChanged(mSubtitleMessageItemList.size() - 1);
        } else {
            addSubtitleItem(subtitleMessageItem);
        }
    }

    // 替换更新一条字幕记录
    public void replaceLastSubtitle(AICallSubtitleMessageItem subtitleMessageItem) {
        if (!mSubtitleMessageItemList.isEmpty()) {
            AICallSubtitleMessageItem lastSubtitleMessageItem = mSubtitleMessageItemList.get(mSubtitleMessageItemList.size() - 1);
            if(subtitleMessageItem.isAsrText() == lastSubtitleMessageItem.isAsrText() && subtitleMessageItem.getAsrSentenceId() == lastSubtitleMessageItem.getAsrSentenceId()) {
                lastSubtitleMessageItem.setText(subtitleMessageItem.getText());
                lastSubtitleMessageItem.setDisplayEndTime(subtitleMessageItem.getDisplayEndTime());
                notifyItemChanged(mSubtitleMessageItemList.size() - 1);
            } else {
                addSubtitleItem(subtitleMessageItem);
            }
        } else {
            addSubtitleItem(subtitleMessageItem);
        }
    }

    public static class SubtitleItemViewHolder extends RecyclerView.ViewHolder {
        private final TextView mTvSubtitleItem;

        public SubtitleItemViewHolder(View itemView) {
            super(itemView);
            mTvSubtitleItem = itemView.findViewById(R.id.tv_subtitle_item_content);
        }
    }
}
