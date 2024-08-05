package com.alivc.auimessage.observable;

/**
 * @author puke
 * @version 2022/8/26
 */
public interface IObservable<T> {

    /**
     * 注册观察者
     *
     * @param observer 观察者对象
     */
    void register(T observer);

    /**
     * 取消注册观察者
     *
     * @param observer 观察者对象
     */
    void unregister(T observer);

    /**
     * 取消注册所有的观察者
     */
    void unregisterAll();
}
