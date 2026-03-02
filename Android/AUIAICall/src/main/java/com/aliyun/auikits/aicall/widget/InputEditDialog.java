package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.aliyun.auikits.aicall.R;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.ViewHolder;

/**
 * 通用输入弹窗
 */
public class InputEditDialog {

    public interface OnConfirmListener {
        void onConfirm(String inputText);
    }

    /**
     * 显示输入弹窗
     *
     * @param context     上下文
     * @param title       标题
     * @param message     提示信息（可为空）
     * @param initialText 初始文本
     * @param hint        输入提示（可为空）
     * @param listener    确认回调
     */
    public static void show(Context context,
                            String title,
                            String message,
                            String initialText,
                            String hint,
                            OnConfirmListener listener) {

        View view = LayoutInflater.from(context).inflate(R.layout.dialog_input_edit, null, false);

        TextView tvTitle = view.findViewById(R.id.tv_dialog_title);
        TextView tvMessage = view.findViewById(R.id.tv_dialog_message);
        EditText etInput = view.findViewById(R.id.et_dialog_input);
        TextView btnConfirm = view.findViewById(R.id.btn_confirm);
        TextView btnCancel = view.findViewById(R.id.btn_cancel);

        tvTitle.setText(title);

        if (TextUtils.isEmpty(message)) {
            tvMessage.setVisibility(View.GONE);
        } else {
            tvMessage.setText(message);
            tvMessage.setVisibility(View.VISIBLE);
        }

        if (!TextUtils.isEmpty(initialText)) {
            etInput.setText(initialText);
            etInput.setSelection(initialText.length());
        }
        if (!TextUtils.isEmpty(hint)) {
            etInput.setHint(hint);
        }

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.CENTER)
                .setExpanded(false)
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(android.R.color.transparent)
                .create();

        btnConfirm.setOnClickListener(v -> {
            if (listener != null) {
                String text = etInput.getText().toString().trim();
                listener.onConfirm(text);
            }
            dialog.dismiss();
        });

        btnCancel.setOnClickListener(v -> dialog.dismiss());

        dialog.show();
    }
}
