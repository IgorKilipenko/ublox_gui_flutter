package com.example.ublox_gui_flutter

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

// FLITTER SECTION
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    
    private val BATTERY_CHANNEL = "samples.flutter.dev/battery"
    private val CHANNEL_RAW_GNSS = "samples.flutter.dev/gnss_measurement"

    private lateinit var _batteryManager : BatteryManager
    private lateinit var _locationManager : LocationManager
    //private lateinit var _sensorManager : SensorManager

    private lateinit var _gnssMeasurementsListener : GnssMeasurementsEvent.Callback

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        init()

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_RAW_GNSS).setMethodCallHandler {
          // Note: this method is invoked on the main thread.
          call, result ->
          if (call.method == "getGpsProviders") {
            val providers : List<String> = getGpsProviders()
            result.success(providers)
          }  else if (call.method == "isLocationEnabled") {
            val locationEnabled : Boolean = isLocationEnabled()
            result.success(locationEnabled)
          }
          else {
            result.notImplemented()
          }
        }
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
        val gpsProviders :List<String> = _locationManager.getProviders(true)
        return gpsProviders
    }

    private fun getGpsProvider(): LocationProvider {
        ///////val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val gpsProvider = _locationManager.getProvider(LocationManager.GPS_PROVIDER);
        return gpsProvider
    }

    private fun isLocationEnabled(): Boolean{
        val enabled: Boolean
        //////val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        enabled = _locationManager.isLocationEnabled()
        return enabled
    }

    private fun init() {
        _batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        _locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        /////_sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }

    private fun addGnssMeasurementsListener() {
        _gnssMeasurementsListener = object: GnssMeasurementsEvent.Callback() {
            override fun onGnssMeasurementsReceived(event : GnssMeasurementsEvent ) {
                
            } 
        }
    }
}
