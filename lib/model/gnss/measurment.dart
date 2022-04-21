class MeasurmentItem {
  MeasurmentItem(
      {this.describeContents,
      this.accumulatedDeltaRangeMeters,
      this.accumulatedDeltaRangeState,
      this.accumulatedDeltaRangeUncertaintyMeters,
      this.automaticGainControlLevelDb,
      this.carrierFrequencyHz,
      this.cn0DbHz,
      this.codeType,
      this.constellationType,
      this.multipathIndicator,
      this.pseudorangeRateMetersPerSecond,
      this.pseudorangeRateUncertaintyMetersPerSecond,
      this.receivedSvTimeNanos,
      this.snrInDb,
      this.state,
      this.svid,
      this.timeOffsetNanos});
  final num describeContents;
  final num accumulatedDeltaRangeMeters;
  final num accumulatedDeltaRangeState;
  final num accumulatedDeltaRangeUncertaintyMeters;
  final num automaticGainControlLevelDb;
  final num carrierFrequencyHz;
  final num cn0DbHz;
  final String codeType;
  final num constellationType;
  final num multipathIndicator;
  final num pseudorangeRateMetersPerSecond;
  final num pseudorangeRateUncertaintyMetersPerSecond;
  final num receivedSvTimeNanos;
  final num snrInDb;
  final num state;
  final num svid;
  final num timeOffsetNanos;

  factory MeasurmentItem.fromList(List<dynamic> list) {
    assert(list != null);
    assert(list.length > RawMeasMapper.timeOffsetNanos);

    return MeasurmentItem(
        describeContents: list[RawMeasMapper.describeContents] as num,
        accumulatedDeltaRangeMeters:
            list[RawMeasMapper.accumulatedDeltaRangeMeters] as num,
        accumulatedDeltaRangeState:
            list[RawMeasMapper.accumulatedDeltaRangeState] as num,
        accumulatedDeltaRangeUncertaintyMeters:
            list[RawMeasMapper.accumulatedDeltaRangeUncertaintyMeters] as num,
        automaticGainControlLevelDb:
            list[RawMeasMapper.automaticGainControlLevelDb] as num,
        carrierFrequencyHz: list[RawMeasMapper.carrierFrequencyHz] as num,
        cn0DbHz: list[RawMeasMapper.cn0DbHz] as num,
        codeType: list[RawMeasMapper.codeType] as String,
        constellationType: list[RawMeasMapper.constellationType] as num,
        multipathIndicator: list[RawMeasMapper.multipathIndicator] as num,
        pseudorangeRateMetersPerSecond:
            list[RawMeasMapper.pseudorangeRateMetersPerSecond] as num,
        pseudorangeRateUncertaintyMetersPerSecond:
            list[RawMeasMapper.pseudorangeRateUncertaintyMetersPerSecond]
                as num,
        receivedSvTimeNanos: list[RawMeasMapper.receivedSvTimeNanos] as num,
        snrInDb: list[RawMeasMapper.snrInDb] as num,
        state: list[RawMeasMapper.state] as num,
        svid: list[RawMeasMapper.svid] as num,
        timeOffsetNanos: list[RawMeasMapper.timeOffsetNanos] as num);
  }
}

class RawMeasMapper {
  static final int describeContents = 0;
  static final int accumulatedDeltaRangeMeters = 1;
  static final int accumulatedDeltaRangeState = 2;
  static final int accumulatedDeltaRangeUncertaintyMeters = 3;
  static final int automaticGainControlLevelDb = 4;
  static final int carrierFrequencyHz = 5;
  static final int cn0DbHz = 6;
  static final int codeType = 7;
  static final int constellationType = 8;
  static final int multipathIndicator = 9;
  static final int pseudorangeRateMetersPerSecond = 10;
  static final int pseudorangeRateUncertaintyMetersPerSecond = 11;
  static final int receivedSvTimeNanos = 12;
  static final int snrInDb = 13;
  static final int state = 14;
  static final int svid = 15;
  static final int timeOffsetNanos = 16;
}