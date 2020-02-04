class Position {
  Position({
    this.longitude,
    this.latitude,
    this.timestamp,
    this.mocked,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    this.speedAccuracy,
  });

  /// The latitude of this position in degrees normalized to the interval -90.0 to +90.0 (both inclusive).
  final double latitude;

  /// The longitude of the position in degrees normalized to the interval -180 (exclusive) to +180 (inclusive).
  final double longitude;

  /// The time at which this position was determined.
  final DateTime timestamp;

  ///Indicate if position was created from a mock provider.
  ///
  /// The mock information is not available on all devices. In these cases the returned value is false.
  final bool mocked;

  /// The altitude of the device in meters.
  ///
  /// The altitude is not available on all devices. In these cases the returned value is 0.0.
  final double altitude;

  /// The estimated horizontal accuracy of the position in meters.
  ///
  /// The accuracy is not available on all devices. In these cases the value is 0.0.
  final double accuracy;

  /// The heading in which the device is traveling in degrees.
  ///
  /// The heading is not available on all devices. In these cases the value is 0.0.
  final double heading;

  /// The speed at which the devices is traveling in meters per second over ground.
  ///
  /// The speed is not available on all devices. In these cases the value is 0.0.
  final double speed;

  /// The estimated speed accuracy of this position, in meters per second.
  ///
  /// The speedAccuracy is not available on all devices. In these cases the value is 0.0.
  final double speedAccuracy;
}
