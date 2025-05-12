package com.aliyun.auikits.aicall.base.card;


import android.os.Handler;
import android.os.Looper;
import android.util.SparseArray;
import android.view.ViewGroup;
import android.view.View;

import androidx.annotation.NonNull;

import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.widget.card.ChatBotSendTextMessageCard;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.module.LoadMoreModule;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.alivc.auicommon.common.base.util.ThreadUtil;


public class CardListAdapter extends BaseQuickAdapter<CardEntity, BaseViewHolder> implements LoadMoreModule {
    private ICardViewFactory cardViewFactory;
    private SparseArray<String> cardTypeIntArray;
    private int lastScrollPosition = 0;
    private boolean autoScrollToBottom = true;
    private OnItemLongClickListener onItemLongClickListener;

    public interface OnItemLongClickListener {
        void onItemLongClick(View view, int position);
    }

    public CardListAdapter(ICardViewFactory cardViewFactory) {
        super(0);
        this.cardViewFactory = cardViewFactory;
        this.cardTypeIntArray = new SparseArray<>();
    }

    public CardListAdapter(ICardViewFactory cardViewFactory, OnItemLongClickListener onItemLongClickListener) {
        super(0);
        this.cardViewFactory = cardViewFactory;
        this.cardTypeIntArray = new SparseArray<>();
        this.onItemLongClickListener = onItemLongClickListener;
    }

    public void setAutoScrollToBottom(boolean autoScrollToBottom) {
        this.autoScrollToBottom = autoScrollToBottom;
    }

    public void smoothScrollToBottom(RecyclerView recyclerView, boolean fource) {
        if (recyclerView.getLayoutManager() instanceof LinearLayoutManager) {
            int lastItemPosition = getItemCount() -1 ;

            if(lastItemPosition == -1) {
                return;
            }

            if(lastScrollPosition != lastItemPosition || fource) {
                lastScrollPosition = lastItemPosition;

                new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        Logger.i("scrollToBottom to " + lastItemPosition);
                        recyclerView.smoothScrollToPosition(lastItemPosition);
                    }
                }, 200);
            }
            //((LinearLayoutManager) recyclerView.getLayoutManager()).scrollToPositionWithOffset(lastItemPosition, 100);
        }
    }

    public void scrollToBottom(RecyclerView recyclerView) {
        if (recyclerView.getLayoutManager() instanceof LinearLayoutManager) {
            int position = getItemCount() -1 ;
            if(position == -1) {
                return;
            }
            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                @Override
                public void run() {
                    Logger.i("scrollToBottom to " + position);
                    //recyclerView.scrollToPosition(position);
                    scrollToPositionBottom(recyclerView, position);
                }
            }, 10);
        }
    }

    protected BaseViewHolder onCreateDefViewHolder(@NonNull ViewGroup parent, int viewType) {
        BaseCard card = cardViewFactory.createCardView(parent.getContext(), parent, cardTypeIntArray.get(viewType));
//        card.setLayoutParams(new RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.WRAP_CONTENT));
        return createBaseViewHolder(card);
    }

    @Override
    public void onBindViewHolder(BaseViewHolder holder, int position) {
        super.onBindViewHolder(holder, position);

        if(holder.itemView instanceof ChatBotSendTextMessageCard) {
            ((ChatBotSendTextMessageCard)holder.itemView).setOnMessageItemLongClickListener(new ChatBotSendTextMessageCard.OnMessageItemLongClickListener() {
                @Override
                public void onMessageItemLongClick() {
                    if(onItemLongClickListener != null) {
                        onItemLongClickListener.onItemLongClick(holder.itemView, position);
                    }
                }
            });
        }

        if(autoScrollToBottom) {
            if (position == getItemCount() - 1) {
                // 监听最后一个item的布局变化，然后滚动到最底部
                holder.itemView.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
                    @Override
                    public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                        if (bottom != oldBottom) { // implies a height change
                            scrollToPositionBottom(getRecyclerView(), position);
                            v.removeOnLayoutChangeListener(this);
                        }
                    }
                });
            }
        }
    }

    private void scrollToPositionBottom(RecyclerView recyclerView, int position) {
        ThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                RecyclerView.ViewHolder viewHolder = recyclerView.findViewHolderForAdapterPosition(position);
                if (viewHolder != null && viewHolder.itemView != null) {
                    int offset = recyclerView.getHeight() - viewHolder.itemView.getHeight();
                    ((LinearLayoutManager) recyclerView.getLayoutManager()).scrollToPositionWithOffset(position, offset);
                } else {
                    recyclerView.scrollToPosition(position);
                    recyclerView.post(() -> {
                        RecyclerView.ViewHolder vh = recyclerView.findViewHolderForAdapterPosition(position);
                        if (vh != null && vh.itemView != null) {
                            int off = recyclerView.getHeight() - vh.itemView.getHeight();
                            ((LinearLayoutManager) recyclerView.getLayoutManager()).scrollToPositionWithOffset(position, off);
                        }
                    });
                }
            }
        });
    }

    public void onViewRecycled(BaseViewHolder holder) {
        if(holder.itemView instanceof BaseCard) {
            ((BaseCard)holder.itemView).onUnBind();
        }

    }

    @Override
    protected void convert(@NonNull BaseViewHolder helper, CardEntity item) {
        if(helper.itemView instanceof BaseCard) {
            ((BaseCard) helper.itemView).onBind(item);
        }
    }

    @Override
    public int getDefItemViewType(int position) {
        CardEntity cardEntity = getData().get(position);
        int cardTypeInt = cardEntity.cardType.hashCode();
        cardTypeIntArray.put(cardTypeInt, cardEntity.cardType);
        return cardTypeInt;
    }
}
