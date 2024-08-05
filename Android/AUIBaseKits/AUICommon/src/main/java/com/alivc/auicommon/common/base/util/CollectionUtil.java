package com.alivc.auicommon.common.base.util;

import com.alivc.auicommon.common.base.base.Function;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;

/**
 * @author puke
 * @version 2021/5/10
 */
public class CollectionUtil {

    public static <T> T getFirst(Collection<T> collection) {
        if (collection == null) {
            return null;
        } else {
            Iterator<T> iterator = collection.iterator();
            return iterator.hasNext() ? iterator.next() : null;
        }
    }

    public static <T> boolean isNotEmpty(Collection<T> collection) {
        return !isEmpty(collection);
    }

    public static <T> boolean isEmpty(Collection<T> collection) {
        return collection == null || collection.isEmpty();
    }

    public static <T> int size(Collection<T> collection) {
        return collection == null ? 0 : collection.size();
    }

    public static <T> int findIndex(List<T> list, Function<T, Boolean> condition) {
        int targetIndex = -1;
        for (int i = 0; i < list.size(); i++) {
            T model = list.get(i);
            if (condition.apply(model)) {
                targetIndex = i;
                break;
            }
        }
        return targetIndex;
    }
}
