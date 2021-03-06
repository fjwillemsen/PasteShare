package com.example.floris_jan.pasteshare;

/**
 * Created by floris-jan on 26-09-16.
 */

import android.content.Context;
import android.os.AsyncTask;
import android.os.Handler;
import android.util.Log;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;

/**
 * AsyncTask which handles the communication with the server
 */
class Client extends AsyncTask<String, Void, String> {

    @Override
    protected String doInBackground(String... params) {
        String result = null;
        try {
            //Create a client socket and define internet address and the port of the server
            Socket socket = new Socket(params[0], Integer.parseInt(params[1]));

            //Get the input stream of the client socket
            InputStream is = socket.getInputStream();

            //Get the output stream of the client socket
            PrintWriter out = new PrintWriter(socket.getOutputStream(),true);
            //Write data to the output stream of the client socket
            out.print(params[2]);
            out.flush();
            //Buffer the data coming from the input stream
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            //Read data in the input buffer
            if(br.ready()) {
                result = br.readLine();
            }
            //Close the client socket
            socket.close();
            Log.d("Exception", "Success!");
        } catch (NumberFormatException e) {
            Log.e("Exception", "NFException");
            e.printStackTrace();
        } catch (UnknownHostException e) {
            Log.e("Exception", "UKHostException");
            e.printStackTrace();
        } catch (IOException e) {
            Log.e("Exception", "IOException");
            e.printStackTrace();
        }
        return result;
    }
    @Override
    protected void onPostExecute(String s) {
        //Write server message to the text view
        Log.d("NetStuff","Server answer:" + s);
    }
}
