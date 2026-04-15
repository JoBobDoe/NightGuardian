# Night Guardian — Android App

Automatically rings at full volume for your starred contacts even when your phone is on silent during sleep hours.

---

## How it works

1. You set a sleep window (e.g. 22:30 – 07:00) and enable sleep mode.
2. The app schedules daily alarms that start/stop a background foreground service.
3. When a call arrives, the service checks if the caller is a **starred contact** in your phonebook.
4. If yes → temporarily boosts ringer to maximum volume so the call rings through.
5. If no → stays silent. After the call ends, your original ringer state is restored.
6. A log of all calls during sleep mode (bypassed + blocked) is saved in the app.

---

## Requirements

- Android 8.0 (API 26) or higher
- Android Studio Hedgehog (2023.1.1) or newer
- Java 11

---

## Setup in Android Studio

1. **Open the project**
   - Launch Android Studio → `File > Open` → select the `NightGuardian` folder.

2. **Sync Gradle**
   - Click "Sync Now" in the yellow banner, or `File > Sync Project with Gradle Files`.

3. **Run on a device or emulator**
   - Connect your Android phone via USB (enable Developer Options + USB Debugging).
   - Click the green ▶ Run button.

---

## Permissions the app requests

| Permission | Why it's needed |
|---|---|
| `READ_CONTACTS` | To fetch your starred/favorite contacts |
| `READ_PHONE_STATE` | To detect incoming calls and caller number |
| `FOREGROUND_SERVICE` | To keep the monitor alive during sleep hours |
| `MODIFY_AUDIO_SETTINGS` | To boost ringer volume for bypass calls |
| `ACCESS_NOTIFICATION_POLICY` | To override Do Not Disturb mode |
| `RECEIVE_BOOT_COMPLETED` | To re-enable monitoring after a phone restart |
| `SCHEDULE_EXACT_ALARM` | To trigger sleep window at the exact right time |
| `POST_NOTIFICATIONS` | To show the persistent status notification (Android 13+) |

### Important: Do Not Disturb access
The app will prompt you to grant **Do Not Disturb access** in system settings — this is required for the ringer override to work when DND is active. Without it, the call will still ring through on silent mode, but not through DND.

---

## How to mark contacts as favorites

Night Guardian uses the system **starred contacts** list — the same contacts you star in the Google Contacts or Phone app.

**To star a contact:**
- Open the Google Contacts app → find the person → tap the ★ star icon.
- Or open the Phone app → Contacts → find the person → tap ★.

The app reads this list automatically — no manual import needed.

---

## Project structure

```
app/src/main/java/com/nightguardian/app/
├── model/
│   ├── FavoriteContact.java     — data class for a starred contact
│   └── CallLogEntry.java        — data class for a call log record
├── util/
│   ├── Prefs.java               — SharedPreferences wrapper (settings + log)
│   ├── ContactsHelper.java      — reads starred contacts, phone number matching
│   └── ScheduleHelper.java      — alarm scheduling, sleep window detection
├── service/
│   └── CallMonitorService.java  — foreground service: core call interception logic
├── receiver/
│   ├── BootReceiver.java        — restarts service after device reboot
│   └── SleepScheduleReceiver.java — handles alarm-triggered start/stop
└── ui/
    ├── MainActivity.java        — main screen: toggle, schedule, tabs
    ├── FavoritesAdapter.java    — RecyclerView adapter for favorites list
    └── CallLogAdapter.java      — RecyclerView adapter for call log
```

---

## Known limitations & notes

- **MIUI / HyperOS (Xiaomi):** Aggressive battery optimisation can kill foreground services. Go to `Settings > Apps > Night Guardian > Battery saver` and set to "No restrictions".
- **Samsung One UI:** Similar — go to `Settings > Device Care > Battery > Background usage limits` and exclude Night Guardian.
- **Android 14+ exact alarms:** On Android 14, `USE_EXACT_ALARM` is declared in the manifest. If alarms don't fire, check `Settings > Apps > Special app access > Alarms & reminders`.
- **DND priority mode:** For full bypass of DND, grant Notification Policy access when prompted.

---

## Extending the app

- **Custom bypass list** (beyond starred): Add a Room database to store a separate bypass list independent of the contacts star.
- **Widget**: A home screen widget to toggle sleep mode without opening the app.
- **Wear OS companion**: Mirror the toggle on a smartwatch.
- **Second ring attempt**: If a favorite calls and hangs up within 10 seconds (common "emergency" pattern), auto-call them back.
