package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.aliyun.auikits.aicall.R;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;

public class AICallNoticeDialog {
    public static void showDialog(Context context, int titleResource, boolean showTitle,
                                  int contentResource, boolean showContent,
                                  OnDismissListener onDismissListener) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aicall_common_tips, null, false);

        TextView tvTitle = (TextView) view.findViewById(R.id.tv_dialog_title);
        if (showTitle) {
            tvTitle.setText(titleResource);
        }
        tvTitle.setVisibility(showTitle ? View.VISIBLE : View.GONE);

        TextView tvContent = (TextView)view.findViewById(R.id.tv_dialog_content);
        if (showContent) {
            tvContent.setText(contentResource);
        }
        tvContent.setVisibility(showContent ? View.VISIBLE : View.GONE);

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.CENTER)
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnClickListener((dialog1, v) -> {
                    if (v.getId() == R.id.btn_confirm) {
                        dialog1.dismiss();
                    }
                })
                .setOnDismissListener(onDismissListener)
                .create();
        dialog.show();
    }


}
