package com.aliyun.auikits.aicall;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.bumptech.glide.Glide;

public class AUIAIChatExternalViewActivity extends AppCompatActivity {

    private String mWebViewUrl;
    private String mImageUrl;
    private WebView mebView;
    private TextView mTvTitle;
    private ImageView mImageView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(com.chad.library.R.style.Theme_AppCompat_Light_NoActionBar);
        setContentView(R.layout.activity_auiaichat_external_view);

        if(getIntent().getExtras() != null) {
            mWebViewUrl = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_EXTERNAL_WEBVIEW_URL, null);
            mImageUrl = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_EXTERNAL_IMAGE_URL, null);
        }

        mebView = findViewById(R.id.web_view);
        mImageView = findViewById(R.id.image_view);


        findViewById(R.id.btn_back_image).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        if(mWebViewUrl != null && !TextUtils.isEmpty(mWebViewUrl)) {
            mebView.getSettings().setJavaScriptEnabled(true);
            mebView.setWebViewClient(new WebViewClient());
            mebView.loadUrl(mWebViewUrl);
            mImageView.setVisibility(View.GONE);
            mebView.setVisibility(View.VISIBLE);

            mTvTitle = findViewById(R.id.web_title);

            setTitle(mWebViewUrl);

            mebView.setWebViewClient(new WebViewClient(){
                @Override
                public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                    view.loadUrl(request.getUrl().toString());
                    return true;
                }
            });

            mebView.setWebChromeClient(new WebChromeClient() {
                @Override
                public void onReceivedTitle(WebView view, String title) {
                    super.onReceivedTitle(view, title);
                    if (title != null && !title.isEmpty()) {
                        setTitle(title);
                    }
                }
            });
        } else if(mImageUrl != null && !TextUtils.isEmpty(mImageUrl)) {

            mebView.setVisibility(View.GONE);
            mImageView.setVisibility(View.VISIBLE);
            Glide.with(this)
                    .load(mImageUrl)
                    .into(mImageView);

        }
    }

    @Override
    public void onBackPressed() {
        if (mebView.canGoBack()) {
            mebView.goBack();
        } else {
            super.onBackPressed();
        }
    }

    private void setTitle(String title) {
        mTvTitle.setText(title);
    }
}
