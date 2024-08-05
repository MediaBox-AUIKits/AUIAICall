package com.alivc.auicommon.common.base.util;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.alivc.auicommon.common.base.IClear;
import com.alivc.auicommon.common.base.IDestroyable;
import com.alivc.auicommon.common.base.IReset;
import com.alivc.auicommon.common.base.base.Consumer;
import com.alivc.auicommon.common.base.error.Errors;
import com.alivc.auicommon.common.base.exposable.Callback;
import com.alivc.auicommon.common.base.exposable.NegCallback;
import com.alivc.auicommon.common.base.exposable.PosCallback;

import java.lang.ref.Reference;
import java.lang.ref.WeakReference;
import java.util.Collection;
import java.util.Formatter;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;


/**
 * Created by KyleCe on 2021/5/27
 */
public class Utils {
//    Math begin

    public static int random(int max, int min) {
        return min + (int) (Math.random() * ((max - min) + 1));
    }

//    Math end

    public static <T, TE extends T, C extends Callback<T>> void callSuccess(Reference<C> callbackRef, TE t) {
        callSuccess(getRef(callbackRef), t);
    }

    public static <T, TE extends T, C extends Callback<T>> void callError(Reference<C> callbackRef, Object e) {
        callError(getRef(callbackRef), e);
    }

    public static <T, TE extends T, C extends Callback<T>> void callSuccess(@Nullable C callback, TE t) {
        if (callback != null) {
            callback.onSuccess(t);
        }
    }

    public static <T, TE extends T, C extends Callback<?>> void callError(@Nullable C callback, TE e) {
        if (callback != null) {
            callback.onError(string(e));
        }
    }

    public static <T, TE extends T, PC extends PosCallback<T>> void callSuccess(@Nullable PC callback, TE t) {
        if (callback != null) {
            callback.onSuccess(t);
        }
    }

    public static void callError(@Nullable NegCallback callback, Object e) {
        if (callback != null) {
            callback.onError(string(e));
        }
    }

    public static String string(Object e) {
        return e != null ? e.toString() : "[null]";
    }

    public static <P, CK extends Callback<P>> void invokeInvalidParamError(CK ck) {
        invokeError(ck, Errors.PARAM_ERROR);
    }

    public static <P, CK extends Callback<P>> void invokeError(CK ck, @NonNull Errors errors) {
        callError(ck, errors.getMessage());
    }

    public static String firstNotEmpty(String... strings) {
        for (String string : strings) {
            if (!TextUtils.isEmpty(string)) {
                return string;
            }
        }
        return null;
    }

    public static boolean isIndexOutOfRange(Integer i, Collection<?> col) {
        return !isIndexInRange(i, col);
    }

    public static <E> boolean isIndexOutOfRange(Integer i, E... es) {
        return !isIndexInRange(i, es);
    }

    public static boolean isIndexInRange(Integer i, Collection<?> col) {
        return i != null && isNotEmpty(col) && 0 <= i && i < col.size();
    }

    public static <E> boolean isIndexInRange(Integer i, E... es) {
        return i != null && isNotEmpty(es) && 0 <= i && i < es.length;
    }

    public static <E> void insertOrAppend(Integer index, List<E> col, E element) {
        if (Utils.isIndexInRange(index, col)) {
            col.add(index, element);
        } else {
            col.add(element);
        }
    }

    public static <E> void insertOrAppend(Integer index, List<E> col, Collection<? extends E> c) {
        if (Utils.isIndexInRange(index, col)) {
            col.addAll(index, c);
        } else {
            col.addAll(c);
        }
    }

    public static <E> int parseIndex(@Nullable E e, Collection<E> col) {
        if (e == null || isEmpty(col)) {
            return -1;
        }

        int i = 0;
        for (Iterator<E> iterator = col.iterator(); iterator.hasNext(); i++) {
            E ei = iterator.next();
            if (e.equals(ei)) {
                return i;
            }
        }

        return -1;
    }

    public static <E> int parseIndex(@Nullable E e, E... es) {
        if (e == null || isEmpty(es)) {
            return -1;
        }

        for (int i = 0; i < es.length; i++) {
            if (e.equals(es[i])) {
                return i;
            }
        }

        return -1;
    }

    public static boolean isEmpty(CharSequence str) {
        return isNull(str) || str.length() == 0;
    }

    public static boolean isNotEmpty(CharSequence str) {
        return !isEmpty(str);
    }

    public static boolean textIsAllEmpty(String... css) {
        if (css == null || css.length == 0) {
            return true;
        }
        for (CharSequence cs : css) {
            if (!TextUtils.isEmpty(cs)) {
                return false;
            }
        }
        return true;
    }

    public static boolean isEmpty(Object[] os) {
        return isNull(os) || os.length == 0;
    }

    public static boolean isNotEmpty(Object[] os) {
        return !isEmpty(os);
    }

    public static boolean isEmpty(Collection<?> c) {
        return isNull(c) || c.isEmpty();
    }

    public static void clear(Collection<?>... cs) {
        if (cs == null || cs.length == 0) {
            return;
        }

        for (Collection<?> c : cs) {
            if (isNull(c)) {
                continue;
            }
            c.clear();
        }
    }

    public static void clear(Map<?, ?>... ms) {
        if (ms == null || ms.length == 0) {
            return;
        }

        for (Map<?, ?> m : ms) {
            if (isEmpty(m)) {
                continue;
            }
            m.clear();
        }
    }

    public static int sizeOf(Collection<?> c) {
        return c != null ? c.size() : 0;
    }

    public static boolean isNotEmpty(Collection<?> c) {
        return !isEmpty(c);
    }

    public static boolean isEmpty(Map<?, ?> m) {
        return isNull(m) || m.isEmpty();
    }

    public static boolean isNotEmpty(Map<?, ?> m) {
        return !isEmpty(m);
    }

    public static boolean isNull(Object o) {
        return o == null;
    }

    public static boolean allNull(Object... os) {
        if (os == null || os.length == 0) {
            return true;
        }
        for (Object o : os) {
            if (o != null) {
                return false;
            }
        }
        return true;
    }

    public static boolean anyNull(Object... os) {
        return firstNull(os) != -1;
    }

    public static int firstNull(Object... os) {
        if (os == null || os.length == 0) {
            return -1;
        }
        for (int i = 0; i < os.length; i++) {
            Object o = os[i];
            if (o == null) {
                return i;
            }
        }
        return -1;
    }

    public static boolean nonNull(Object[] os) {
        if (os == null || os.length == 0) {
            return false;
        }
        for (Object o : os) {
            if (o == null) {
                return false;
            }
        }
        return true;
    }

    public static boolean noneEmpty(CharSequence... css) {
        if (css == null || css.length == 0) {
            return true;
        }

        for (CharSequence cs : css) {
            if (TextUtils.isEmpty(cs)) {
                return false;
            }
        }
        return true;
    }

    public static boolean anyEmpty(CharSequence... css) {
        if (css == null || css.length == 0) {
            return false;
        }

        for (CharSequence cs : css) {
            if (TextUtils.isEmpty(cs)) {
                return true;
            }
        }
        return false;
    }

    public static <E> E getSafely(Collection<E> col, Integer index) {
        if (index == null || isEmpty(col)) {
            return null;
        }

        if (isIndexOutOfRange(index, col)) {
            return null;
        }

        int i = 0;
        for (Iterator<E> iterator = col.iterator(); iterator.hasNext(); i++) {
            E e = iterator.next();
            if (index == i) {
                return e;
            }
        }

        return null;
    }

    @Nullable
    public static <E> E acceptFirstNonNull(@Nullable E... es) {
        if (isEmpty(es)) {
            return null;
        }
        for (E e : es) {
            if (e != null) {
                return e;
            }
        }

        return null;
    }

    @Nullable
    public static String acceptFirstNotEmpty(@Nullable CharSequence... es) {
        if (isEmpty(es)) {
            return null;
        }
        for (CharSequence e : es) {
            if (!TextUtils.isEmpty(e)) {
                return e.toString();
            }
        }

        return null;
    }

    @Nullable
    public static <E> E acceptFirstSuitable(@NonNull Checker<E> checker, @Nullable E... es) {
        if (allNull(es)) {
            return null;
        }
        for (E e : es) {
            if (checker.isSuitable(e)) {
                return e;
            }
        }

        return null;
    }

    public static void destroy(Object... ids) {
        if (isEmpty(ids)) {
            return;
        }

        for (Object d : ids) {
            if (d instanceof IDestroyable) {
                ((IDestroyable) d).destroy();
            }
        }
    }

    public static void reset(Object... ids) {
        if (isEmpty(ids)) {
            return;
        }

        for (Object d : ids) {
            if (d instanceof IReset) {
                ((IReset) d).reset();
            }
        }
    }

    public static void clear(Object... ics) {
        if (isEmpty(ics)) {
            return;
        }

        for (Object c : ics) {
            if (c == null) {
                continue;
            }
            if (c instanceof IClear) {
                ((IClear) c).clear();
            }
            if (c instanceof Map) {
                ((Map<?, ?>) c).clear();
            }
            if (c instanceof Collection) {
                ((Collection<?>) c).clear();
            }
            if (c instanceof Reference<?>) {
                ((Reference<?>) c).clear();
            }
            if (c instanceof Handler) {
                clear((Handler) c);
            }
            if (c instanceof ImageView) {
                clear((ImageView) c);
            }
        }
    }

    public static void clear(IClear... ics) {
        if (isEmpty(ics)) {
            return;
        }

        for (IClear c : ics) {
            if (c == null) {
                continue;
            }
            ((IClear) c).clear();
        }
    }

    public static void clear(Reference<?>... refs) {
        for (Reference<?> ref : refs) {
            if (ref != null) {
                ref.clear();
            }
        }
    }

    public static void clear(Handler... hs) {
        if (hs == null || hs.length == 0) {
            return;
        }
        for (Handler h : hs) {
            if (h != null) {
                h.removeCallbacksAndMessages(null);
            }
        }
    }

    public static <IV extends ImageView> void clear(IV... ivs) {
        if (ivs == null || ivs.length == 0) {
            return;
        }

        for (IV v : ivs) {
            if (v != null) {
                v.setImageDrawable(null);
                v.setImageResource(0);
            }
        }
    }

    public static void terminate(ExecutorService... ess) {
        if (isEmpty(ess)) {
            return;
        }

        for (ExecutorService es : ess) {
            try {
                if (es != null && !es.isShutdown() && !es.isTerminated()) {
                    es.shutdown();
                }
            } catch (Throwable ignore) {
            }
        }
    }

    public static void cancel(Future<?>... sfs) {
        cancel(true, sfs);
    }

    public static void cancel(boolean interrupt, Future<?>... sfs) {
        if (isEmpty(sfs)) {
            return;
        }

        for (Future<?> sf : sfs) {
            if (sf != null && !sf.isCancelled()) {
                sf.cancel(interrupt);
            }
        }
    }

    public static void shutDown(ExecutorService... ess) {
        if (isEmpty(ess)) {
            return;
        }

        for (ExecutorService es : ess) {
            if (es != null && !es.isShutdown()) {
                es.shutdownNow();
            }
        }
    }

    public static void invoke(View.OnClickListener listener, View... vs) {
        if (listener == null || vs == null || vs.length == 0) {
            return;
        }

        for (View view : vs) {
            if (view != null) {
                listener.onClick(view);
            }
        }
    }

    public static void run(WeakReference<Runnable> task) {
        run(task != null ? task.get() : null);
    }

    public static void run(Runnable task) {
        if (task != null) {
            task.run();
        }
    }

    public static <V> V call(WeakReference<Callable<V>> ref) {
        return call(ref != null ? ref.get() : null);
    }

    public static <V> V call(Callable<V> task) {
        if (task != null) {
            try {
                return task.call();
            } catch (Throwable ignore) {
            }
        }
        return null;
    }

    public static <V> void accept(WeakReference<Consumer<V>> ref, V v) {
        accept(ref != null ? ref.get() : null, v);
    }

    public static <V> void accept(Consumer<V> task, V v) {
        if (task != null) {
            try {
                task.accept(v);
            } catch (Throwable ignore) {
            }
        }
    }

    public static void runViaCondition(boolean condition, Runnable task) {
        if (condition && task != null) {
            task.run();
        }
    }

    public static void showDialogFragment(@Nullable FragmentActivity act, @Nullable DialogFragment df) {
        if (isActivityInvalid(act) || df == null) {
            return;
        }

        try {
            FragmentManager mgr = act.getSupportFragmentManager();
            df.show(mgr, df.getClass().getSimpleName());
        } catch (Throwable ignore) {
        }
    }

    public static void replaceWithFragment(FragmentActivity fragmentActivity, int id, Fragment fragment) {
        replaceWithFragment(fragmentActivity, id, fragment, "fragment-" + fragment.getClass().getSimpleName());
    }

    public static void replaceWithFragment(FragmentActivity fragmentActivity, int id, Fragment fragment, String tag) {
        if (isActivityInvalid(fragmentActivity) || id == 0 || fragment == null) {
            return;
        }

        try {
            FragmentManager fragMgr = fragmentActivity.getSupportFragmentManager();
            FragmentTransaction fragTransaction = fragMgr.beginTransaction();

            fragTransaction.replace(id, fragment, tag);
            fragTransaction.commit();
        } catch (Throwable ignore) {
        }
    }

    public static void toggleFragmentVisibility(FragmentActivity fragmentActivity, Fragment fragment, boolean trueForShowFalseForHide) {
        if (isActivityInvalid(fragmentActivity) || fragment == null || !fragment.isAdded()
                || fragment.isVisible() == trueForShowFalseForHide) {
            return;
        }

        try {
            FragmentManager fragMgr = fragmentActivity.getSupportFragmentManager();
            FragmentTransaction fragTransaction = fragMgr.beginTransaction();

            if (trueForShowFalseForHide) {
                fragTransaction.show(fragment);
            } else {
                fragTransaction.hide(fragment);
            }
            fragTransaction.commit();
        } catch (Throwable ignore) {
        }
    }

    public static boolean isContextActivityAndInvalid(Context context) {
        return context instanceof Activity && isActivityInvalid((Activity) context);
    }

    public static boolean isActivityInvalid(Reference<Activity> activityRef) {
        return isActivityInvalid(getRef(activityRef));
    }

    public static boolean isActivityInvalid(Activity activity) {
        return activity == null || activity.isFinishing() || activity.isDestroyed();
    }

    public static boolean isActivityValid(Activity activity) {
        return !isActivityInvalid(activity);
    }

    @Nullable
    public static <O> O getRef(@Nullable Reference<O> ref) {
        return ref != null ? ref.get() : null;
    }

    @Nullable
    public static <O> O getValid(List<O> list, int index) {
        if (isIndexInRange(index, list)) {
            return list.get(index);
        }
        return null;
    }

    public static String format(String format, Object... args) {
        return new Formatter(Locale.getDefault()).format(format, args).toString();
    }

    public static int hashCode(@Nullable Object obj) {
        return obj != null ? obj.hashCode() : -1;
    }

    public static void addLifeCycleObserver(@Nullable Object owner, @Nullable LifecycleObserver observer) {
        if (owner instanceof LifecycleOwner && observer != null) {
            ((LifecycleOwner) owner).getLifecycle().addObserver(observer);
        }
    }

    public static void removeLifeCycleObserver(@Nullable Object owner, @Nullable LifecycleObserver observer) {
        if (owner instanceof LifecycleOwner && observer != null) {
            ((LifecycleOwner) owner).getLifecycle().removeObserver(observer);
        }
    }

    public interface Checker<M> {
        boolean isSuitable(@Nullable M m);
    }
}
