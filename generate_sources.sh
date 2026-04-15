#!/bin/bash
# Auto-generated: creates all NightGuardian source files

mkdir -p app/src/main/java/com/nightguardian/app/{service,receiver,ui,model,util}
mkdir -p app/src/main/res/{layout,drawable,values,mipmap-hdpi,mipmap-mdpi,mipmap-xhdpi,mipmap-xxhdpi}

# ── AndroidManifest.xml ──────────────────────────────────────────────────────
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_PHONE_CALL" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />
    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher"
        android:supportsRtl="true"
        android:theme="@style/Theme.NightGuardian">
        <activity android:name=".ui.MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <service android:name=".service.CallMonitorService" android:exported="false" android:foregroundServiceType="phoneCall" />
        <receiver android:name=".receiver.BootReceiver" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
            </intent-filter>
        </receiver>
        <receiver android:name=".receiver.SleepScheduleReceiver" android:exported="false" />
    </application>
</manifest>
EOF

# ── FavoriteContact.java ─────────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/model/FavoriteContact.java << 'EOF'
package com.nightguardian.app.model;
public class FavoriteContact {
    private final long id; private final String name, phoneNumber, initials;
    public FavoriteContact(long id, String name, String phoneNumber) {
        this.id=id; this.name=name; this.phoneNumber=phoneNumber;
        String[] p=name.trim().split("\\s+");
        this.initials=(p.length>=2?(""+p[0].charAt(0)+p[p.length-1].charAt(0)):name.substring(0,Math.min(2,name.length()))).toUpperCase();
    }
    public long getId(){return id;} public String getName(){return name;}
    public String getPhoneNumber(){return phoneNumber;} public String getInitials(){return initials;}
}
EOF

# ── CallLogEntry.java ────────────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/model/CallLogEntry.java << 'EOF'
package com.nightguardian.app.model;
public class CallLogEntry {
    public enum Result{BYPASSED,BLOCKED}
    private final String name,number; private final long timestamp; private final Result result;
    public CallLogEntry(String name,String number,long timestamp,Result result){this.name=name;this.number=number;this.timestamp=timestamp;this.result=result;}
    public String getName(){return name;} public String getNumber(){return number;}
    public long getTimestamp(){return timestamp;} public Result getResult(){return result;}
}
EOF

# ── Prefs.java ───────────────────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/util/Prefs.java << 'EOF'
package com.nightguardian.app.util;
import android.content.Context; import android.content.SharedPreferences;
import com.nightguardian.app.model.CallLogEntry;
import org.json.JSONArray; import org.json.JSONException; import org.json.JSONObject;
import java.util.ArrayList; import java.util.List;
public class Prefs {
    private static final String FILE="night_guardian_prefs",KEY_ENABLED="sleep_mode_enabled",
        KEY_START_HOUR="start_hour",KEY_START_MIN="start_min",KEY_END_HOUR="end_hour",
        KEY_END_MIN="end_min",KEY_CALL_LOG="call_log";
    private final SharedPreferences sp;
    public Prefs(Context ctx){sp=ctx.getApplicationContext().getSharedPreferences(FILE,Context.MODE_PRIVATE);}
    public boolean isSleepModeEnabled(){return sp.getBoolean(KEY_ENABLED,false);}
    public void setSleepModeEnabled(boolean e){sp.edit().putBoolean(KEY_ENABLED,e).apply();}
    public int getStartHour(){return sp.getInt(KEY_START_HOUR,22);} public int getStartMin(){return sp.getInt(KEY_START_MIN,30);}
    public int getEndHour(){return sp.getInt(KEY_END_HOUR,7);} public int getEndMin(){return sp.getInt(KEY_END_MIN,0);}
    public void setSchedule(int sh,int sm,int eh,int em){sp.edit().putInt(KEY_START_HOUR,sh).putInt(KEY_START_MIN,sm).putInt(KEY_END_HOUR,eh).putInt(KEY_END_MIN,em).apply();}
    public List<CallLogEntry> getCallLog(){
        List<CallLogEntry> list=new ArrayList<>(); String json=sp.getString(KEY_CALL_LOG,"[]");
        try{JSONArray arr=new JSONArray(json);for(int i=0;i<arr.length();i++){JSONObject o=arr.getJSONObject(i);list.add(new CallLogEntry(o.getString("name"),o.getString("number"),o.getLong("timestamp"),CallLogEntry.Result.valueOf(o.getString("result"))));}
        }catch(JSONException ignored){}return list;}
    public void appendCallLog(CallLogEntry entry){
        List<CallLogEntry> log=getCallLog();log.add(0,entry);if(log.size()>50)log=log.subList(0,50);
        JSONArray arr=new JSONArray();for(CallLogEntry e:log){JSONObject o=new JSONObject();try{o.put("name",e.getName());o.put("number",e.getNumber());o.put("timestamp",e.getTimestamp());o.put("result",e.getResult().name());arr.put(o);}catch(JSONException ignored){}}
        sp.edit().putString(KEY_CALL_LOG,arr.toString()).apply();}
    public void clearCallLog(){sp.edit().putString(KEY_CALL_LOG,"[]").apply();}
}
EOF

# ── ContactsHelper.java ──────────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/util/ContactsHelper.java << 'EOF'
package com.nightguardian.app.util;
import android.content.Context; import android.database.Cursor; import android.provider.ContactsContract;
import com.nightguardian.app.model.FavoriteContact;
import java.util.ArrayList; import java.util.List;
public class ContactsHelper {
    public static List<FavoriteContact> getStarredContacts(Context ctx){
        List<FavoriteContact> result=new ArrayList<>();
        String[] proj={ContactsContract.Contacts._ID,ContactsContract.Contacts.DISPLAY_NAME_PRIMARY,ContactsContract.Contacts.STARRED,ContactsContract.Contacts.HAS_PHONE_NUMBER};
        String sel=ContactsContract.Contacts.STARRED+"=1 AND "+ContactsContract.Contacts.HAS_PHONE_NUMBER+"=1";
        try(Cursor c=ctx.getContentResolver().query(ContactsContract.Contacts.CONTENT_URI,proj,sel,null,ContactsContract.Contacts.DISPLAY_NAME_PRIMARY+" ASC")){
            if(c==null)return result;
            while(c.moveToNext()){long id=c.getLong(c.getColumnIndexOrThrow(ContactsContract.Contacts._ID));String name=c.getString(c.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME_PRIMARY));String phone=getFirstPhoneNumber(ctx,id);if(phone!=null)result.add(new FavoriteContact(id,name,phone));}}
        return result;}
    private static String getFirstPhoneNumber(Context ctx,long contactId){
        try(Cursor c=ctx.getContentResolver().query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,new String[]{ContactsContract.CommonDataKinds.Phone.NUMBER},ContactsContract.CommonDataKinds.Phone.CONTACT_ID+"=?",new String[]{String.valueOf(contactId)},null)){
            if(c!=null&&c.moveToFirst())return c.getString(0);}return null;}
    public static String normalise(String n){if(n==null)return "";String d=n.replaceAll("[^0-9]","");if(d.length()>9)d=d.substring(d.length()-9);return d;}
    public static FavoriteContact findMatch(Context ctx,String incoming){String norm=normalise(incoming);for(FavoriteContact c:getStarredContacts(ctx)){if(normalise(c.getPhoneNumber()).equals(norm))return c;}return null;}
}
EOF

# ── ScheduleHelper.java ──────────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/util/ScheduleHelper.java << 'EOF'
package com.nightguardian.app.util;
import android.app.AlarmManager; import android.app.PendingIntent; import android.content.Context; import android.content.Intent;
import com.nightguardian.app.receiver.SleepScheduleReceiver;
import java.util.Calendar;
public class ScheduleHelper {
    public static final String ACTION_SLEEP_START="com.nightguardian.SLEEP_START",ACTION_SLEEP_END="com.nightguardian.SLEEP_END";
    private static final int PI_START=100,PI_END=101;
    public static void scheduleDailyAlarms(Context ctx){Prefs p=new Prefs(ctx);AlarmManager am=(AlarmManager)ctx.getSystemService(Context.ALARM_SERVICE);setRepeatingAlarm(ctx,am,p.getStartHour(),p.getStartMin(),ACTION_SLEEP_START,PI_START);setRepeatingAlarm(ctx,am,p.getEndHour(),p.getEndMin(),ACTION_SLEEP_END,PI_END);}
    public static void cancelAlarms(Context ctx){AlarmManager am=(AlarmManager)ctx.getSystemService(Context.ALARM_SERVICE);am.cancel(buildIntent(ctx,ACTION_SLEEP_START,PI_START));am.cancel(buildIntent(ctx,ACTION_SLEEP_END,PI_END));}
    private static void setRepeatingAlarm(Context ctx,AlarmManager am,int hour,int min,String action,int req){am.setRepeating(AlarmManager.RTC_WAKEUP,nextOccurrence(hour,min),AlarmManager.INTERVAL_DAY,buildIntent(ctx,action,req));}
    private static PendingIntent buildIntent(Context ctx,String action,int req){Intent i=new Intent(ctx,SleepScheduleReceiver.class);i.setAction(action);return PendingIntent.getBroadcast(ctx,req,i,PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);}
    public static long nextOccurrence(int hour,int min){Calendar c=Calendar.getInstance();c.set(Calendar.HOUR_OF_DAY,hour);c.set(Calendar.MINUTE,min);c.set(Calendar.SECOND,0);c.set(Calendar.MILLISECOND,0);if(c.getTimeInMillis()<=System.currentTimeMillis())c.add(Calendar.DAY_OF_YEAR,1);return c.getTimeInMillis();}
    public static boolean isInsideSleepWindow(Context ctx){Prefs p=new Prefs(ctx);Calendar now=Calendar.getInstance();int n=now.get(Calendar.HOUR_OF_DAY)*60+now.get(Calendar.MINUTE),s=p.getStartHour()*60+p.getStartMin(),e=p.getEndHour()*60+p.getEndMin();return s<e?(n>=s&&n<e):(n>=s||n<e);}
}
EOF

# ── CallMonitorService.java ──────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/service/CallMonitorService.java << 'EOF'
package com.nightguardian.app.service;
import android.app.*; import android.content.Context; import android.content.Intent;
import android.media.AudioManager; import android.os.IBinder;
import android.telephony.PhoneStateListener; import android.telephony.TelephonyManager;
import androidx.core.app.NotificationCompat;
import com.nightguardian.app.R;
import com.nightguardian.app.model.CallLogEntry; import com.nightguardian.app.model.FavoriteContact;
import com.nightguardian.app.ui.MainActivity;
import com.nightguardian.app.util.ContactsHelper; import com.nightguardian.app.util.Prefs;
public class CallMonitorService extends Service {
    private static final String CHANNEL_ID="night_guardian_channel"; private static final int NOTIF_ID=1;
    private TelephonyManager tm; private PhoneStateListener psl; private AudioManager am; private Prefs prefs;
    private int savedRingerMode=AudioManager.RINGER_MODE_SILENT,savedRingerVolume=0; private boolean boosted=false;
    @Override public void onCreate(){super.onCreate();prefs=new Prefs(this);am=(AudioManager)getSystemService(Context.AUDIO_SERVICE);createChannel();startForeground(NOTIF_ID,buildNotif("Monitoring calls…"));registerListener();}
    @Override public int onStartCommand(Intent i,int f,int s){return START_STICKY;}
    @Override public IBinder onBind(Intent i){return null;}
    @Override public void onDestroy(){if(tm!=null&&psl!=null)tm.listen(psl,PhoneStateListener.LISTEN_NONE);super.onDestroy();}
    private void registerListener(){tm=(TelephonyManager)getSystemService(Context.TELEPHONY_SERVICE);psl=new PhoneStateListener(){@Override public void onCallStateChanged(int state,String num){if(state==TelephonyManager.CALL_STATE_RINGING)handleCall(num);else if(state==TelephonyManager.CALL_STATE_IDLE&&boosted)restore();}};tm.listen(psl,PhoneStateListener.LISTEN_CALL_STATE);}
    private void handleCall(String number){if(number==null||number.isEmpty())return;FavoriteContact m=ContactsHelper.findMatch(this,number);if(m!=null){boost();log(m.getName(),number,CallLogEntry.Result.BYPASSED);updateNotif("Ringing: "+m.getName()+" ★");}else{log("Unknown",number,CallLogEntry.Result.BLOCKED);}}
    private void boost(){boosted=true;savedRingerMode=am.getRingerMode();savedRingerVolume=am.getStreamVolume(AudioManager.STREAM_RING);am.setRingerMode(AudioManager.RINGER_MODE_NORMAL);am.setStreamVolume(AudioManager.STREAM_RING,am.getStreamMaxVolume(AudioManager.STREAM_RING),AudioManager.FLAG_SHOW_UI);}
    private void restore(){am.setStreamVolume(AudioManager.STREAM_RING,savedRingerVolume,0);am.setRingerMode(savedRingerMode);boosted=false;updateNotif("Monitoring calls…");}
    private void log(String name,String number,CallLogEntry.Result r){prefs.appendCallLog(new CallLogEntry(name,number,System.currentTimeMillis(),r));}
    private void createChannel(){NotificationChannel ch=new NotificationChannel(CHANNEL_ID,"Night Guardian",NotificationManager.IMPORTANCE_LOW);getSystemService(NotificationManager.class).createNotificationChannel(ch);}
    private Notification buildNotif(String text){return new NotificationCompat.Builder(this,CHANNEL_ID).setContentTitle("Night Guardian active").setContentText(text).setSmallIcon(R.drawable.ic_moon).setContentIntent(PendingIntent.getActivity(this,0,new Intent(this,MainActivity.class),PendingIntent.FLAG_IMMUTABLE)).setOngoing(true).setPriority(NotificationCompat.PRIORITY_LOW).build();}
    private void updateNotif(String text){getSystemService(NotificationManager.class).notify(NOTIF_ID,buildNotif(text));}
}
EOF

# ── BootReceiver.java ────────────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/receiver/BootReceiver.java << 'EOF'
package com.nightguardian.app.receiver;
import android.content.BroadcastReceiver; import android.content.Context; import android.content.Intent;
import com.nightguardian.app.service.CallMonitorService;
import com.nightguardian.app.util.Prefs; import com.nightguardian.app.util.ScheduleHelper;
public class BootReceiver extends BroadcastReceiver {
    @Override public void onReceive(Context ctx,Intent i){Prefs p=new Prefs(ctx);ScheduleHelper.scheduleDailyAlarms(ctx);if(p.isSleepModeEnabled()&&ScheduleHelper.isInsideSleepWindow(ctx))ctx.startForegroundService(new Intent(ctx,CallMonitorService.class));}
}
EOF

# ── SleepScheduleReceiver.java ───────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/receiver/SleepScheduleReceiver.java << 'EOF'
package com.nightguardian.app.receiver;
import android.content.BroadcastReceiver; import android.content.Context; import android.content.Intent;
import com.nightguardian.app.service.CallMonitorService;
import com.nightguardian.app.util.Prefs; import com.nightguardian.app.util.ScheduleHelper;
public class SleepScheduleReceiver extends BroadcastReceiver {
    @Override public void onReceive(Context ctx,Intent i){Prefs p=new Prefs(ctx);if(!p.isSleepModeEnabled())return;if(ScheduleHelper.ACTION_SLEEP_START.equals(i.getAction()))ctx.startForegroundService(new Intent(ctx,CallMonitorService.class));else if(ScheduleHelper.ACTION_SLEEP_END.equals(i.getAction()))ctx.stopService(new Intent(ctx,CallMonitorService.class));}
}
EOF

# ── FavoritesAdapter.java ────────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/ui/FavoritesAdapter.java << 'EOF'
package com.nightguardian.app.ui;
import android.view.*; import android.widget.TextView;
import androidx.annotation.NonNull; import androidx.recyclerview.widget.RecyclerView;
import com.nightguardian.app.R; import com.nightguardian.app.model.FavoriteContact;
import java.util.ArrayList; import java.util.List;
public class FavoritesAdapter extends RecyclerView.Adapter<FavoritesAdapter.VH> {
    private List<FavoriteContact> data;
    private static final int[] BG={0xFF1E1E3A,0xFF0D3028,0xFF3A1A12,0xFF332210};
    private static final int[] FG={0xFFA090FF,0xFF4DD4A8,0xFFF07050,0xFFE8A040};
    public FavoritesAdapter(List<FavoriteContact> d){this.data=new ArrayList<>(d);}
    public void updateData(List<FavoriteContact> d){this.data=new ArrayList<>(d);notifyDataSetChanged();}
    @NonNull @Override public VH onCreateViewHolder(@NonNull ViewGroup p,int t){return new VH(LayoutInflater.from(p.getContext()).inflate(R.layout.item_favorite,p,false));}
    @Override public void onBindViewHolder(@NonNull VH h,int pos){FavoriteContact c=data.get(pos);int i=pos%BG.length;h.avatar.setText(c.getInitials());h.avatar.setBackgroundColor(BG[i]);h.avatar.setTextColor(FG[i]);h.name.setText(c.getName());h.phone.setText(c.getPhoneNumber());}
    @Override public int getItemCount(){return data.size();}
    static class VH extends RecyclerView.ViewHolder{TextView avatar,name,phone;VH(View v){super(v);avatar=v.findViewById(R.id.avatarText);name=v.findViewById(R.id.contactName);phone=v.findViewById(R.id.contactPhone);}}
}
EOF

# ── CallLogAdapter.java ──────────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/ui/CallLogAdapter.java << 'EOF'
package com.nightguardian.app.ui;
import android.view.*; import android.widget.TextView;
import androidx.annotation.NonNull; import androidx.recyclerview.widget.RecyclerView;
import com.nightguardian.app.R; import com.nightguardian.app.model.CallLogEntry;
import java.text.SimpleDateFormat; import java.util.*; 
public class CallLogAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private static final int TYPE_ENTRY=0,TYPE_FOOTER=1;
    private List<CallLogEntry> data; private final Runnable clearCb;
    private final SimpleDateFormat sdf=new SimpleDateFormat("EEE HH:mm",Locale.getDefault());
    public CallLogAdapter(List<CallLogEntry> d,Runnable cb){this.data=new ArrayList<>(d);this.clearCb=cb;}
    public void updateData(List<CallLogEntry> d){this.data=new ArrayList<>(d);notifyDataSetChanged();}
    @Override public int getItemViewType(int p){return p<data.size()?TYPE_ENTRY:TYPE_FOOTER;}
    @Override public int getItemCount(){return data.size()+(data.isEmpty()?0:1);}
    @NonNull @Override public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup p,int t){LayoutInflater inf=LayoutInflater.from(p.getContext());if(t==TYPE_FOOTER){View v=inf.inflate(R.layout.item_log_footer,p,false);return new FooterVH(v);}return new EntryVH(inf.inflate(R.layout.item_log_entry,p,false));}
    @Override public void onBindViewHolder(@NonNull RecyclerView.ViewHolder h,int pos){if(h instanceof FooterVH){((FooterVH)h).clearBtn.setOnClickListener(v->clearCb.run());return;}CallLogEntry e=data.get(pos);EntryVH vh=(EntryVH)h;vh.name.setText(e.getName());vh.number.setText(e.getNumber());vh.time.setText(sdf.format(new Date(e.getTimestamp())));boolean b=e.getResult()==CallLogEntry.Result.BYPASSED;vh.badge.setText(b?"rang through":"silent");vh.badge.setBackgroundResource(b?R.drawable.badge_green:R.drawable.badge_gray);}
    static class EntryVH extends RecyclerView.ViewHolder{TextView name,number,time,badge;EntryVH(View v){super(v);name=v.findViewById(R.id.logName);number=v.findViewById(R.id.logNumber);time=v.findViewById(R.id.logTime);badge=v.findViewById(R.id.logBadge);}}
    static class FooterVH extends RecyclerView.ViewHolder{TextView clearBtn;FooterVH(View v){super(v);clearBtn=v.findViewById(R.id.clearLogBtn);}}
}
EOF

# ── MainActivity.java ────────────────────────────────────────────────────────
cat > app/src/main/java/com/nightguardian/app/ui/MainActivity.java << 'EOF'
package com.nightguardian.app.ui;
import android.Manifest; import android.app.*; import android.content.Intent; import android.content.pm.PackageManager;
import android.os.Build; import android.os.Bundle; import android.widget.TextView; import android.widget.Toast;
import androidx.activity.result.ActivityResultLauncher; import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity; import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager; import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.materialswitch.MaterialSwitch; import com.google.android.material.tabs.TabLayout;
import com.nightguardian.app.R; import com.nightguardian.app.model.*; import com.nightguardian.app.service.CallMonitorService;
import com.nightguardian.app.util.*;
import java.util.List; import java.util.Locale;
public class MainActivity extends AppCompatActivity {
    private Prefs prefs; private MaterialSwitch sleepToggle; private TextView startTimeText,endTimeText,statusText;
    private RecyclerView mainRecycler; private FavoritesAdapter favAdp; private CallLogAdapter logAdp; private int tab=0;
    private final ActivityResultLauncher<String[]> permLauncher=registerForActivityResult(new ActivityResultContracts.RequestMultiplePermissions(),r->{boolean ok=true;for(boolean v:r.values())if(!v){ok=false;break;}if(ok)applyToggle(true);else Toast.makeText(this,"Permissions required.",Toast.LENGTH_LONG).show();});
    @Override protected void onCreate(Bundle s){super.onCreate(s);setContentView(R.layout.activity_main);prefs=new Prefs(this);sleepToggle=findViewById(R.id.sleepToggle);startTimeText=findViewById(R.id.startTimeText);endTimeText=findViewById(R.id.endTimeText);statusText=findViewById(R.id.statusText);mainRecycler=findViewById(R.id.mainRecycler);mainRecycler.setLayoutManager(new LinearLayoutManager(this));refreshTimes();sleepToggle.setChecked(prefs.isSleepModeEnabled());sleepToggle.setOnCheckedChangeListener((b,c)->{if(c)checkPermsAndEnable();else applyToggle(false);});startTimeText.setOnClickListener(v->timePicker(true));endTimeText.setOnClickListener(v->timePicker(false));TabLayout tabs=findViewById(R.id.tabLayout);tabs.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener(){@Override public void onTabSelected(TabLayout.Tab t){tab=t.getPosition();refresh();}@Override public void onTabUnselected(TabLayout.Tab t){}@Override public void onTabReselected(TabLayout.Tab t){}});refresh();updateStatus();}
    @Override protected void onResume(){super.onResume();refresh();updateStatus();}
    private void checkPermsAndEnable(){String[] perms=Build.VERSION.SDK_INT>=33?new String[]{Manifest.permission.READ_CONTACTS,Manifest.permission.READ_PHONE_STATE,Manifest.permission.POST_NOTIFICATIONS}:new String[]{Manifest.permission.READ_CONTACTS,Manifest.permission.READ_PHONE_STATE};boolean ok=true;for(String p:perms)if(ContextCompat.checkSelfPermission(this,p)!=PackageManager.PERMISSION_GRANTED){ok=false;break;}NotificationManager nm=getSystemService(NotificationManager.class);if(!nm.isNotificationPolicyAccessGranted()){Toast.makeText(this,"Please grant Do Not Disturb access.",Toast.LENGTH_LONG).show();startActivity(new Intent(android.provider.Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS));}if(ok)applyToggle(true);else permLauncher.launch(perms);}
    private void applyToggle(boolean on){prefs.setSleepModeEnabled(on);sleepToggle.setChecked(on);if(on){ScheduleHelper.scheduleDailyAlarms(this);if(ScheduleHelper.isInsideSleepWindow(this))startForegroundService(new Intent(this,CallMonitorService.class));}else{ScheduleHelper.cancelAlarms(this);stopService(new Intent(this,CallMonitorService.class));}updateStatus();}
    private void timePicker(boolean start){int h=start?prefs.getStartHour():prefs.getEndHour(),m=start?prefs.getStartMin():prefs.getEndMin();new TimePickerDialog(this,(v,hour,min)->{if(start)prefs.setSchedule(hour,min,prefs.getEndHour(),prefs.getEndMin());else prefs.setSchedule(prefs.getStartHour(),prefs.getStartMin(),hour,min);refreshTimes();if(prefs.isSleepModeEnabled())ScheduleHelper.scheduleDailyAlarms(this);updateStatus();},h,m,true).show();}
    private void refreshTimes(){startTimeText.setText(String.format(Locale.getDefault(),"%02d:%02d",prefs.getStartHour(),prefs.getStartMin()));endTimeText.setText(String.format(Locale.getDefault(),"%02d:%02d",prefs.getEndHour(),prefs.getEndMin()));}
    private void updateStatus(){if(!prefs.isSleepModeEnabled()){statusText.setText("Sleep mode is off");return;}statusText.setText(ScheduleHelper.isInsideSleepWindow(this)?"Active — favorites can reach you":String.format(Locale.getDefault(),"Scheduled — starts at %02d:%02d",prefs.getStartHour(),prefs.getStartMin()));}
    private void refresh(){if(tab==0){List<FavoriteContact> c=ContactsHelper.getStarredContacts(this);if(favAdp==null){favAdp=new FavoritesAdapter(c);mainRecycler.setAdapter(favAdp);}else favAdp.updateData(c);}else{List<CallLogEntry> l=prefs.getCallLog();if(logAdp==null){logAdp=new CallLogAdapter(l,()->{prefs.clearCallLog();logAdp.updateData(prefs.getCallLog());});mainRecycler.setAdapter(logAdp);}else logAdp.updateData(l);}}
}
EOF

# ── Resources ────────────────────────────────────────────────────────────────
cat > app/src/main/res/values/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?><resources><string name="app_name">Night Guardian</string></resources>
EOF

cat > app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?><resources><color name="bg_dark">#0F0F1A</color><color name="bg_card">#1E1E3A</color><color name="bg_pill">#2A2A4A</color><color name="text_primary">#E8E8FF</color><color name="text_muted">#7070A0</color><color name="accent_purple">#8080FF</color><color name="accent_green">#4DB870</color><color name="badge_green_bg">#1A3A20</color><color name="badge_gray_bg">#2A2A4A</color></resources>
EOF

cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?><resources><style name="Theme.NightGuardian" parent="Theme.Material3.Dark.NoActionBar"><item name="colorPrimary">@color/accent_purple</item><item name="colorPrimaryVariant">@color/bg_card</item><item name="colorOnPrimary">@color/text_primary</item><item name="colorSurface">@color/bg_card</item><item name="colorOnSurface">@color/text_primary</item><item name="android:windowBackground">@color/bg_dark</item><item name="android:statusBarColor">@color/bg_dark</item><item name="android:navigationBarColor">@color/bg_dark</item></style></resources>
EOF

cat > app/src/main/res/drawable/ic_moon.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?><vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="24dp" android:height="24dp" android:viewportWidth="24" android:viewportHeight="24"><path android:fillColor="#8080FF" android:pathData="M21,12.79A9,9 0,0 1,11.21 3,7 7,0 0,0 21,12.79Z"/></vector>
EOF

cat > app/src/main/res/drawable/card_bg.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?><shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="@color/bg_card"/><corners android:radius="16dp"/><stroke android:width="0.5dp" android:color="#3A3A6A"/></shape>
EOF

cat > app/src/main/res/drawable/time_pill_bg.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?><shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="@color/bg_pill"/><corners android:radius="10dp"/></shape>
EOF

cat > app/src/main/res/drawable/avatar_circle.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?><shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval"><solid android:color="@color/bg_card"/></shape>
EOF

cat > app/src/main/res/drawable/badge_green.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?><shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="@color/badge_green_bg"/><corners android:radius="6dp"/></shape>
EOF

cat > app/src/main/res/drawable/badge_gray.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?><shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="@color/badge_gray_bg"/><corners android:radius="6dp"/></shape>
EOF

# ── Launcher icons ───────────────────────────────────────────────────────────
ICON='<?xml version="1.0" encoding="utf-8"?><adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"><background android:drawable="@color/bg_dark"/><foreground android:drawable="@drawable/ic_moon"/></adaptive-icon>'
for d in mipmap-hdpi mipmap-mdpi mipmap-xhdpi mipmap-xxhdpi; do
  echo "$ICON" > app/src/main/res/$d/ic_launcher.xml
  echo "$ICON" > app/src/main/res/$d/ic_launcher_round.xml
done

# ── Layouts ──────────────────────────────────────────────────────────────────
cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:background="@color/bg_dark">
  <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="20dp" android:gravity="center_vertical">
    <TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="Night Guardian" android:textSize="20sp" android:textStyle="bold" android:textColor="@color/text_primary"/>
    <TextView android:layout_width="32dp" android:layout_height="32dp" android:text="🌙" android:textSize="20sp" android:gravity="center"/>
  </LinearLayout>
  <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:layout_marginStart="16dp" android:layout_marginEnd="16dp" android:layout_marginBottom="16dp" android:background="@drawable/card_bg" android:padding="16dp">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="center_vertical">
      <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Sleep mode" android:textSize="12sp" android:textColor="@color/text_muted"/>
        <TextView android:id="@+id/statusText" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Sleep mode is off" android:textSize="14sp" android:textColor="@color/text_primary"/>
      </LinearLayout>
      <com.google.android.material.materialswitch.MaterialSwitch android:id="@+id/sleepToggle" android:layout_width="wrap_content" android:layout_height="wrap_content"/>
    </LinearLayout>
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:layout_marginTop="12dp" android:gravity="center_vertical">
      <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:background="@drawable/time_pill_bg" android:orientation="vertical" android:padding="8dp" android:gravity="center" android:layout_marginEnd="4dp">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="from" android:textSize="10sp" android:textColor="@color/text_muted"/>
        <TextView android:id="@+id/startTimeText" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="22:30" android:textSize="18sp" android:textStyle="bold" android:textColor="@color/accent_purple" android:clickable="true" android:focusable="true"/>
      </LinearLayout>
      <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:background="@drawable/time_pill_bg" android:orientation="vertical" android:padding="8dp" android:gravity="center" android:layout_marginStart="4dp">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="until" android:textSize="10sp" android:textColor="@color/text_muted"/>
        <TextView android:id="@+id/endTimeText" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="07:00" android:textSize="18sp" android:textStyle="bold" android:textColor="@color/accent_purple" android:clickable="true" android:focusable="true"/>
      </LinearLayout>
    </LinearLayout>
  </LinearLayout>
  <com.google.android.material.tabs.TabLayout android:id="@+id/tabLayout" android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginStart="16dp" android:layout_marginEnd="16dp" android:layout_marginBottom="8dp" app:tabGravity="fill" app:tabMode="fixed" app:tabSelectedTextColor="@color/accent_purple" app:tabTextColor="@color/text_muted" app:tabIndicatorColor="@color/accent_purple" app:tabBackground="@color/bg_card">
    <com.google.android.material.tabs.TabItem android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Favorites ★"/>
    <com.google.android.material.tabs.TabItem android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Call Log"/>
  </com.google.android.material.tabs.TabLayout>
  <androidx.recyclerview.widget.RecyclerView android:id="@+id/mainRecycler" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1" android:paddingTop="4dp" android:clipToPadding="false"/>
</LinearLayout>
EOF

cat > app/src/main/res/layout/item_favorite.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="12dp" android:gravity="center_vertical" android:paddingStart="16dp" android:paddingEnd="16dp">
  <TextView android:id="@+id/avatarText" android:layout_width="40dp" android:layout_height="40dp" android:gravity="center" android:textSize="13sp" android:textStyle="bold" android:background="@drawable/avatar_circle"/>
  <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical" android:layout_marginStart="12dp">
    <TextView android:id="@+id/contactName" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="14sp" android:textColor="@color/text_primary"/>
    <TextView android:id="@+id/contactPhone" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="11sp" android:textColor="@color/text_muted"/>
  </LinearLayout>
  <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="★" android:textSize="14sp" android:textColor="#F0C040" android:layout_marginEnd="8dp"/>
  <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="bypass on" android:textSize="10sp" android:background="@drawable/badge_green" android:textColor="#4DB870" android:paddingStart="7dp" android:paddingEnd="7dp" android:paddingTop="3dp" android:paddingBottom="3dp"/>
</LinearLayout>
EOF

cat > app/src/main/res/layout/item_log_entry.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="12dp" android:gravity="center_vertical" android:paddingStart="16dp" android:paddingEnd="16dp">
  <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical">
    <TextView android:id="@+id/logName" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="14sp" android:textColor="@color/text_primary"/>
    <TextView android:id="@+id/logNumber" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="11sp" android:textColor="@color/text_muted"/>
  </LinearLayout>
  <LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="end">
    <TextView android:id="@+id/logBadge" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="10sp" android:paddingStart="7dp" android:paddingEnd="7dp" android:paddingTop="3dp" android:paddingBottom="3dp" android:layout_marginBottom="4dp"/>
    <TextView android:id="@+id/logTime" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="11sp" android:textColor="@color/text_muted"/>
  </LinearLayout>
</LinearLayout>
EOF

cat > app/src/main/res/layout/item_log_footer.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:padding="16dp" android:gravity="center">
  <TextView android:id="@+id/clearLogBtn" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Clear log" android:textSize="13sp" android:textColor="@color/text_muted" android:background="@drawable/time_pill_bg" android:paddingStart="20dp" android:paddingEnd="20dp" android:paddingTop="8dp" android:paddingBottom="8dp" android:clickable="true" android:focusable="true"/>
</LinearLayout>
EOF

echo "✅ All source files generated successfully!"
