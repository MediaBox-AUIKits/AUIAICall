package com.aliyun.auikits.aicall.base.feed;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.aliyun.auikits.aicall.R;
import com.chad.library.adapter.base.loadmore.BaseLoadMoreView;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;
import androidx.annotation.NonNull;

public class CustomLoadMoreView extends BaseLoadMoreView {
    @NonNull
    @Override
    public View getRootView(@NonNull ViewGroup parent) {
        return LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_base_loading_more_view, parent, false);
    }

    @NonNull
    @Override
    public View getLoadingView(@NonNull BaseViewHolder holder) {
        return holder.findView(R.id.load_more_loading_view);
    }

    @NonNull
    @Override
    public View getLoadComplete(@NonNull BaseViewHolder holder) {
        return holder.findView(R.id.load_more_load_complete_view);
    }

    @NonNull
    @Override
    public View getLoadEndView(@NonNull BaseViewHolder holder) {
        return holder.findView(R.id.load_more_load_end_view);
    }

    @NonNull
    @Override
    public View getLoadFailView(@NonNull BaseViewHolder holder) {
        return holder.findView(R.id.load_more_load_fail_view);
    }

}
