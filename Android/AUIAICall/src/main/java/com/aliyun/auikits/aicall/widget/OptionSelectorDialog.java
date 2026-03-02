package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.ViewHolder;

import java.util.List;

/**
 * 通用的底部选项选择器 Dialog
 */
public class OptionSelectorDialog {

    public interface OnOptionSelectedListener {
        void onOptionSelected(int position, String option);
    }

    /**
     * 显示选项选择 Dialog
     *
     * @param context       上下文
     * @param title         标题
     * @param options       选项列表
     * @param selectedIndex 当前选中的索引
     * @param listener      选择回调
     */
    public static void show(Context context, String title, List<String> options,
                          int selectedIndex, OnOptionSelectedListener listener) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_option_selector, null, false);

        TextView tvTitle = view.findViewById(R.id.tv_dialog_title);
        ImageView ivClose = view.findViewById(R.id.iv_close_dialog);
        RecyclerView rvOptions = view.findViewById(R.id.rv_options);

        tvTitle.setText(title);

        rvOptions.setLayoutManager(new LinearLayoutManager(context));
        OptionAdapter adapter = new OptionAdapter(options, selectedIndex, (position, option) -> {
            if (listener != null) {
                listener.onOptionSelected(position, option);
            }
        });
        rvOptions.setAdapter(adapter);

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setExpanded(false)
                .setOverlayBackgroundResource(R.color.color_bg_mask_transparent_70)
                .setContentBackgroundResource(R.drawable.bg_rounded_setting_dialog)
                .create();

        ivClose.setOnClickListener(v -> dialog.dismiss());

        dialog.show();
    }

    /**
     * RecyclerView 适配器
     */
    private static class OptionAdapter extends RecyclerView.Adapter<OptionAdapter.ViewHolder> {
        private final List<String> options;
        private int selectedPosition;
        private OnOptionSelectedListener listener;

        public OptionAdapter(List<String> options, int selectedPosition, OnOptionSelectedListener listener) {
            this.options = options;
            this.selectedPosition = selectedPosition;
            this.listener = listener;
        }

        public void setOnItemClickListener(OnOptionSelectedListener listener) {
            this.listener = listener;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_dialog_option, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            String option = options.get(position);
            holder.tvOption.setText(option);
            holder.ivCheck.setVisibility(position == selectedPosition ? View.VISIBLE : View.GONE);
            
            // 最后一个选项不显示分隔线
            holder.divider.setVisibility(position == getItemCount() - 1 ? View.GONE : View.VISIBLE);

            holder.itemView.setOnClickListener(v -> {
                int oldPosition = selectedPosition;
                selectedPosition = position;
                notifyItemChanged(oldPosition);
                notifyItemChanged(selectedPosition);

                if (listener != null) {
                    listener.onOptionSelected(position, option);
                }
            });
        }

        @Override
        public int getItemCount() {
            return options.size();
        }

        static class ViewHolder extends RecyclerView.ViewHolder {
            TextView tvOption;
            ImageView ivCheck;
            View divider;

            public ViewHolder(@NonNull View itemView) {
                super(itemView);
                tvOption = itemView.findViewById(R.id.tv_option_text);
                ivCheck = itemView.findViewById(R.id.iv_option_check);
                divider = itemView.findViewById(R.id.divider);
            }
        }
    }
}
