package com.aliyun.auikits.aicall.widget;

import android.annotation.SuppressLint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aicall.R;

import java.util.ArrayList;
import java.util.List;

public class AICallSentenceLatencyRVAdapter extends RecyclerView.Adapter<AICallSentenceLatencyRVAdapter.SentenceLatencyViewHolder> {
    private final List<AICallSentenceLatencyItem> mSentenceLatencyItems = new ArrayList<>();

    @SuppressLint("NotifyDataSetChanged")
    public void updateData(List<AICallSentenceLatencyItem> newData) {
        mSentenceLatencyItems.clear();
        mSentenceLatencyItems.addAll(newData);
        notifyDataSetChanged();
    }

    public void addNewData(AICallSentenceLatencyItem newData) {

    }

    @NonNull
    @Override
    public SentenceLatencyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_auiaicall_in_call_sentence_latency_item, parent, false);
        return new SentenceLatencyViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull SentenceLatencyViewHolder holder, int position) {
        AICallSentenceLatencyItem item = mSentenceLatencyItems.get(position);
        holder.mSentenceId.setText(String.valueOf(item.getSentenceId()));
        holder.mLatency.setText(item.getLatencyStr());
    }

    @Override
    public int getItemCount() {
        return mSentenceLatencyItems.size();
    }


    public static class SentenceLatencyViewHolder extends RecyclerView.ViewHolder {
        TextView mSentenceId;
        TextView mLatency;

        public SentenceLatencyViewHolder(@NonNull View itemView) {
            super(itemView);
            mSentenceId = itemView.findViewById(R.id.tv_latency_rate_sentence_id);
            mLatency = itemView.findViewById(R.id.tv_latency_rate_sentence_latency_value);
        }
    }
}
