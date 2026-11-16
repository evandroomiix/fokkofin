package com.fokkofin.app;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.WebView;
import androidx.core.view.WindowCompat;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    private String pendingDeepLink = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Garante que a barra de notificações (status bar) fique ACIMA do app e nunca sobreponha o conteúdo
        WindowCompat.setDecorFitsSystemWindows(getWindow(), true);
        handleDeepLinkIntent(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleDeepLinkIntent(intent);
    }

    private void handleDeepLinkIntent(Intent intent) {
        if (intent == null) return;
        Uri data = intent.getData();
        if (data != null) {
            String uriString = data.toString();
            this.pendingDeepLink = uriString;
            sendDeepLinkToWebView(uriString);
        }
    }

    private void sendDeepLinkToWebView(final String url) {
        if (getBridge() != null && getBridge().getWebView() != null) {
            final WebView webView = getBridge().getWebView();
            webView.post(new Runnable() {
                @Override
                public void run() {
                    String escaped = url.replace("'", "\\'");
                    String js = "if (typeof handleDeepLinkUrl === 'function') { handleDeepLinkUrl('" + escaped + "'); }";
                    webView.evaluateJavascript(js, null);
                }
            });
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (pendingDeepLink != null) {
            sendDeepLinkToWebView(pendingDeepLink);
        }
    }
}
