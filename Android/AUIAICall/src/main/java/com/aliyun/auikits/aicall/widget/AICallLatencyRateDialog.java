package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;

public class AICallLatencyRateDialog {

    // 为了重用类似 AICallReportingDialog 的样式
    public interface ILatencyRateDialogDismissListener {
        void onDismiss();
    }

    public static void showDialog(Context context, ViewModelProvider viewModelProvider, ILatencyRateDialogDismissListener onDismissListener) {
        // 加载布局
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aicall_latency_rate, null, false);
        AICallLatencyRateDialog latencyDialog = new AICallLatencyRateDialog(view, viewModelProvider);
        view.setTag(latencyDialog);
        // 状态栏高度处理
        int statusBarHeight = DisplayUtil.getStatusBarHeight(context);
        View topBar = view.findViewById(R.id.top_bar);
        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) topBar.getLayoutParams();
        layoutParams.topMargin = statusBarHeight;

        // 使用 DialogPlus 构建对话框
        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.color_bg)
                .setExpanded(true, ViewGroup.LayoutParams.MATCH_PARENT)
                .setOnClickListener((dialog1, v) -> { // 处理按钮点击事件
                    if (v.getId() == R.id.btn_back || v.getId() == R.id.btn_close) {
                        dialog1.dismiss(); // 关闭对话框
                    }
                    latencyDialog.onClick(v); // 调用内部的点击逻辑
                })
                .setOnDismissListener(new OnDismissListener() { // 处理对话框关闭事件
                    @Override
                    public void onDismiss(DialogPlus dialog) {
                        if (onDismissListener != null) {
                            onDismissListener.onDismiss(); // 通知监听器
                        }
                    }
                })
                .create();

        // 显示对话框
        dialog.show();
    }

    private RecyclerView mRecyclerView;
    private AICallSentenceLatencyRVAdapter mAdapter;
    private boolean shouldScrollToTop = true; // 控制是否自动滚动
    private AICallSentenceLatencyViewModel mViewModel;

    // 构造函数：绑定布局和初始化逻辑
    private AICallLatencyRateDialog(View root, ViewModelProvider viewModelProvider) {
        // 初始化返回按钮
        ImageView mBackButton = root.findViewById(R.id.btn_back);
        mBackButton.setOnClickListener(v -> { /* 由DialogPlus点击监听处理 */ });

        // 初始化 RecyclerView
        mRecyclerView = root.findViewById(R.id.recycler_view_latency_rate);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(root.getContext());
        linearLayoutManager.setReverseLayout(true);
        linearLayoutManager.setStackFromEnd(true);
        mRecyclerView.setLayoutManager(linearLayoutManager);

        mAdapter = new AICallSentenceLatencyRVAdapter();
        mRecyclerView.setAdapter(mAdapter);
        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    if (!recyclerView.canScrollVertically(-1)) {
                        shouldScrollToTop = true;
                    }
                } else {
                    shouldScrollToTop = false;
                }
            }
        });

        // 初始化 ViewModel
        mViewModel = viewModelProvider.get(AICallSentenceLatencyViewModel.class);

        // 监听数据变化
        mViewModel.getDataList().observeForever(list -> {
            if (list != null) {
                mAdapter.updateData(list);
                if (shouldScrollToTop) {
                    mRecyclerView.scrollToPosition(mAdapter.getItemCount() - 1);
                }
            }
        });
    }

    // 点击事件处理
    private void onClick(View v) {
        // 根据需要扩展具体的点击逻辑
    }
}
