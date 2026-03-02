package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.auikits.aicall.R;

public class EntranceGuideView extends FrameLayout {

    private Paint mPaint;
    private Paint mClearPaint;
    private Paint mBorderPaint;
    private RectF mTargetRect;
    private ImageView mIvArrow;
    private TextView mTvHint;
    private View mTargetView;
    private OnTargetClickListener mOnTargetClickListener;

    public interface OnTargetClickListener {
        void onTargetClick();
    }

    public EntranceGuideView(@NonNull Context context) {
        this(context, null);
    }

    public EntranceGuideView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public EntranceGuideView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        setWillNotDraw(false);
        setClickable(true);
        setFocusable(true);

        LayoutInflater.from(context).inflate(R.layout.layout_entrance_guide, this, true);

        mIvArrow = findViewById(R.id.iv_guide_arrow);
        mTvHint = findViewById(R.id.tv_guide_hint);

        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mPaint.setColor(context.getResources().getColor(R.color.color_bg_mask_transparent_70));
        mPaint.setStyle(Paint.Style.FILL);

        mClearPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mClearPaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.CLEAR));

        mBorderPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mBorderPaint.setColor(context.getResources().getColor(R.color.color_border_selection));
        mBorderPaint.setStyle(Paint.Style.STROKE);
        mBorderPaint.setStrokeWidth(2 * getResources().getDisplayMetrics().density);
    }

    public void setTargetView(View targetView) {
        if (targetView == null) {
            return;
        }

        mTargetView = targetView;

        int[] location = new int[2];
        targetView.getLocationOnScreen(location);

        int padding = (int) (12 * getResources().getDisplayMetrics().density);
        mTargetRect = new RectF(
                location[0] - padding,
                location[1] - padding,
                location[0] + targetView.getWidth() + padding,
                location[1] + targetView.getHeight() + padding
        );

        invalidate();
        updateHintPosition();
    }

    public void setOnTargetClickListener(OnTargetClickListener listener) {
        mOnTargetClickListener = listener;
    }

    private void updateHintPosition() {
        if (mTargetRect == null) {
            return;
        }

        post(() -> {
            int screenWidth = getWidth();
            
            // 箭头右上角对齐设置按钮方框正下方居中，留出一定间距
            float arrowX = mTargetRect.centerX() - mIvArrow.getWidth();
            float arrowY = mTargetRect.bottom + 8 * getResources().getDisplayMetrics().density;

            mIvArrow.setX(arrowX);
            mIvArrow.setY(arrowY);

            // 提示文本在箭头左下角（箭头尖）的正下方
            // 箭头左下角 = 箭头X位置（也就是图片左边缘）
            int hintWidth = mTvHint.getWidth();
            float hintX = arrowX - hintWidth / 2f;
            float hintY = arrowY + mIvArrow.getHeight() + 8 * getResources().getDisplayMetrics().density;

            // 边界检查
            if (hintX < 20) {
                hintX = 20;
            }
            if (hintX + hintWidth > screenWidth - 20) {
                hintX = screenWidth - hintWidth - 20;
            }

            mTvHint.setX(hintX);
            mTvHint.setY(hintY);

            invalidate();
        });
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_UP) {
            float x = event.getX();
            float y = event.getY();

            if (mTargetRect != null && mTargetRect.contains(x, y)) {
                if (mOnTargetClickListener != null) {
                    mOnTargetClickListener.onTargetClick();
                }
                if (mTargetView != null) {
                    mTargetView.performClick();
                }
                dismiss();
                return true;
            } else {
                dismiss();
                return true;
            }
        }
        return super.onTouchEvent(event);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        if (mTargetRect != null) {
            int layerId = canvas.saveLayer(0, 0, getWidth(), getHeight(), null);

            canvas.drawRect(0, 0, getWidth(), getHeight(), mPaint);

            float cornerRadius = 12 * getResources().getDisplayMetrics().density;
            canvas.drawRoundRect(mTargetRect, cornerRadius, cornerRadius, mClearPaint);

            canvas.restoreToCount(layerId);

            canvas.drawRoundRect(mTargetRect, cornerRadius, cornerRadius, mBorderPaint);
        }
    }

    public void dismiss() {
        if (getParent() instanceof ViewGroup) {
            ((ViewGroup) getParent()).removeView(this);
        }
    }
}
