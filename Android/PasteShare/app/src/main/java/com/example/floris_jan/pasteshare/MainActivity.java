package com.example.floris_jan.pasteshare;

import android.content.Context;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.EditText;

import com.google.zxing.Result;
import me.dm7.barcodescanner.zxing.ZXingScannerView;

public class MainActivity extends AppCompatActivity implements ZXingScannerView.ResultHandler {
    public static String ipAddress = "192.168.1.3";
    public static String portNumber = "60200";
    private ZXingScannerView mScannerView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

//        final EditText editIPAddress = (EditText) findViewById(R.id.editIPAddress);
//        final EditText editPortNumber = (EditText) findViewById(R.id.editPortNumber);
//
//        editIPAddress.setText(ipAddress);
//        editPortNumber.setText(portNumber);
//
//        editIPAddress.addTextChangedListener(new TextWatcher() {
//            @Override
//            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
//
//            }
//
//            @Override
//            public void onTextChanged(CharSequence s, int start, int before, int count) {
//
//            }
//
//            @Override
//            public void afterTextChanged(Editable s) {
//                ipAddress = editIPAddress.getText().toString();
//            }
//        });
//
//        editPortNumber.addTextChangedListener(new TextWatcher() {
//            @Override
//            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
//
//            }
//
//            @Override
//            public void onTextChanged(CharSequence s, int start, int before, int count) {
//
//            }
//
//            @Override
//            public void afterTextChanged(Editable s) {
//                portNumber = editPortNumber.getText().toString();
//            }
//        });
    }

    public void QrScanner(View view){
        mScannerView = new ZXingScannerView(this);   // Programmatically initialize the scanner view
        setContentView(mScannerView);

        mScannerView.setResultHandler(this); // Register ourselves as a handler for scan results.
        mScannerView.startCamera();         // Start camera

    }

    @Override
    public void onPause() {
        super.onPause();
        mScannerView.stopCamera();           // Stop camera on pause
    }

    @Override
    public void handleResult(Result rawResult) {
        // Do something with the result here

        Log.e("handler", rawResult.getText()); // Prints scan results
        Log.e("handler", rawResult.getBarcodeFormat().toString()); // Prints the scan format (qrcode)

        ipAddress = rawResult.getText();
        sendString("Succesful connection with;+" + android.os.Build.MODEL);

        // show the scanner result into dialog box.
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Scan Result");
        builder.setMessage("Connected to " + ipAddress);
        AlertDialog alert = builder.create();
        alert.show();
        setContentView(R.layout.activity_main);

        // If you would like to resume scanning, call this method below:
        // mScannerView.resumeCameraPreview(this);
    }

    public static void sendString(String data) {
        Client client  = new Client();
        client.execute(new String[]{ipAddress, portNumber, data});
    }
}
