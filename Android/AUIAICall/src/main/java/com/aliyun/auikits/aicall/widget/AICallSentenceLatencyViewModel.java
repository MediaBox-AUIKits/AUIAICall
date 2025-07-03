package com.aliyun.auikits.aicall.widget;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import java.util.ArrayList;
import java.util.List;

public class AICallSentenceLatencyViewModel extends ViewModel {
    private final MutableLiveData<List<AICallSentenceLatencyItem>> dataList = new MutableLiveData<>();

    public void updateData(List<AICallSentenceLatencyItem> newData) {
        dataList.postValue(newData);
    }

    public LiveData<List<AICallSentenceLatencyItem>> getDataList() {
        return dataList;
    }
}
