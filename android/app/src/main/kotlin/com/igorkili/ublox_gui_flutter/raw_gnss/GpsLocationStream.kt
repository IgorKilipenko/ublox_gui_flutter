
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
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant


import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.BinaryMessenger

import androidx.annotation.Nullable
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager

import android.os.Handler;
import android.os.Looper;
import android.app.Activity

import android.util.Log


class GpsLocationStream(context: Context, activity: Activity,  minTime: Long = 1000L, minDistance: Float = 0.0f) : StreamHandler, MethodCallHandler  {
    private val _mContext = context
    private val _mActivity = activity

    private var _minTime :Long = minTime
    private var _minDistance :Float = minDistance

    private var _locationListener: GpsLocationListener? = null
    private var _locationManager: LocationManager? = null

    private var _streamEnabled = false;

    companion object {
        @JvmStatic 
        private val TAG = "GpsLocationStream"
        @JvmStatic 
        val STREAM_CHANNEL = "ublox_gui_flutter/gps_location/events"
        @JvmStatic 
        val METHOD_CHANNEL = "ublox_gui_flutter/gps_location/methods"
        @JvmStatic 
        private val LOCATION_PERMISSION_REQUEST = 1
        @JvmStatic 
        private val REQUIRED_PERMISSIONS = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION
        )
        @JvmStatic
        fun registerStreamWith(registrar: Registrar, minTime: Long = 1000L, minDistance: Float = 0.0f) : GpsLocationStream {
            return registerStreamWith(registrar.context(), registrar.activity(), registrar.messenger(), minTime, minDistance)
        }
        @JvmStatic
        fun registerStreamWith(context: Context, activity: Activity, messenger : BinaryMessenger, minTime: Long = 1000L, minDistance: Float = 0.0f) : GpsLocationStream {
            val plugin = GpsLocationStream(context, activity, minTime, minDistance)
            val channel = EventChannel(messenger, STREAM_CHANNEL)
            val methodChannel = MethodChannel(messenger,METHOD_CHANNEL)
            channel.setStreamHandler(plugin)
            methodChannel.setMethodCallHandler(plugin)
            return plugin
        }
        @JvmStatic
        fun checkPermission(context: Context, activity: Activity) {
            if (context.checkSelfPermission(REQUIRED_PERMISSIONS[0])
                != PackageManager.PERMISSION_GRANTED) {
                // Request permissions from the user
                activity.requestPermissions(
                    REQUIRED_PERMISSIONS,
                    LOCATION_PERMISSION_REQUEST
                )
            }
        }
    }

    //public fun start() {
    //    if (_streamEnabled) return
    //    val channel = EventChannel(messenger, STREAM_CHANNEL)
    //    _streamEnabled = channel.setStreamHandler(plugin)
    //}

    override fun onListen(arguments: Any?, sink: EventSink?) {
        Log.w(TAG, "onListen start")
        if (sink != null) {
            checkPermission(_mContext, _mActivity)
            _locationManager = _mContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            _locationManager?.requestLocationUpdates(LocationManager.GPS_PROVIDER, _minTime, _minDistance, GpsLocationListener(sink as EventSink) as? LocationListener, Looper.getMainLooper())
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.w(TAG, "onCancel start")
        if (_locationListener != null) {
            _locationManager?.removeUpdates(_locationListener);
        }
    }

    override fun onMethodCall(call : MethodCall, result : MethodChannel.Result) {
        when (call.method) {
            "stop" -> onCancel(null)
            //"start" -> 
        }

    }

    class GpsLocationListener(var sink: EventSink) : LocationListener {
        override fun onLocationChanged(location: Location) {
            sink.success("${location.getLatitude()}\t${location.getLongitude()}")
        }

        override fun onProviderDisabled(provider: String?) {
            sink.success("onProviderDisabled")
        }

        override fun onProviderEnabled(provider: String?) {
            sink.success("onProviderEnabled")
        }

        override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
    }
}