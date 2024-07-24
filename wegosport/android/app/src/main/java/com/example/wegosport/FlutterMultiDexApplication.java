package com.example.wegosport;

import androidx.multidex.MultiDex;
import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class FlutterMultiDexApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        MultiDex.install(this);
    }
}
