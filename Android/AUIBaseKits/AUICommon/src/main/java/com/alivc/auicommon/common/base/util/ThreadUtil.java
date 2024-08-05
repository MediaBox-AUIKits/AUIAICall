package com.alivc.auicommon.common.base.util;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.log.Logger;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author puke
 * @version 2020/12/23
 */
public class ThreadUtil {

    private static final String TAG = ThreadUtil.class.getName();

    private static final ThreadPoolExecutor THREAD_POOL_EXECUTOR;
    private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
    private static final int CORE_POOL_SIZE = Math.max(2, Math.min(CPU_COUNT - 1, 4));
    private static final int MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1;
    private static final int KEEP_ALIVE_SECONDS = 30;

    private static final long DEFAULT_LATCH_TIMEOUT_DURATION_IN_SECONDS = 10;

    private static final BlockingQueue<Runnable> POOL_WORK_QUEUE =
            new LinkedBlockingQueue<>(128);
    private static final Object sSesLock = new Object();
    private static final ThreadFactory THREAD_FACTORY = new ThreadFactory() {
        private final AtomicInteger mCount = new AtomicInteger(1);

        @Override
        public Thread newThread(Runnable r) {
            return new Thread(r, "ThreadUtils #" + mCount.getAndIncrement());
        }
    };
    private static final Handler UI_HANDLER = new Handler(Looper.getMainLooper());
    private static ScheduledExecutorService sScheduledES;

    static {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
                CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_SECONDS, TimeUnit.SECONDS,
                POOL_WORK_QUEUE, THREAD_FACTORY);
        threadPoolExecutor.allowCoreThreadTimeOut(true);
        THREAD_POOL_EXECUTOR = threadPoolExecutor;
    }

    public static boolean isMainThread() {
        return Looper.myLooper() == Looper.getMainLooper();
    }

    public static void runOnUiThread(@Nullable Runnable task) {
        if (task == null) {
            return;
        }
        if (isMainThread()) {
            task.run();
        } else {
            UI_HANDLER.post(task);
        }
    }

    public static void postToUiThread(@Nullable Runnable task) {
        if (task == null) {
            return;
        }
        UI_HANDLER.post(task);
    }

    public static void postUiDelay(long delayMillis, Runnable runnable) {
        postDelay(delayMillis, runnable);
    }

    public static void postDelay(long delayMillis, Runnable runnable) {
        if (runnable == null) {
            return;
        }
        UI_HANDLER.postDelayed(runnable, delayMillis);
    }

    public static void cancel(Runnable runnable) {
        UI_HANDLER.removeCallbacks(runnable);
    }

    public static void runOnSubThread(Runnable runnable) {
        if (THREAD_POOL_EXECUTOR.getQueue().size() == 128 || THREAD_POOL_EXECUTOR.isShutdown()) {
            Logger.e(TAG, "线程池爆满警告，请查看是否开启了过多的耗时线程");
            return;
        }
        THREAD_POOL_EXECUTOR.execute(runnable);
    }

    public static void bindActionWithLatch(@NonNull CountDownLatch latch, @NonNull Runnable passAction) {
        bindActionWithLatchWithTimeOut(latch, passAction, DEFAULT_LATCH_TIMEOUT_DURATION_IN_SECONDS);
    }

    public static void bindActionWithLatchWithoutTimeOut(@NonNull CountDownLatch latch, @NonNull Runnable passAction) {
        bindActionWithLatchWithTimeOut(latch, passAction, -1);
    }

    public static void bindActionWithLatchWithTimeOut(@NonNull final CountDownLatch latch, @NonNull final Runnable passAction, final long timeOutDurationInSeconds) {
        runOnSubThread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (timeOutDurationInSeconds > 0) {
                        latch.await(timeOutDurationInSeconds, TimeUnit.SECONDS);
                    } else {
                        latch.await();
                    }
                } catch (Throwable ignore) {
                }

                passAction.run();
            }
        });
    }

    public static ScheduledFuture<?> schedule(Runnable command,
                                              long delay, TimeUnit unit) {
        try {
            return ofScheduledExecutor().schedule(command, delay, unit);
        } catch (Throwable ignore) {
            return null;
        }
    }

    public static ScheduledFuture<?> scheduleAtFixedRate(Runnable runnable,
                                                         long initialDelay,
                                                         long period,
                                                         TimeUnit unit) {
        try {
            return ofScheduledExecutor().scheduleAtFixedRate(runnable, initialDelay, period, unit);
        } catch (Throwable ignore) {
            return null;
        }
    }

    public static ScheduledFuture<?> scheduleWithFixedDelay(Runnable runnable,
                                                            long initialDelay,
                                                            long delay,
                                                            TimeUnit unit) {
        try {
            return ofScheduledExecutor().scheduleWithFixedDelay(runnable, initialDelay, delay, unit);
        } catch (Throwable ignore) {
            return null;
        }
    }

    private static ScheduledExecutorService ofScheduledExecutor() {
        if (sScheduledES == null) {
            synchronized (sSesLock) {
                if (sScheduledES == null) {
                    sScheduledES = Executors.newSingleThreadScheduledExecutor();
                }
            }
        }
        return sScheduledES;
    }
}
