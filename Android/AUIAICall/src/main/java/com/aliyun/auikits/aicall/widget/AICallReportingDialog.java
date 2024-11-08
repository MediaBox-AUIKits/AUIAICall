package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.util.DisplayUtil;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;

import java.util.ArrayList;
import java.util.List;

public class AICallReportingDialog {
    public static final boolean AI_CALL_REPORTING_ENABLE = false;

    public interface IReportingDialogDismissListener {
        void onReportingSubmit(List<Integer> reportTypeStatIdList, String reportIssueDesc);
        void onDismiss(boolean hasSubmit);
    }

    public static void showDialog(Context context, IReportingDialogDismissListener onDismissListener) {
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aicall_reporting, null, false);
        AICallReportingDialog aiCallReportingDialog = new AICallReportingDialog(view);
        view.setTag(aiCallReportingDialog);

        int statusBarHeight = DisplayUtil.getStatusBarHeight(context);
        View topBar = view.findViewById(R.id.top_bar);
        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) topBar.getLayoutParams();
        layoutParams.topMargin = statusBarHeight;

        ViewHolder viewHolder = new ViewHolder(view);
        DialogPlus dialog = DialogPlus.newDialog(context)
                .setContentHolder(viewHolder)
                .setGravity(Gravity.BOTTOM)
                .setOverlayBackgroundResource(android.R.color.transparent)
                .setContentBackgroundResource(R.color.layout_base_dialog_background)
                .setOnClickListener((dialog1, v) -> {
                    if (v.getId() == R.id.btn_back) {
                        dialog1.dismiss();
                    } else if (v.getId() == R.id.tv_submit) {
                        if (null != onDismissListener) {
                            onDismissListener.onReportingSubmit(aiCallReportingDialog.getReportTypeStatIdList(), aiCallReportingDialog.getReportOtherDesc());
                            aiCallReportingDialog.mHasSubmit = true;
                        }
                        dialog1.dismiss();
                    }
                    aiCallReportingDialog.onClick(v);
                })
                .setOnDismissListener(new OnDismissListener() {
                    @Override
                    public void onDismiss(DialogPlus dialog) {
                        if (null != onDismissListener) {
                            onDismissListener.onDismiss(aiCallReportingDialog.mHasSubmit);
                        }
                    }
                })
                .create();
        dialog.show();
    }

    private class ReportTypeRecord {
        int viewId;
        int statId; // 上报的id
        boolean isSelected = false;

        ReportTypeRecord(int vid, int sid) {
            viewId = vid;
            statId = sid;
        }
    }

    List<ReportTypeRecord> mReportTypeRecordList = new ArrayList<>();
    String mReportDesc = "";
    TextView mTvReportingDescCounting = null;
    TextView mReportTypeOthers = null;
    TextView mTvSubmit = null;
    EditText mEtDesc = null;
    int maxDescCount = 100;
    boolean mHasSubmit = false;

    AICallReportingDialog(View root) {
        mReportTypeRecordList.add(new ReportTypeRecord(R.id.tv_reporting_type_function_unavailable, 1));
        mReportTypeRecordList.add(new ReportTypeRecord(R.id.tv_reporting_type_function_bugs, 2));
        mReportTypeRecordList.add(new ReportTypeRecord(R.id.tv_reporting_type_response_slow, 3));
        mReportTypeRecordList.add(new ReportTypeRecord(R.id.tv_reporting_type_response_inaccurate, 4));
        mReportTypeRecordList.add(new ReportTypeRecord(R.id.tv_reporting_type_media_quality, 5));
        mReportTypeRecordList.add(new ReportTypeRecord(R.id.tv_reporting_type_others, 6));

        mReportTypeOthers = root.findViewById(R.id.tv_reporting_type_others);

        mEtDesc = root.findViewById(R.id.et_reporting_desc);
        mEtDesc.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                mReportDesc = s.toString();

                int countEnd = s.length();
                countEnd = countEnd > maxDescCount ? maxDescCount : countEnd;
                mTvReportingDescCounting.setText(countEnd + "/" + maxDescCount);

                mReportTypeOthers.setSelected(true);
                mReportTypeRecordList.get(mReportTypeRecordList.size()-1).isSelected = true;
                updateSubmitButtonUI();
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() > maxDescCount) {
                    s.delete(maxDescCount, s.length());
                }
            }
        });
        mTvReportingDescCounting = root.findViewById(R.id.tv_reporting_desc_counting);
        mTvSubmit = (TextView) root.findViewById(R.id.tv_submit);
        mTvSubmit.setEnabled(false);
    }

    private void onClick(View v) {
        for (int i = 0; i < mReportTypeRecordList.size(); i++) {
            ReportTypeRecord reportTypeRecord = mReportTypeRecordList.get(i);
            if (reportTypeRecord.viewId == v.getId()) {
                boolean isSelected = !v.isSelected();
                v.setSelected(isSelected);

                reportTypeRecord.isSelected = isSelected;
            }
        }

        updateSubmitButtonUI();
    }

    private void updateSubmitButtonUI() {
        boolean canSubmit = false;
        for (int i = 0; i < mReportTypeRecordList.size(); i++) {
            ReportTypeRecord reportTypeRecord = mReportTypeRecordList.get(i);
            canSubmit |= reportTypeRecord.isSelected;
        }

        mTvSubmit.setEnabled(canSubmit);
    }

    List<Integer> getReportTypeStatIdList() {
        List<Integer> statIdList = new ArrayList<>();
        for (int i = 0; i < mReportTypeRecordList.size(); i++) {
            ReportTypeRecord reportTypeRecord = mReportTypeRecordList.get(i);
            if (reportTypeRecord.isSelected) {
                statIdList.add(reportTypeRecord.statId);
            }
        }
        return statIdList;
    }

    String getReportOtherDesc() {
        if (mEtDesc.isEnabled()) {
            return mReportDesc;
        } else {
            return "";
        }
    }

}
