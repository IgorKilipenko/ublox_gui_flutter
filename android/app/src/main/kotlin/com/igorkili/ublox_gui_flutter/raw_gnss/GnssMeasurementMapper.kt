package com.igorkili.ublox_gui_flutter.raw_gnss
import android.location.GnssMeasurement

class GnssMeasurementMapper {
    companion object {
        val CODE : Int = 0x10
        val MapFields: HashMap<String, Int> = hashMapOf(
                "describeContents" to 0,
                "accumulatedDeltaRangeMeters" to 1,
                "accumulatedDeltaRangeState" to 2,
                "accumulatedDeltaRangeUncertaintyMeters" to 3,
                "automaticGainControlLevelDb" to 4,
                //"carrierCycles" to 5,
                "carrierFrequencyHz" to 5,
                //"carrierPhase" to 6,
                //"carrierPhaseUncertainty" to 7,
                "cn0DbHz" to 6,
                "codeType" to 7,
                "constellationType" to 8,
                "multipathIndicator" to 9,
                "pseudorangeRateMetersPerSecond" to 10,
                "pseudorangeRateUncertaintyMetersPerSecond" to 11,
                "receivedSvTimeNanos" to 12,
                "receivedSvTimeUncertaintyNanos" to 13,
                "snrInDb" to 14,
                "state" to 15,
                "svid" to 16,
                "timeOffsetNanos" to 17
        )
        fun map(measurement : GnssMeasurement) : List<Any> {
            val res : List<Any> = listOf(
                    measurement.describeContents(),
                    measurement.accumulatedDeltaRangeMeters,
                    measurement.accumulatedDeltaRangeState,
                    measurement.accumulatedDeltaRangeUncertaintyMeters,
                    measurement.automaticGainControlLevelDb,
                    measurement.carrierFrequencyHz,
                    measurement.cn0DbHz,
                    measurement.codeType,
                    measurement.constellationType,
                    measurement.multipathIndicator,
                    measurement.pseudorangeRateMetersPerSecond,
                    measurement.pseudorangeRateUncertaintyMetersPerSecond,
                    measurement.receivedSvTimeNanos,
                    measurement.snrInDb,
                    measurement.state,
                    measurement.svid,
                    measurement.timeOffsetNanos
            )
            return res
        }
    }
}