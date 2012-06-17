package uk.me.jandj.gamework;

import android.app.Activity;
import android.os.Bundle;
import com.google.android.c2dm.C2DMessaging;

public class MainActivity extends Activity {
  /** Called when the activity is first created. */
  @Override
  public void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);
    // Do this on-install somehow?
    C2DMessaging.register(this, "gamework@jandj.me.uk");
  }
  

}
