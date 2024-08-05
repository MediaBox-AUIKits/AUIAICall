package com.aliyun.auikits.aicall.base.feed;

/**
 * 内容抽象接口
 * @param <T>
 */
public interface IContentModel <T> {
    /**
     * 初始化接口
     * @param parameter 数据透传
     * @param callback 回调
     */
    void initData(BizParameter parameter, IBizCallback<T> callback);

    /**
     * 主动拉取型接口
     * @param isPullToRefresh true : Pull，  false : LoadMore
     * @param parameter 数据透传
     * @param callback 回调
     */
    void fetchData(boolean isPullToRefresh, BizParameter parameter, IBizCallback<T> callback);

    /**
     * 添加被动Push型数据监听器
     * @param contentObserver 监听器
     */
    void addContentObserver(IContentObserver<T> contentObserver);
    /**
     * 删除被动Push型接口监听器
     * @param contentObserver 监听器
     */
    void removeContentObserver(IContentObserver<T> contentObserver);

    /**
     * 释放
     */
    void release();
}
