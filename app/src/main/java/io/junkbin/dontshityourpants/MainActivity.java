package io.junkbin.dontshityourpants;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.widget.EditText;
import android.widget.FrameLayout;

public class MainActivity extends Activity {

    private WebView webView;
    private EditText hiddenInput;
    private boolean clearingInput = false;
    private boolean readyToSend = false;

    // Send a keycode to the game: pushes to codo_key_buffer and triggers btnp for Enter
    private void sendKey(int code) {
        if (code == 13) {
            // p8sdlkey dispatches keydown which game's own listener uses to push 13 to codo_key_buffer
            // so we don't push manually - avoids double push
            webView.evaluateJavascript(
                "(function(){" +
                "  if(typeof p8btnpress!=='undefined') p8btnpress(0x30);" +
                "  if(typeof p8sdlkey!=='undefined') p8sdlkey(13);" +
                "})()", null
            );
        } else {
            webView.evaluateJavascript(
                "(function(){" +
                "  if(typeof codo_key_buffer!=='undefined') codo_key_buffer.push(" + code + ");" +
                "})()", null
            );
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().getDecorView().setSystemUiVisibility(
            View.SYSTEM_UI_FLAG_FULLSCREEN |
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        );

        FrameLayout root = new FrameLayout(this);
        setContentView(root);

        webView = new WebView(this);
        root.addView(webView, new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        ));

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setMediaPlaybackRequiresUserGesture(false);
        settings.setDomStorageEnabled(true);
        settings.setCacheMode(WebSettings.LOAD_NO_CACHE);
        settings.setAllowFileAccessFromFileURLs(true);
        settings.setAllowUniversalAccessFromFileURLs(true);

        android.webkit.WebView.setWebContentsDebuggingEnabled(true);
        webView.setWebChromeClient(new WebChromeClient());
        webView.setOverScrollMode(View.OVER_SCROLL_NEVER);


        // Hidden EditText — captures soft keyboard input
        hiddenInput = new EditText(this);
        hiddenInput.setAlpha(0.01f);
        hiddenInput.setFocusable(true);
        hiddenInput.setFocusableInTouchMode(true);
        hiddenInput.setInputType(
            InputType.TYPE_CLASS_TEXT |
            InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS |
            InputType.TYPE_TEXT_FLAG_MULTI_LINE
        );
        hiddenInput.setImeOptions(
            EditorInfo.IME_FLAG_NO_EXTRACT_UI |
            EditorInfo.IME_FLAG_NO_FULLSCREEN
        );

        FrameLayout.LayoutParams inputLp = new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, 1
        );
        inputLp.gravity = android.view.Gravity.BOTTOM;
        root.addView(hiddenInput, inputLp);

        hiddenInput.addTextChangedListener(new TextWatcher() {
            private String lastText = "";

            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                if (clearingInput) return;
                if (!readyToSend) { lastText = s.toString(); return; }
                String current = s.toString();
                if (current.length() > lastText.length()) {
                    String added = current.substring(lastText.length());
                    for (char c : added.toCharArray()) {
                        if (c == '\n') {
                            sendKey(13);
                            clearHiddenInput();
                            lastText = "";
                            return;
                        }
                        sendKey((int) c);
                    }
                } else if (current.length() < lastText.length()) {
                    sendKey(8); // Backspace
                }
                lastText = current;
                if (current.length() > 20) {
                    clearHiddenInput();
                    lastText = "";
                }
            }
        });

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                new Handler(getMainLooper()).postDelayed(() -> {
                    readyToSend = true;
                    clearHiddenInput();
                    showKeyboard();
                }, 2000);
            }
        });

        webView.loadUrl("file:///android_asset/index.html");
    }

    private void clearHiddenInput() {
        clearingInput = true;
        hiddenInput.setText("");
        clearingInput = false;
    }

    private void showKeyboard() {
        hiddenInput.requestFocus();
        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        if (imm != null) imm.showSoftInput(hiddenInput, InputMethodManager.SHOW_IMPLICIT);
    }

    @Override
    public void onBackPressed() {}

    @Override
    protected void onPause() {
        super.onPause();
        webView.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        webView.onResume();
        new Handler(getMainLooper()).postDelayed(() -> showKeyboard(), 300);
    }
}
