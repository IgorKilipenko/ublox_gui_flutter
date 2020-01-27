cmake_minimum_required(VERSION 3.4.1)  # for example

add_library( native_add

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ../../ios/rtklib/src/native_add.cpp )

set(SRC_DIR ../../ios/rtklib/src)



set(CTARGET -DENAGLO -DENAQZS -DENACMP -DENAGAL -DENAIRN -DNFREQ=3 -DSVR_REUSEADDR)
set(CFLAGS -Wall -O3 -ansi -pedantic -Wno-unused-but-set-variable -I${SRC_DIR} -I.. -DTRACE ${CTARGET} -g)


set(RTKLIB ${SRC_DIR}/rtkcmn.c ${SRC_DIR}/rtksvr.c ${SRC_DIR}/rtkpos.c ${SRC_DIR}/geoid.c 
            ${SRC_DIR}/solution.c ${SRC_DIR}/lambda.c ${SRC_DIR}/sbas.c ${SRC_DIR}/stream.c 
            ${SRC_DIR}/rcvraw.c ${SRC_DIR}/rtcm.c ${SRC_DIR}/rtcm2.c ${SRC_DIR}/rtcm3.c ${SRC_DIR}/rtcm3e.c 
            ${SRC_DIR}/preceph.c ${SRC_DIR}/options.c ${SRC_DIR}/pntpos.c ${SRC_DIR}/ppp.c ${SRC_DIR}/ppp_ar.c 
            ${SRC_DIR}/rcv/novatel.c ${SRC_DIR}/rcv/ublox.c ${SRC_DIR}/rcv/ss2.c ${SRC_DIR}/rcv/crescent.c 
            ${SRC_DIR}/rcv/skytraq.c ${SRC_DIR}/rcv/gw10.c ${SRC_DIR}/rcv/javad.c ${SRC_DIR}/rcv/nvs.c ${SRC_DIR}/rcv/binex.c 
            ${SRC_DIR}/rcv/rt17.c ${SRC_DIR}/ephemeris.c ${SRC_DIR}/rinex.c ${SRC_DIR}/ionex.c ${SRC_DIR}/qzslex.c 
            ${SRC_DIR}/tides.c ${SRC_DIR}/ppp_corr.c ${SRC_DIR}/rcv/septentrio.c ${SRC_DIR}/rcv/cmr.c ${SRC_DIR}/rcv/tersus.c)
set_source_files_properties(${RTKLIB}, PROPERTIES ${CFLAGS})
include_directories(${SRC_DIR})
add_library( rtklib_test SHARED ${RTKLIB})
