package com.zad.islamic

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android re-delivers the original launch intent — including the
        // deep-link URI that first opened the app — whenever the activity is
        // resumed from recents/history or the launcher reuses the task
        // (amplified by launchMode="singleTop"). Left untouched, app_links'
        // getInitialLink() returns that stale invite link on every cold start,
        // wrongly routing into the team-join flow on each app open.
        //
        // FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY is set only on those reuse
        // launches, never on a genuine link tap, so clearing the data in that
        // case honors deep links only when actually opened via a link.
        val fromHistory =
            ((intent?.flags ?: 0) and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0
        if (fromHistory) {
            intent?.data = null
        }
        super.onCreate(savedInstanceState)
    }
}
