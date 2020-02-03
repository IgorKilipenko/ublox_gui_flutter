package com.igorkili.ublox_gui_flutter.raw_gnss

import android.Manifest
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter

import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES

// GNSS SECTION 
// https://github.com/barbeau/gpstest/blob/master/GPSTest/src/main/java/com/android/gpstest/GpsTestActivity.java
//import android.hardware.Sensor
//import android.hardware.SensorEvent
//import android.hardware.SensorEventListener
//import android.hardware.SensorManager
import android.location.GnssMeasurement
import android.location.GnssMeasurementsEvent
import android.location.GnssNavigationMessage
import android.location.GnssStatus
import android.location.GpsStatus
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.location.LocationProvider
//import android.location.OnNmeaMessageListener
import android.content.BroadcastReceiver;
import android.os.Bundle;

// FLITTER SECTION
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.GeneratedPluginRegistrant


import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.PluginRegistry.Registrar

import androidx.annotation.Nullable
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager

import android.os.Handler;
import android.os.Looper;
import android.app.Activity

import android.util.Log

class GnssRawDataStream(context: Context, activity: Activity) : StreamHandler  {
    private val _mContext = context
    private val _mActivity = activity

    private var _gnssMeasurementsListener: GnssMeasurementsEvent.Callback? = null
    private var _locationManager: LocationManager? = null

    companion object {
        @JvmStatic private val TAG = "GnssRawChannel"
        @JvmStatic val GNSS_STREAM_CHANNEL = "ublox_gui_flutter/gnss_raw_data_stream"
        @JvmStatic private val LOCATION_PERMISSION_REQUEST = 1
        @JvmStatic private val REQUIRED_PERMISSIONS = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION
        )
        @JvmStatic
        fun registerStreamWith(registrar: Registrar) {
            val plugin = GnssRawDataStream(registrar.context(), registrar.activity())
            val channel = EventChannel(registrar.messenger(), GNSS_STREAM_CHANNEL)
            channel.setStreamHandler(plugin)
        }
        @JvmStatic
        fun registerStreamWith(context: Context, activity: Activity, messenger : BinaryMessenger) {
            val plugin = GnssRawDataStream(context, activity)
            val channel = EventChannel(messenger, GNSS_STREAM_CHANNEL)
            channel.setStreamHandler(plugin)
        }
    }

    fun checkPermission() {
        if (_mContext.checkSelfPermission(REQUIRED_PERMISSIONS[0])
            != PackageManager.PERMISSION_GRANTED) {
            // Request permissions from the user
            _mActivity?.requestPermissions(
                REQUIRED_PERMISSIONS,
                LOCATION_PERMISSION_REQUEST
            )
        }
    }

    override fun onListen(arguments: Any?, sink: EventSink?) {
        Log.w(TAG, "onListen start")
        if (sink != null) {
            _startListenRawData(sink as EventSink);
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.w(TAG, "onCancel start")
        _stopListenRawData()
    }

    private fun _startListenRawData(sink: EventSink) {
        checkPermission()
        _locationManager = _mContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        var handler : Handler = Handler(Looper.getMainLooper())
        _gnssMeasurementsListener = GnssMeasurementsListener(sink)
        _locationManager?.registerGnssMeasurementsCallback(_gnssMeasurementsListener as GnssMeasurementsEvent.Callback, handler)
    }

    private fun _stopListenRawData() {
        if (_gnssMeasurementsListener != null) {
            _locationManager?.unregisterGnssMeasurementsCallback(_gnssMeasurementsListener as GnssMeasurementsEvent.Callback)
        }
    }

    class GnssMeasurementsListener(var sink: EventSink) : GnssMeasurementsEvent.Callback() {
        override fun onGnssMeasurementsReceived(event: GnssMeasurementsEvent) {
            
            for (m : GnssMeasurement in event.getMeasurements()) {
                sink.success("SVID -> ${m.getSvid()}\nFrequencyHz -> ${m.getCarrierFrequencyHz()}")
            }
        }

        override fun onStatusChanged(status: Int) {
            sink.success(status)
        }
    }
}
