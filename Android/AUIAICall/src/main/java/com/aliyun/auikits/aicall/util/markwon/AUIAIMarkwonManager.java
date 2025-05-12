package com.aliyun.auikits.aicall.util.markwon;
import android.content.Context;
import android.graphics.Color;
import android.text.TextPaint;
import android.text.style.AbsoluteSizeSpan;
import android.util.TypedValue;
import android.view.View;

import android.text.style.ClickableSpan;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;


import org.commonmark.node.Heading;
import org.commonmark.node.Image;
import org.commonmark.node.Link;

import io.noties.markwon.Markwon;
import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.SpanFactory;
import io.noties.markwon.core.CoreProps;
import io.noties.markwon.image.AsyncDrawableSpan;
import io.noties.markwon.image.ImageProps;
import io.noties.markwon.image.glide.GlideImagesPlugin;
import io.noties.markwon.MarkwonSpansFactory;
import io.noties.markwon.AbstractMarkwonPlugin;

import io.noties.markwon.RenderProps;

public class AUIAIMarkwonManager {
    // 单例实例
    private static AUIAIMarkwonManager instance;

    // Markwon 实例
    private final Markwon markwon;

    private AUIAIMarkwonManagerCallback callback;


    public interface AUIAIMarkwonManagerCallback {
         void onLinkClicked(String url, boolean isLinkUrl) ;
    }

    /**
     * 私有构造函数，防止外部实例化
     */
    private AUIAIMarkwonManager(Context context) {
        // 初始化 Markwon 实例
        this.markwon = Markwon.builder(context)
                .usePlugin(GlideImagesPlugin.create(context))
                .usePlugin(new AbstractMarkwonPlugin() {
                    @Override
                    public void configureSpansFactory(@NonNull MarkwonSpansFactory.Builder builder) {

                        // 获取默认的Image Span工厂
                        final SpanFactory original = builder.getFactory(Image.class);
                        if (original == null) return;

                        builder.setFactory(Heading.class, new SpanFactory() {
                            @Nullable
                            @Override
                            public Object getSpans(@NonNull MarkwonConfiguration configuration, @NonNull RenderProps props) {
                                int level = CoreProps.HEADING_LEVEL.get(props);
                                int sizePx;
                                switch (level) {
                                    case 1:
                                        sizePx = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, 24, context.getResources().getDisplayMetrics());
                                        break;
                                    case 2:
                                        sizePx = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, 22, context.getResources().getDisplayMetrics());
                                        break;
                                    case 3:
                                        sizePx = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, 20, context.getResources().getDisplayMetrics());
                                        break;
                                    case 4:
                                        sizePx = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, 18, context.getResources().getDisplayMetrics());
                                        break;
                                    case 5:
                                        sizePx = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, 16, context.getResources().getDisplayMetrics());
                                        break;
                                    case 6:
                                    default:
                                        sizePx = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, 14, context.getResources().getDisplayMetrics());
                                        break;
                                }
                                return new CustomAbsoluteSizeSpan(sizePx);
                            }
                        });

                        builder.setFactory(Link.class, new SpanFactory() {
                            @Nullable
                            @Override
                            public Object getSpans(@NonNull MarkwonConfiguration configuration, @NonNull RenderProps props) {
                                return new CustomLinkSpan(CoreProps.LINK_DESTINATION.require(props));
                            }
                        });

                        builder.setFactory(Image.class, (configuration, props) -> {
                            // 生成原始ImageSpan（由GlideImagesPlugin处理）
                            Object originalSpans = original.getSpans(configuration, props);
                            if (originalSpans instanceof AsyncDrawableSpan) {
                                AsyncDrawableSpan imageSpan = (AsyncDrawableSpan) originalSpans;
                                String source = props.get(ImageProps.DESTINATION);

                                // 创建可点击的Span（结合ImageSpan和ClickableSpan）
                                ClickableSpan clickableSpan = AUIAIMarkwonClickableImageSpan.createClickableSpan(
                                        source,
                                        imageUrl -> {
                                            // 处理点击事件
                                            if(callback != null) {
                                                callback.onLinkClicked(imageUrl, false);
                                            }
                                        }
                                );

                                // 返回多个Span：原始图片Span和点击Span
                                return new Object[] { imageSpan, clickableSpan };
                            }
                            return originalSpans;
                        });
                    }
                })
                .build();
    }


    /**
     * 获取单例实例
     */
    public static synchronized AUIAIMarkwonManager getInstance(Context context) {
        if (instance == null) {
            instance = new AUIAIMarkwonManager(context.getApplicationContext());
        }
        return instance;
    }

    public void registerLinkClickCallback(AUIAIMarkwonManagerCallback back) {
        callback = back;
    }

    /**
     * 获取 Markwon 实例
     */
    public Markwon getMarkwon() {
        return markwon;
    }

    private class CustomLinkSpan extends ClickableSpan {
        private final String url;

        public CustomLinkSpan(String url) {
            this.url = url;
        }

        @Override
        public void updateDrawState(TextPaint ds) {
            super.updateDrawState(ds);
            ds.setColor(Color.parseColor("#3295FB")); // Set your desired color
            ds.setUnderlineText(false); // Remove underline
        }

        @Override
        public void onClick(View widget) {
            if(callback != null) {
                callback.onLinkClicked(url, true);
            }
        }
    }

    private class CustomAbsoluteSizeSpan extends AbsoluteSizeSpan {
        public CustomAbsoluteSizeSpan(int size) {
            super(size, true); // 第二个参数表示是否使用dp单位
        }
    }
}
