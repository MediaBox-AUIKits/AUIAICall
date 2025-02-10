package com.aliyun.auikits.aicall.base.feed;


import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.lifecycle.ViewModel;

import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.card.CardListAdapter;
import com.chad.library.adapter.base.listener.OnLoadMoreListener;

import java.util.List;

public class ContentViewModel extends ViewModel implements IContentObserver<CardEntity>{
    public static final String TAG = "ContentViewModel";
    public interface OnViewInflatedListener {
        void onViewInflated(View view);
    }

    public interface OnDataUpdateCallback {
        void onInitStart();
        void onInitEnd(boolean success, List<CardEntity> cardEntities);
        void onLoadMoreStart();
        void onLoadMoreEnd(boolean success, List<CardEntity> cardEntities);
    }

    private IContentModel<CardEntity> contentModel;
    private CardListAdapter cardListAdapter;
    private BizParameter bizParameter;
    private boolean enableLoadMore = true;
    private int emptyResId = 0;
    private int loadingResId = 0;
    private int errorResId = 0;
    private int errorRetryId = 0;
    private OnViewInflatedListener onErrorViewInflatedListener = null;
    private boolean hasInitData = false;
    private OnDataUpdateCallback onDataUpdateCallback = null;

    private ContentViewModel() {

    }

    public void bindView(CardListAdapter adapter) {
        this.cardListAdapter = adapter;
        if(this.enableLoadMore) {
            this.cardListAdapter.getLoadMoreModule().setLoadMoreView(new CustomLoadMoreView());
            this.cardListAdapter.getLoadMoreModule().setOnLoadMoreListener(new OnLoadMoreListener() {
                @Override
                public void onLoadMore() {
                    loadMore();
                }
            });
        }

        if(!hasInitData) {
            showLoading();
        }

        this.contentModel.addContentObserver(this);
        this.initData();
    }

    public void unBind() {
        this.contentModel.removeContentObserver(this);
        this.contentModel.release();
    }

    public void initData() {
        if(onDataUpdateCallback != null) {
            onDataUpdateCallback.onInitStart();
        }

        this.cardListAdapter.getLoadMoreModule().setEnableLoadMore(false);
        this.contentModel.initData(this.bizParameter, new IBizCallback<CardEntity>() {
            @Override
            public void onSuccess(List<CardEntity> data) {
                Log.v(TAG,  "init success");
                if(data.size() > 0) {
                    cardListAdapter.setList(data);
                } else {
                    cardListAdapter.getLoadMoreModule().loadMoreEnd();
                }
                initDataSuccess(data);
            }

            @Override
            public void onError(int code, String msg) {
                Log.v(TAG,  "init data error:" + code + ",msg:" + msg);
                initDataFailed();
            }
        });
    }

    private void showLoading() {
        if(loadingResId != 0) {
            this.cardListAdapter.setEmptyView(loadingResId);
        }
    }

    private void showEmptyView() {
        if(emptyResId != 0) {
            this.cardListAdapter.setEmptyView(emptyResId);
        }
    }

    private void showErrorView() {
        if(errorResId != 0) {
            this.cardListAdapter.setEmptyView(errorResId);
            FrameLayout frameLayout = this.cardListAdapter.getEmptyLayout();
            if(onErrorViewInflatedListener != null) {
                onErrorViewInflatedListener.onViewInflated(frameLayout);
            }

            if(errorRetryId != 0) {
                View retryView = frameLayout.findViewById(errorRetryId);

                retryView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        showLoading();
                        initData();
                    }
                });
            }

        }
    }



    private void initDataSuccess(List<CardEntity> data) {
        hasInitData = true;
        if(data.size() > 0) {
            ContentViewModel.this.cardListAdapter.getLoadMoreModule().setEnableLoadMore(ContentViewModel.this.enableLoadMore);
        } else {
            showEmptyView();
        }

        if(onDataUpdateCallback != null) {
            onDataUpdateCallback.onInitEnd(true, data);
        }

    }

    private void initDataFailed() {
        hasInitData = true;
        if(cardListAdapter.getData().size() > 0) {
            ContentViewModel.this.cardListAdapter.getLoadMoreModule().setEnableLoadMore(ContentViewModel.this.enableLoadMore);
        } else {
            showErrorView();
        }

        if(onDataUpdateCallback != null) {
            onDataUpdateCallback.onInitEnd(false, null);
        }
    }

    public void loadMore() {
        if(onDataUpdateCallback != null) {
            onDataUpdateCallback.onLoadMoreStart();
        }
        this.contentModel.fetchData(false, this.bizParameter, new IBizCallback<CardEntity>() {
            @Override
            public void onSuccess(List<CardEntity> data) {
                Log.v(TAG,  "fetch success");
                if(data.size() > 0) {
                    cardListAdapter.addData(data);
                    cardListAdapter.getLoadMoreModule().loadMoreComplete();
                } else {
                    cardListAdapter.getLoadMoreModule().loadMoreEnd();
                }

                if(onDataUpdateCallback != null) {
                    onDataUpdateCallback.onLoadMoreEnd(true, data);
                }

            }

            @Override
            public void onError(int code, String msg) {
                Log.v(TAG,  "fetch data error:" + code + ",msg:" + msg);
                cardListAdapter.getLoadMoreModule().loadMoreFail();
                if(onDataUpdateCallback != null) {
                    onDataUpdateCallback.onLoadMoreEnd(false, null);
                }
            }
        });
    }

    @Override
    public void onContentUpdate(List<CardEntity> data) {
        cardListAdapter.setList(data);
    }

    @Override
    public void onContentInsert(List<CardEntity> data) {
        cardListAdapter.addData(data);
    }

    @Override
    public void onContentHeaderInsert(List<CardEntity> data) {
        cardListAdapter.addData(0, data);
    }

    @Override
    public void onContentRemove(List<CardEntity> dataList) {
        for(CardEntity entity : dataList) {
            cardListAdapter.remove(entity);
        }
    }

    @Override
    public void onContentUpdate(CardEntity data, int position) {
        cardListAdapter.setData(position, data);
    }


    public static class Builder {
        private boolean loadMoreEnable = true;
        private BizParameter bizParameter;
        private IContentModel<CardEntity> contentModel;
        private int emptyResId;
        private int loadingResId;
        private int errorResId;
        private int errorRetryId;
        private OnViewInflatedListener onErrorViewInflatedListener;
        private OnDataUpdateCallback onDataUpdateCallback;


        public Builder setLoadMoreEnable(boolean loadMoreEnable) {
            this.loadMoreEnable = loadMoreEnable;
            return this;
        }

        public Builder setBizParameter(BizParameter bizParameter) {
            this.bizParameter = bizParameter;
            return this;
        }

        public Builder setContentModel(IContentModel<CardEntity> contentModel) {
            this.contentModel = contentModel;
            return this;
        }

        /**
         * 设置空数据页面
         * @param resId 空数据页面的resId
         * @return
         */
        public Builder setEmptyView(int resId) {
            this.emptyResId = resId;
            return this;
        }

        /**
         * 设置Loading页面
         * @param resId Loading页面的resId
         * @return
         */
        public Builder setLoadingView(int resId) {
            this.loadingResId = resId;
            return this;
        }

        /**
         * 设置错误页面
         * @param resId 错误页面的resId
         * @param retryId 重试控件的id，没有的话直接填0
         * @return
         */
        public Builder setErrorView(int resId, int retryId) {
            this.errorResId = resId;
            this.errorRetryId = retryId;
            return this;
        }

        /**
         * 设置错误页面
         * @param resId 错误页面的resId
         * @param onViewInflatedListener 错误页面显示后会回调该接口，可以设置点击事件
         * @return
         */
        public Builder setErrorView(int resId, OnViewInflatedListener onViewInflatedListener) {
            this.errorResId = resId;
            this.onErrorViewInflatedListener = onViewInflatedListener;
            return this;
        }

        /**
         * 设置数据回调
         * @param onDataUpdateCallback 数据回调
         * @return
         */
        public Builder setOnDataUpdateCallback(OnDataUpdateCallback onDataUpdateCallback) {
            this.onDataUpdateCallback = onDataUpdateCallback;
            return this;
        }

        public ContentViewModel build() {
            ContentViewModel contentViewModel = new ContentViewModel();
            contentViewModel.contentModel = this.contentModel;
            contentViewModel.bizParameter = this.bizParameter;
            contentViewModel.enableLoadMore = this.loadMoreEnable;
            contentViewModel.emptyResId = this.emptyResId;
            contentViewModel.loadingResId = this.loadingResId;
            contentViewModel.errorResId = this.errorResId;
            contentViewModel.errorRetryId = this.errorRetryId;
            contentViewModel.onErrorViewInflatedListener = this.onErrorViewInflatedListener;
            contentViewModel.onDataUpdateCallback = this.onDataUpdateCallback;
            return contentViewModel;
        }
    }

}
