package com.aliyun.auikits.aicall.bean;

public class AudioToneData {
    private String mAudioToneId;
    private int mIconResId;
    private String mTitle;
    private boolean isUsing = false;

    public AudioToneData(String id, String title) {
        mAudioToneId = id;
        mTitle = title;
    }

    public void setTitle(String mTitle) {
        this.mTitle = mTitle;
    }

    public String getTitle() {
        return mTitle;
    }

    public void setIconResId(int mIconResId) {
        this.mIconResId = mIconResId;
    }

    public int getIconResId() {
        return mIconResId;
    }

    public void setUsing(boolean using) {
        isUsing = using;
    }

    public boolean isUsing() {
        return isUsing;
    }

    public String getAudioToneId() {
        return mAudioToneId;
    }
}
