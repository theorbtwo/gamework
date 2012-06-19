package uk.me.jandj.gamework;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import com.google.android.c2dm.C2DMessaging;
import android.text.TextUtils;

public class MainActivity extends Activity {
  /** Called when the activity is first created. */
  @Override
  public void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);

    // Do this on-install somehow?
    Log.d("gamework", "onCreate!");

    String registrationId = C2DMessaging.getRegistrationId(this /**context**/);
    if (TextUtils.isEmpty(registrationId)) {
      C2DMessaging.register(this, "gamework@jandj.me.uk");
    }
    //    C2DMessaging.register(this, "gamework@jandj.me.uk");
  }
}
