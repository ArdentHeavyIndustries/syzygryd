package syzygryd.modulator;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;

public class Modulator extends Activity
{
   private static final String LOG = "SyzygyrdModulator";

   private static final int MENU_SETTINGS = 0;
   private static final int MENU_EXIT = 1;

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

   /* Activity */
   @Override
   public boolean onCreateOptionsMenu(Menu menu) {
      menu.add(0, MENU_SETTINGS, MENU_SETTINGS, "Settings");
      menu.add(0, MENU_EXIT, MENU_EXIT, "Exit");
      return true;
   }
   
   /* Activity */
   @Override
   public boolean onOptionsItemSelected(MenuItem item) {
      switch (item.getItemId())
         {
         case MENU_SETTINGS:
            doSettings();
            return true;
         case MENU_EXIT:
            doExit();
            return true;
         }
      return false;
   }

   private void doSettings() {
      Log.v(LOG, "Launching Activity for settings");
      /* Context */ this.startActivity(new Intent(/* Context */ this, Preferences.class));
   }
   
   private void doExit() {
      Log.d(LOG, "Exitting");
      /* Activity */ this.finish();
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
