package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.os.Handler;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.aliyun.auikits.aicall.R;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;

public class AICallNoticeDialog {
    public interface IActionHandle {
        void handleAction();
    }
    public static void showFunctionalDialog(Context context, String titleResource, boolean showTitle,
                                            String contentResource, boolean showContent,
                                            int functionBtnResource,
                                            IActionHandle actionHandle) {

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

        TextView tvFunction =  (TextView)view.findViewById(R.id.btn_cancel);
        tvFunction.setText(functionBtnResource);
        tvFunction.setVisibility(View.VISIBLE);

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.CENTER)
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnClickListener((dialog1, v) -> {
                    if (v.getId() == R.id.btn_confirm) {
                        dialog1.dismiss();
                    } else if (v.getId() == R.id.btn_cancel) {
                        if (null != actionHandle) {
                            actionHandle.handleAction();
                        }
                    }
                })
                .create();
        dialog.show();
    }

    public static void showFunctionalDialogEx(Context context, String titleResource, boolean showTitle,
                                            String contentResource, boolean showContent,
                                            boolean showCancel,
                                            IActionHandle actionHandle) {

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

        TextView tvFunction =  (TextView)view.findViewById(R.id.btn_cancel);
        tvFunction.setVisibility(showCancel? View.VISIBLE: View.GONE);

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.CENTER)
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnClickListener((dialog1, v) -> {
                    if (v.getId() == R.id.btn_confirm || v.getId() == R.id.btn_cancel) {
                        dialog1.dismiss();
                        if (null != actionHandle) {
                            actionHandle.handleAction();
                        }

                    }
                })
                .create();
        dialog.show();
    }

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
