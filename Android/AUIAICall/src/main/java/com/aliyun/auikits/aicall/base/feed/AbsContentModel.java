package com.aliyun.auikits.aicall.base.feed;


import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public abstract class AbsContentModel<T> implements IContentModel<T> {
    protected CopyOnWriteArrayList<IContentObserver<T>> observers = new CopyOnWriteArrayList<>();

    @Override
    public void addContentObserver(IContentObserver<T> contentObserver) {
        observers.add(contentObserver);
    }

    @Override
    public void removeContentObserver(IContentObserver<T> contentObserver) {
        observers.remove(contentObserver);
    }

    @Override
    public void release() {

    }

    protected void insertContent(List<T> dataList) {
        for(IContentObserver<T> o : observers) {
            o.onContentInsert(dataList);
        }
    }

    protected void insertContentHeader(List<T> dataList) {
        for(IContentObserver<T> o : observers) {
            o.onContentHeaderInsert(dataList);
        }
    }


    protected void updateContent(List<T> dataList) {
        for(IContentObserver<T> o : observers) {
            o.onContentUpdate(dataList);
        }
    }

    protected void updateContent(T data , int pos) {
        for(IContentObserver<T> o : observers) {
            o.onContentUpdate(data, pos);
        }
    }

    protected void removeContent(List<T> dataList) {
        for(IContentObserver<T> o : observers) {
            o.onContentRemove(dataList);
        }
    }
}
