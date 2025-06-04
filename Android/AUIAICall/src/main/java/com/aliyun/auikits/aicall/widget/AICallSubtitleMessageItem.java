package com.aliyun.auikits.aicall.widget;

// 字幕消息项
public class AICallSubtitleMessageItem {
    private boolean isAsrText;
    private int asrSentenceId;
    private long receiveTime;
    private String text;
    private long displayEndTime;

    public AICallSubtitleMessageItem() {
        this.asrSentenceId = 0;
        this.isAsrText = true;
        this.receiveTime = 0;
        this.text = "";
        this.displayEndTime = 0;
    }

    public AICallSubtitleMessageItem(boolean isAsrText, int asrSentenceId, long receiveTime, String text, long  displayEndTime) {
        this.isAsrText = isAsrText;
        this.asrSentenceId = asrSentenceId;
        this.receiveTime = receiveTime;
        this.text = text;
        this.displayEndTime = displayEndTime;

    }

    public int getAsrSentenceId() {
        return asrSentenceId;
    }

    public void setAsrSentenceId(int asrSentenceId) {
        this.asrSentenceId = asrSentenceId;
    }

    public boolean isAsrText() {
        return isAsrText;
    }

    public void setAsrText(boolean asrText) {
        isAsrText = asrText;
    }

    public long getReceiveTime() {
        return receiveTime;
    }

    public void setReceiveTime(long receiveTime) {
        this.receiveTime = receiveTime;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public long getDisplayEndTime() {
        return displayEndTime;
    }

    public void setDisplayEndTime(long displayEndTime) {
        this.displayEndTime = displayEndTime;
    }
}
