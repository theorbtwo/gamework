package uk.me.jandj.gamework;

import java.io.IOException;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.google.android.c2dm.C2DMBaseReceiver;
import com.google.android.c2dm.C2DMessaging;

public class C2DMReceiver extends C2DMBaseReceiver {
  public static final String C2DM_SENDER = "gamework@jandj.me.uk";
  public static final String C2DM_ACCOUNT_EXTRA = "account_name";
  public static final String C2DM_MESSAGE_EXTRA = "message";
  public static final String C2DM_MESSAGE_SYNC = "sync";

  // Borrowed from Config.java in jumpnote:
  public static String makeLogTag(Class cls) {
    String tag = "JumpNote_" + cls.getSimpleName();
    return (tag.length() > 23) ? tag.substring(0, 23) : tag;
  }

  static final String TAG = makeLogTag(C2DMReceiver.class);


    public C2DMReceiver() {
      // FIXME, where the heck does Config come from?
      //        super(Config.C2DM_SENDER);
        super("gamework@jandj.me.uk");
    }

    @Override
    public void onError(Context context, String errorId) {
        Toast.makeText(context, "Messaging registration error: " + errorId,
                Toast.LENGTH_LONG).show();
    }

    @Override
    protected void onMessage(Context context, Intent intent) {
        String accountName = intent.getExtras().getString(C2DM_ACCOUNT_EXTRA);
        String message = intent.getExtras().getString(C2DM_MESSAGE_EXTRA);
        if (C2DM_MESSAGE_SYNC.equals(message)) {
            if (accountName != null) {
                if (Log.isLoggable(TAG, Log.DEBUG)) {
                    Log.d(TAG, "Messaging request received for account " + accountName);
                }

                // Do stuff with message here
            }
        }
    }

    @Override
    public void onRegistered(Context context, String registrationId) throws IOException {
      // registrationId has been saved internally to C2DMessaging
      // Now we need to send it to the gamework/app server.

        Toast.makeText(context, "Got RegId: " + registrationId,
                Toast.LENGTH_LONG).show();
    }

}
