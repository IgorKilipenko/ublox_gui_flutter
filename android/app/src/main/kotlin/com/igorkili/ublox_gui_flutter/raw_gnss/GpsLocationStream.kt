
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


class GpsLocationStream private constructor (context: Context, activity: Activity,  minTime: Long = 1000L, minDistance: Float = 0.0f) : StreamHandler, MethodCallHandler  {
    private val _mContext : Context
    private val _mActivity : Activity

    private var _minTime :Long
    private var _minDistance :Float

    private var _locationListener: GpsLocationListener?
    private var _locationManager: LocationManager

    init {
        _mContext = context
        _mActivity = activity
        _minTime = minTime
        _minDistance = minDistance
        _locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        _locationListener = null;
    }

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

    override fun onListen(arguments: Any?, sink: EventSink?) {
        Log.w(TAG, "onListen start")
        if (sink != null) {
            checkPermission(_mContext, _mActivity)
            /*_locationManager = _mContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager*/
            _locationListener = GpsLocationListener(sink as EventSink)
            _locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, _minTime, _minDistance, _locationListener as LocationListener, Looper.getMainLooper())
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.w(TAG, "onCancel start")
        if (_locationListener != null) {
            _locationManager.removeUpdates(_locationListener);
        }
    }

    override fun onMethodCall(call : MethodCall, result : MethodChannel.Result) {
        when (call.method) {
            "stop" -> {
                onCancel(null)
                result.success("canceled")
            }
            "getGpsProviders" -> {
                val providers: List<String> = getGpsProviders()
                result.success(providers)
            }
            "isLocationEnabled" -> {
                val locationEnabled: Boolean = isLocationEnabled()
                result.success(locationEnabled)
            }
            else -> result.notImplemented()
        }
    }

    private fun getGpsProviders(): List<String> {
        val gpsProviders: List<String> = _locationManager.getProviders(true)
        return gpsProviders
    }

    private fun getGpsProvider(): LocationProvider {
        val gpsProvider = _locationManager.getProvider(LocationManager.GPS_PROVIDER);
        return gpsProvider
    }

    private fun isLocationEnabled(): Boolean {
        val enabled: Boolean
        enabled = _locationManager.isLocationEnabled()
        return enabled
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