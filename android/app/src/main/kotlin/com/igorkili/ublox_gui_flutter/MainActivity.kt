//package com.example.ublox_gui_flutter
package com.igorkili.ublox_gui_flutter

import com.igorkili.ublox_gui_flutter.raw_gnss.GnssRawDataStream
import com.igorkili.ublox_gui_flutter.raw_gnss.GpsLocationStream

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
//import android.location.GnssNavigationMessage
//import android.location.GnssStatus
//import android.location.GpsStatus
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
import io.flutter.plugins.GeneratedPluginRegistrant

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.PluginRegistry.Registrar

import androidx.annotation.Nullable
import androidx.annotation.RequiresApi
//import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager

import android.os.Handler;
import android.os.Looper;


import android.util.Log

@RequiresApi(api = 28)
class MainActivity: FlutterActivity() {

    private val BATTERY_CHANNEL = "samples.flutter.dev/battery"
    private val RAW_GNSS_CHENNEL = "samples.flutter.dev/gnss_measurement"
    private val GNSS_STREAM_CHANNEL = "ublox_gui_flutter/gnss_measurement_stream"

    private lateinit var _batteryManager: BatteryManager
    private lateinit var _locationManager: LocationManager
    //private lateinit var _sensorManager : SensorManager

    private lateinit var _gnssMeasurementsListener: GnssMeasurementsEvent.Callback

    private val LOCATION_PERMISSION_REQUEST = 1
    private val REQUIRED_PERMISSIONS = arrayOf(
        Manifest.permission.ACCESS_FINE_LOCATION
    )

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        _init()
        Log.w("DEBUG", "adding listener")

        var rawStream = GnssRawDataStream.registerStreamWith(this.context, this, flutterEngine.dartExecutor.binaryMessenger)
        var locationStream = GpsLocationStream.registerStreamWith(this.context, this, flutterEngine.dartExecutor.binaryMessenger)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }

        //////////////MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RAW_GNSS_CHENNEL).setMethodCallHandler {
        //////////////    // Note: this method is invoked on the main thread.
        //////////////    call, result ->
        //////////////    if (call.method == "getGpsProviders") {
        //////////////        val providers: List<String> = getGpsProviders()
        //////////////        result.success(providers)
        //////////////    } else if (call.method == "isLocationEnabled") {
        //////////////        val locationEnabled: Boolean = isLocationEnabled()
        //////////////        result.success(locationEnabled)
        //////////////    } else {
        //////////////        result.notImplemented()
        //////////////    }
        //////////////}
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


    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            //////val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = _batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }

    private fun getGpsProviders(): List<String> {
        ///////val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val gpsProviders: List<String> = _locationManager.getProviders(true)
        return gpsProviders
    }

    private fun getGpsProvider(): LocationProvider {
        ///////val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val gpsProvider = _locationManager.getProvider(LocationManager.GPS_PROVIDER);
        return gpsProvider
    }

    private fun isLocationEnabled(): Boolean {
        val enabled: Boolean
        //////val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        enabled = _locationManager.isLocationEnabled()
        return enabled
    }

    private fun _init() {
        if (ContextCompat.checkSelfPermission(this, REQUIRED_PERMISSIONS[0])
            != PackageManager.PERMISSION_GRANTED) {
            // Request permissions from the user
            ActivityCompat.requestPermissions(
                this,
                REQUIRED_PERMISSIONS,
                LOCATION_PERMISSION_REQUEST
            )
        }
        _batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        /////////////_locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        /////_sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }
}
