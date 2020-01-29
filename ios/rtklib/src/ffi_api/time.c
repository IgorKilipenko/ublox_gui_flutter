#ifndef _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 199506
#endif

#include <stdarg.h>
#include <ctype.h>
#ifndef WIN32
#include <dirent.h>
#include <time.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/types.h>
#endif
#include "rtklib.h"

gtime_t* utc2gpst_ffi(gtime_t* time) {
    gtime_t gpsTime = utc2gpst(*time);
    gtime_t* res = (gtime_t*)malloc(sizeof(gtime_t));
	res->time = gpsTime.time;
    res->sec = gpsTime.sec;
	return res;
}