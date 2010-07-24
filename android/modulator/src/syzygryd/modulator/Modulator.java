package syzygryd.modulator;

import android.app.Activity;
import android.content.res.Configuration;
import android.os.Bundle;
import android.util.Log;

public class Modulator extends Activity
{
   private static final String LOG = "SyzygyrdModulator";

   /* Activity */
   @Override
   public void onCreate(Bundle savedInstanceState) {
      Log.v(LOG, "onCreate()");
      super.onCreate(savedInstanceState);
      setContentView(R.layout.main);
   }

   /* Activity */
   @Override
      public void onConfigurationChanged(Configuration newConfig) {
      Log.v(LOG, "onConfigurationChanged(" + newConfig + ")");
      // XXX will *not* calling super prevent the display from rotating ?
   }

}

/*
** Local Variables:
**   mode: java
**   c-basic-offset: 3
**   tab-width: 3
**   indent-tabs-mode: nil
** End:
**
** ex: set softtabstop=3 tabstop=3 expandtab cindent shiftwidth=3 ft=java :
*/
