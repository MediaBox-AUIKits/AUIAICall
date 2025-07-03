package com.aliyun.auikits.aicall.widget;

import java.util.Locale;

// 对话延迟列表项
public class AICallSentenceLatencyItem {
    private int sentenceId = -1;
    private long latency = 0;

    public AICallSentenceLatencyItem(int sentenceId, long latency) {
        this.sentenceId = sentenceId;
        this.latency = latency;
    }

    public int getSentenceId() {
        return sentenceId;
    }

    public void setSentenceId(int sentenceId) {
        this.sentenceId = sentenceId;
    }

    public void setLatency(long latency) {
        this.latency = latency;
    }

    public long getLatency() {
        return latency;
    }

    public String getLatencyStr() {
        return latency + "ms";
    }
}
