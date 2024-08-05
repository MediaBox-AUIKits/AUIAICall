package com.aliyun.auikits.aicall.demo;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class DebugInfoListAdapter extends BaseAdapter {
    private final WeakReference<Context> wref;
    private List<String> debugInfos = new ArrayList<>();

    public DebugInfoListAdapter(Context ctx){
        wref = new WeakReference<>(ctx);
    }

    public void addInfo(String info){
        debugInfos.add(info);
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return debugInfos.size();
    }

    @Override
    public Object getItem(int position) {
        if(position >= debugInfos.size()) return null;
        return debugInfos.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Context ctx = wref.get();
        if(ctx == null) return convertView;
        if(convertView == null){
            convertView = LayoutInflater.from(ctx).inflate(R.layout.info_item, parent, false);
        }
        TextView info = convertView.findViewById(R.id.info);
        info.setText(debugInfos.get(position));
        return convertView;
    }
}
