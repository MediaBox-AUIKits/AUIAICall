package com.alivc.auimessage.helper;

import com.alivc.auicommon.common.base.util.ThreadUtil;

/**
 * 点赞辅助类 (用来优化点赞的频繁请求问题)
 *
 * @author puke
 * @version 2021/5/21
 */
public class LikeHelper {

    // 点赞请求的最少间隔时长
    private static final int MIN_REQUEST_INTERVAL = 2000;

    private final Callback callback;
    private boolean isReady;
    private int count;

    private final Runnable requestTask = new Runnable() {
        @Override
        public void run() {
            if (count <= 0) {
                // 边界条件, 无状态时, 忽略
                return;
            }

            // 暂存点赞数
            int likeCountTemp = count;

            // 内部状态清理
            count = 0;
            isReady = false;

            // 执行网络请求
            if (callback != null) {
                callback.onRequest(likeCountTemp);
            }
        }
    };

    public LikeHelper(Callback callback) {
        this.callback = callback;
    }

    /**
     * 用户每触发一次点赞, 调用一次
     */
    public void doLike() {
        // 点赞计数+1
        count++;

        // 已经准备发了, 就不再准备
        if (isReady) {
            return;
        }

        // 准备发送
        ThreadUtil.postDelay(MIN_REQUEST_INTERVAL, requestTask);

        // 记录准备发的状态
        isReady = true;
    }

    /**
     * 释放任务
     */
    public void release() {
        ThreadUtil.cancel(requestTask);
    }

    public interface Callback {
        void onRequest(int likeCount);
    }
}
