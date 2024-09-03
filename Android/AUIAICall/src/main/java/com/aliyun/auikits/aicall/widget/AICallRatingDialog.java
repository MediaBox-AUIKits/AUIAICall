package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.util.ToastHelper;
import com.orhanobut.dialogplus.DialogPlus;
import com.orhanobut.dialogplus.OnDismissListener;
import com.orhanobut.dialogplus.ViewHolder;

public class AICallRatingDialog {
    private static final boolean AI_CALL_RATING_ENABLE = false;

    private TextView mTvSkip = null;
    private TextView mTvSubmit = null;
    private StarRating mSumRatingHolder = null;
    private StarRating mCallDelayRatingHolder = null;
    private StarRating mNoiseHandlingRatingHolder = null;
    private StarRating mRecognitionAccuracyRatingHolder = null;
    private StarRating mInteractionExperienceRatingHolder = null;
    private StarRating mQualityRealismRatingHolder = null;

    private static boolean sCanSkip = false;

    public interface IRatingDialogDismissListener {
        void onSubmit(int subRating, int callDelay, int noiseHandling,
                       int recognition, int interaction, int realism);
        void onDismiss();
    }

    // 获取系统标题栏的高度
    private static int getStatusBarHeight(Context context) {
        int statusBarHeight = 0;
        if (null != context) {
            int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
            if (resourceId > 0) {
                statusBarHeight = context.getResources().getDimensionPixelSize(resourceId);
            }
        }
        return statusBarHeight;
    }

    public static void show(Context context, IRatingDialogDismissListener onDismissListener) {
        if (!AI_CALL_RATING_ENABLE) {
            if (null != onDismissListener) {
                onDismissListener.onDismiss();
            }
            return;
        }
        View view = LayoutInflater.from(context).inflate(R.layout.dialog_aicall_rating, null, false);
        AICallRatingDialog aiCallRatingDialog = new AICallRatingDialog(view);
        view.setTag(aiCallRatingDialog);

        int statusBarHeight = getStatusBarHeight(context);
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
                    if (v.getId() == R.id.tv_skip) {
                        dialog1.dismiss();
                    } else if (v.getId() == R.id.tv_submit) {
                        if (aiCallRatingDialog.canSubmit()) {
                            if (null != onDismissListener) {
                                onDismissListener.onSubmit(aiCallRatingDialog.mSumRatingHolder.getCurrentScore(),
                                        aiCallRatingDialog.mCallDelayRatingHolder.getCurrentScore(),
                                        aiCallRatingDialog.mNoiseHandlingRatingHolder.getCurrentScore(),
                                        aiCallRatingDialog.mRecognitionAccuracyRatingHolder.getCurrentScore(),
                                        aiCallRatingDialog.mInteractionExperienceRatingHolder.getCurrentScore(),
                                        aiCallRatingDialog.mQualityRealismRatingHolder.getCurrentScore());
                            }
                            dialog1.dismiss();
                        } else {
                            ToastHelper.showToast(context, R.string.complete_rating_tips, Toast.LENGTH_SHORT);
                        }
                    } else {
                        boolean handled = aiCallRatingDialog.mSumRatingHolder.onClick(v) ||
                        aiCallRatingDialog.mCallDelayRatingHolder.onClick(v) ||
                        aiCallRatingDialog.mNoiseHandlingRatingHolder.onClick(v) ||
                        aiCallRatingDialog.mRecognitionAccuracyRatingHolder.onClick(v) ||
                        aiCallRatingDialog.mInteractionExperienceRatingHolder.onClick(v) ||
                        aiCallRatingDialog.mQualityRealismRatingHolder.onClick(v);

                        if (handled) {
                            aiCallRatingDialog.onRatingChanged();
                        }
                    }
                })
                .setCancelable(sCanSkip)
                .setOnDismissListener(new OnDismissListener() {
                    @Override
                    public void onDismiss(DialogPlus dialog) {
                        if (null != onDismissListener) {
                            onDismissListener.onDismiss();
                        }
                        sCanSkip = true;
                    }
                })
                .create();
        dialog.show();
    }

    private AICallRatingDialog(View root) {
        mTvSkip = root.findViewById(R.id.tv_skip);
        mTvSubmit = root.findViewById(R.id.tv_submit);
        if (sCanSkip) {
            mTvSkip.setVisibility(View.VISIBLE);
        } else {
            mTvSkip.setVisibility(View.GONE);
        }
        mTvSubmit.setEnabled(false);
        mSumRatingHolder = new StarRating(root.findViewById(R.id.ll_sum_score));
        mCallDelayRatingHolder = new StarRating(root.findViewById(R.id.ll_score_call_delay));
        mNoiseHandlingRatingHolder = new StarRating(root.findViewById(R.id.ll_score_noise_handling));
        mRecognitionAccuracyRatingHolder = new StarRating(root.findViewById(R.id.ll_score_voice_recognition_accuracy));
        mInteractionExperienceRatingHolder = new StarRating(root.findViewById(R.id.ll_score_interaction_experience));
        mQualityRealismRatingHolder = new StarRating(root.findViewById(R.id.ll_score_voice_quality_realism));
    }

    private void onRatingChanged() {
        if (canSubmit()) {
            mTvSubmit.setEnabled(true);
        }
    }

    private boolean canSubmit() {
        return mSumRatingHolder.getCurrentScore() > 0 &&
                mCallDelayRatingHolder.getCurrentScore() > 0 &&
                mNoiseHandlingRatingHolder.getCurrentScore() > 0 &&
                mRecognitionAccuracyRatingHolder.getCurrentScore() > 0 &&
                mInteractionExperienceRatingHolder.getCurrentScore() > 0 &&
                mQualityRealismRatingHolder.getCurrentScore() > 0;
    }

    private static class StarRating {
        private ViewGroup mRoot;
        private ImageView mIvStarList[] = new ImageView[5];

        private int mCurrentScore = 0;

        private StarRating(ViewGroup root) {
            mRoot = root;

            mIvStarList[0] = mRoot.findViewById(R.id.ic_star1);
            mIvStarList[1] = mRoot.findViewById(R.id.ic_star2);
            mIvStarList[2] = mRoot.findViewById(R.id.ic_star3);
            mIvStarList[3] = mRoot.findViewById(R.id.ic_star4);
            mIvStarList[4] = mRoot.findViewById(R.id.ic_star5);

            for (int i = 0; i < 5; i++) {
                mIvStarList[i].setTag(i+1);
            }
        }

        public int getCurrentScore() {
            return mCurrentScore;
        }

        public boolean onClick(View v) {
            boolean isMyView = false;
            for (int i = 0; i < 5; i++) {
                if (mIvStarList[i].equals(v)) {
                    isMyView = true;
                    break;
                }
            }
            if (isMyView) {
                if (v.getTag() instanceof Integer) {
                    int score = (int) v.getTag();

                    if (score >= 1 && score <= 5) {
                        mCurrentScore = score;

                        for (int i = 0; i < 5; i++) {
                            if (i <= mCurrentScore - 1) {
                                mIvStarList[i].setImageResource(R.drawable.ic_star_blue);
                            } else {
                                mIvStarList[i].setImageResource(R.drawable.ic_star_gray);
                            }
                        }
                    }
                }
            }
            return isMyView;
        }
    }
}
