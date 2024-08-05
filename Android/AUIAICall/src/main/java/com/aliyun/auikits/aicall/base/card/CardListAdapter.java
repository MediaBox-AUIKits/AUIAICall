package com.aliyun.auikits.aicall.base.card;


import android.util.SparseArray;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.module.LoadMoreModule;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;


public class CardListAdapter extends BaseQuickAdapter<CardEntity, BaseViewHolder> implements LoadMoreModule {
    private ICardViewFactory cardViewFactory;
    private SparseArray<String> cardTypeIntArray;

    public CardListAdapter(ICardViewFactory cardViewFactory) {
        super(0);
        this.cardViewFactory = cardViewFactory;
        this.cardTypeIntArray = new SparseArray<>();
    }

    protected BaseViewHolder onCreateDefViewHolder(@NonNull ViewGroup parent, int viewType) {
        BaseCard card = cardViewFactory.createCardView(parent.getContext(), parent, cardTypeIntArray.get(viewType));
//        card.setLayoutParams(new RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.WRAP_CONTENT));
        return createBaseViewHolder(card);
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
