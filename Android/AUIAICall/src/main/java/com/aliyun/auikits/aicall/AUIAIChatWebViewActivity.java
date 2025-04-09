package com.aliyun.auikits.aicall;

import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;

public class AUIAIChatWebViewActivity extends AppCompatActivity {

    private String mUrl;
    private WebView mebView;
    private TextView mTvTitle;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(com.chad.library.R.style.Theme_AppCompat_Light_NoActionBar);
        setContentView(R.layout.activity_auiaichat_web_view);

        if(getIntent().getExtras() != null) {
            mUrl = getIntent().getExtras().getString(AUIAIConstStrKey.BUNDLE_KEY_WEBVIEW_URL, null);
        }

        mebView = findViewById(R.id.web_view);

        findViewById(R.id.btn_back_image).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mebView.getSettings().setJavaScriptEnabled(true);
        mebView.setWebViewClient(new WebViewClient());
        mebView.loadUrl(mUrl);

        mTvTitle = findViewById(R.id.web_title);

        setTitle(mUrl);

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
