package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.bean.AUIAICallAgentScenario;

import java.util.List;

public class AUIAICallAgentScenarioAdapter extends RecyclerView.Adapter<AUIAICallAgentScenarioAdapter.ViewHolder> {

    private Context mContext;
    private List<AUIAICallAgentScenario> mScenarios;
    private int mSelectedPosition = 0;
    
    private static final String DEFAULT_COLOR_TOKEN = "DEFAULT";

    public AUIAICallAgentScenarioAdapter(Context context, List<AUIAICallAgentScenario> scenarios) {
        this.mContext = context;
        this.mScenarios = scenarios;
        for (int i = 0; i < scenarios.size(); i++) {
            if (scenarios.get(i).isSelected()) {
                mSelectedPosition = i;
                break;
            }
        }
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.item_aicall_scenario, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        AUIAICallAgentScenario scenario = mScenarios.get(position);
        
        holder.tvScenarioName.setText(scenario.getScenarioName());
        holder.tvAsrModel.setText("• ASR " + scenario.getAsrModel());
        holder.tvTtsModel.setText("• TTS " + scenario.getTtsModel());
        
        // 优先显示 JSON 中的 name，没有则回退到 voice_id
        String voiceDisplayName = scenario.getVoiceName();
        if (TextUtils.isEmpty(voiceDisplayName)) {
            voiceDisplayName = scenario.getVoiceId();
        }
        holder.tvAgentId.setText("• " + mContext.getString(R.string.aicall_scenario_voice_id) + " " + (TextUtils.isEmpty(voiceDisplayName) ? "-" : voiceDisplayName));
        
        holder.tvTag1.setBackgroundResource(R.drawable.bg_aicall_scenario_tag1);
        holder.tvTag2.setBackgroundResource(R.drawable.bg_aicall_scenario_tag2);
        holder.tvTag1.setTextColor(Color.WHITE);
        holder.tvTag2.setTextColor(Color.WHITE);
        
        if (!TextUtils.isEmpty(scenario.getTags())) {
            String[] tagNames = scenario.getTags().trim().split("\\s+");
            
            String[] tagFgColors = null;
            if (!TextUtils.isEmpty(scenario.getTagFgColors())) {
                tagFgColors = scenario.getTagFgColors().trim().split("\\s+");
            }
            
            String[] tagBgColors = null;
            if (!TextUtils.isEmpty(scenario.getTagBgColors())) {
                tagBgColors = scenario.getTagBgColors().trim().split("\\s+");
            }
            
            holder.tvTag1.setVisibility(View.GONE);
            holder.tvTag2.setVisibility(View.GONE);
            
            if (tagNames.length > 0 && !TextUtils.isEmpty(tagNames[0])) {
                holder.tvTag1.setVisibility(View.VISIBLE);
                holder.tvTag1.setText(tagNames[0]);
                applyTagColors(holder.tvTag1,
                        getColorTokenByIndex(tagFgColors, 0),
                        getColorTokenByIndex(tagBgColors, 0));
            }
            if (tagNames.length > 1 && !TextUtils.isEmpty(tagNames[1])) {
                holder.tvTag2.setVisibility(View.VISIBLE);
                holder.tvTag2.setText(tagNames[1]);
                applyTagColors(holder.tvTag2,
                        getColorTokenByIndex(tagFgColors, 1),
                        getColorTokenByIndex(tagBgColors, 1));
            }
        } else {
            holder.tvTag1.setVisibility(View.GONE);
            holder.tvTag2.setVisibility(View.GONE);
        }

        boolean isSelected = position == mSelectedPosition;
        updateItemSelection(holder, isSelected);

        holder.itemView.setOnClickListener(v -> {
            int oldPosition = mSelectedPosition;
            mSelectedPosition = holder.getAdapterPosition();
            
            mScenarios.get(oldPosition).setSelected(false);
            mScenarios.get(mSelectedPosition).setSelected(true);
            
            notifyItemChanged(oldPosition);
            notifyItemChanged(mSelectedPosition);
        });
    }

    private void updateItemSelection(ViewHolder holder, boolean isSelected) {
        if (isSelected) {
            holder.itemView.setBackgroundResource(R.drawable.bg_aicall_scenario_item_selected);
        } else {
            holder.itemView.setBackgroundResource(R.drawable.bg_aicall_scenario_item);
        }
    }
    
    private String getColorTokenByIndex(String[] colors, int index) {
        if (colors == null || index < 0 || index >= colors.length) {
            return null;
        }
        String value = colors[index];
        if (TextUtils.isEmpty(value) || DEFAULT_COLOR_TOKEN.equalsIgnoreCase(value)) {
            return null;
        }
        return value;
    }
    
    private void applyTagColors(TextView tv, String fgColor, String bgColor) {
        if (!TextUtils.isEmpty(fgColor)) {
            try {
                tv.setTextColor(Color.parseColor(fgColor));
            } catch (IllegalArgumentException ignored) {
            }
        }
        
        if (!TextUtils.isEmpty(bgColor)) {
            try {
                int colorInt = Color.parseColor(bgColor);
                GradientDrawable drawable = new GradientDrawable();
                drawable.setShape(GradientDrawable.RECTANGLE);
                float radius = tv.getResources().getDisplayMetrics().density * 4f;
                drawable.setCornerRadius(radius);
                drawable.setColor(colorInt);
                tv.setBackground(drawable);
            } catch (IllegalArgumentException ignored) {
            }
        }
    }

    @Override
    public int getItemCount() {
        return mScenarios != null ? mScenarios.size() : 0;
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvScenarioName;
        TextView tvAsrModel;
        TextView tvTtsModel;
        TextView tvAgentId;
        TextView tvTag1;
        TextView tvTag2;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvScenarioName = itemView.findViewById(R.id.tv_scenario_name);
            tvAsrModel = itemView.findViewById(R.id.tv_asr_model);
            tvTtsModel = itemView.findViewById(R.id.tv_tts_model);
            tvAgentId = itemView.findViewById(R.id.tv_agent_id);
            tvTag1 = itemView.findViewById(R.id.tv_tag1);
            tvTag2 = itemView.findViewById(R.id.tv_tag2);
        }
    }
}
