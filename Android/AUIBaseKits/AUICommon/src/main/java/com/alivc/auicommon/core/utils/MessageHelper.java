package com.alivc.auicommon.core.utils;

import android.os.Handler;
import android.os.Looper;

import java.util.ArrayList;
import java.util.List;

/**
 * 弹幕消息辅助类<hr>
 *
 * @author puke
 * @version 2021/9/17
 */
public class MessageHelper<M> {

    private static final String TAG = MessageHelper.class.getSimpleName();
    private static final Handler HANDLER = new Handler(Looper.getMainLooper());
    // 最大消息总数
    private static final int DEFAULT_MAX_SIZE_FOR_TOTAL = 200;
    // 达到最大消息数时, 建议移除的消息比例
    private static final float SUGGEST_REMOVE_RATE_WHEN_LIMIT = 1 / 3f;
    // 消息队列
    protected final List<M> bufferQueue = new ArrayList<>();
    private int maxSizeForTotal = DEFAULT_MAX_SIZE_FOR_TOTAL;

    private Callback<M> callback;
    private boolean isRunning;
    private final Runnable consumeTask = new Runnable() {
        @Override
        public void run() {
            if (!isRunning) {
                return;
            }

            if (bufferQueue.isEmpty()) {
                isRunning = false;
            } else {
                M message = bufferQueue.remove(0);
                if (callback != null) {
                    callback.onMessageAdded(message);
                }
                int intervalMs = getAdjustMessageInterval();
                if (intervalMs == 0) {
                    run();
                } else {
                    HANDLER.postDelayed(this, intervalMs);
                }
            }
        }
    };

    public MessageHelper<M> setMaxSizeForTotal(int maxSizeForTotal) {
        this.maxSizeForTotal = maxSizeForTotal;
        return this;
    }

    public MessageHelper<M> setCallback(Callback<M> callback) {
        this.callback = callback;
        return this;
    }

    public void addMessage(M message) {
        bufferQueue.add(message);

        // 超出最大值时, 做移除操作
        removeIfLimit();

        if (!isRunning) {
            isRunning = true;
            consumeTask.run();
        }
    }

    /**
     * 获取动态自适应的消息间隔 <br>
     */
    protected int getAdjustMessageInterval() {
        int bufferSize = bufferQueue.size();
        if (bufferSize <= 2) {
            return 400;
        } else if (bufferSize <= 5) {
            return 200;
        } else if (bufferSize <= 10) {
            return 100;
        } else if (bufferSize <= 20) {
            return 50;
        } else if (bufferSize <= 100) {
            return 10;
        } else if (bufferSize <= 200) {
            return 50;
        } else {
            return 0;
        }
    }

    protected void removeIfLimit() {
        if (callback != null) {
            int totalSize = callback.getTotalSize();
            if (totalSize > maxSizeForTotal) {
                int suggestRemoveCount = (int) (maxSizeForTotal * SUGGEST_REMOVE_RATE_WHEN_LIMIT);
                callback.onMessageRemoved(suggestRemoveCount);
            }
        }
    }

    public void destroy() {
        isRunning = false;
        HANDLER.removeCallbacks(consumeTask);
    }

    public interface Callback<M> {
        int getTotalSize();

        void onMessageAdded(M message);

        void onMessageRemoved(int suggestRemoveCount);
    }
}
