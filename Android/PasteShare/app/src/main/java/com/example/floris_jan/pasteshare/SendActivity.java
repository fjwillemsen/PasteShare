package com.example.floris_jan.pasteshare;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import static android.R.attr.action;
import static android.R.attr.type;

/**
 * Created by floris-jan on 26-09-16.
 */

public class SendActivity extends Activity {
    private Client client;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        String action = intent.getAction();
        String type = intent.getType();
        client  = new Client();

        if (Intent.ACTION_SEND.equals(action) && type != null) {
            if ("text/plain".equals(type)) {
                MainActivity.sendString(intent.getStringExtra(Intent.EXTRA_TEXT)); // Handle text being sent
            } else if (type.startsWith("image/")) {
//                handleSendImage(intent); // Handle single image being sent
            }
        } else if (Intent.ACTION_SEND_MULTIPLE.equals(action) && type != null) {
            if (type.startsWith("image/")) {
//                handleSendMultipleImages(intent); // Handle multiple images being sent
            }
        } else {
            // Handle other intents, such as being started from the home screen
        }

        finish();
    }
}
