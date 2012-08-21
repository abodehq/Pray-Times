//--------------------- Copyright Block ----------------------
/* 

PrayTime.h: Prayer Times Calculator (ver 1.2)
Copyright (C) 2007-2010 PrayTimes.org

Objective C Code By: Hussain Ali Khan
Original JS Code By: Hamid Zarrabi-Zadeh

License: GNU LGPL v3.0

TERMS OF USE:
	Permission is granted to use this code, with or 
	without modification, in any website or application 
	provided that credit is given to the original work 
	with a link back to PrayTimes.org.

This program is distributed in the hope that it will 
be useful, but WITHOUT ANY WARRANTY. 

PLEASE DO NOT REMOVE THIS COPYRIGHT BLOCK.

*/

#import <Foundation/Foundation.h>


@interface PrayTime : NSObject {
	// Calculation Methods
	NSInteger Jafari;    // Ithna Ashari
	NSInteger Karachi;    // University of Islamic Sciences, Karachi
	NSInteger ISNA;    // Islamic Society of North America (ISNA)
	NSInteger MWL;    // Muslim World League (MWL)
	NSInteger Makkah;    // Umm al-Qura, Makkah
	NSInteger Egypt;    // Egyptian General Authority of Survey
	NSInteger Custom;    // Custom Setting
	NSInteger Tehran;    // Institute of Geophysics, University of Tehran
	
	// Juristic Methods
	NSInteger Shafii;    // Shafii (standard)
	NSInteger Hanafi;    // Hanafi
	
	// Adjusting Methods for Higher Latitudes
	NSInteger None;    // No adjustment
	NSInteger MidNight;    // middle of night
	NSInteger OneSeventh;    // 1/7th of night
	NSInteger AngleBased;    // angle/60th of night
	
	
	// Time Formats
	NSInteger Time24;    // 24-hour format
	NSInteger Time12;    // 12-hour format
	NSInteger Time12NS;    // 12-hour format with no suffix
	NSInteger Float;    // floating point number
	
	
	// Time Names
	NSMutableArray *timeNames;
	
	NSString *InvalidTime;	 // The string used for invalid times
	
	
	//--------------------- Technical Settings --------------------
	
	NSInteger numIterations;		// number of iterations needed to compute times
	
	//------------------- Calc Method Parameters --------------------
	
	
	NSMutableDictionary *methodParams;
	
	/*  this.methodParams[methodNum] = new Array(fa, ms, mv, is, iv);	
	 
	 fa : fajr angle
	 ms : maghrib selector (0 = angle; 1 = minutes after sunset)
	 mv : maghrib parameter value (in angle or minutes)
	 is : isha selector (0 = angle; 1 = minutes after maghrib)
	 iv : isha parameter value (in angle or minutes)
	 */
	NSMutableArray *prayerTimesCurrent;
	NSMutableArray *offsets;
}
@property (assign) NSInteger Jafari;
@property (assign) NSInteger Karachi;
@property (assign) NSInteger ISNA;
@property (assign) NSInteger MWL;
@property (assign) NSInteger Makkah;
@property (assign) NSInteger Egypt;
@property (assign) NSInteger Custom;
@property (assign) NSInteger Tehran;

@property (assign) NSInteger Shafii;
@property (assign) NSInteger Hanafi;

@property (assign) NSInteger None;
@property (assign) NSInteger MidNight;
@property (assign) NSInteger OneSeventh;
@property (assign) NSInteger AngleBased;

@property (assign) NSInteger Time24;
@property (assign) NSInteger Time12;
@property (assign) NSInteger Time12NS;
@property (assign) NSInteger Float;

@property (readonly, readonly) NSMutableArray *timeNames;
@property (readonly, readonly) NSString *InvalidTime;

@property (assign) NSInteger numIterations;

@property (readonly, readonly) NSMutableDictionary *methodParams;

@property (nonatomic, retain) NSMutableArray *prayerTimesCurrent;
@property (nonatomic, retain) NSMutableArray *offsets;

//---------------------- Trigonometric Functions -----------------------
-(double) radiansToDegrees:(double)alpha;
-(double) DegreesToRadians:(double)alpha;
-(double) fixangle: (double)a;
-(double) fixhour: (double)a;
-(double)dsin: (double) d;
-(double)dcos: (double) d;
-(double)dtan: (double) d;
-(double)darcsin: (double) x;
-(double)darccos: (double) x;
-(double)darctan: (double) x;
-(double)darccot: (double) x;
-(double)darctan2: (double)y andX: (double) x;

//---------------------- Time-Zone Functions -----------------------
-(double)getTimeZone;
-(double)getBaseTimeZone;
-(double)detectDaylightSaving;

//---------------------- Julian Date Functions -----------------------
-(double) julianDate: (int)year andMonth:(int)month andDay:(int)day;
-(double)calcJD: (int)year andMonth:(int)month andDay:(int)day;

//---------------------- Calculation Functions -----------------------
-(NSMutableArray*)sunPosition: (double) jd;
-(double)equationOfTime: (double)jd;
-(double)sunDeclination: (double)jd;
-(double)computeMidDay: (double) t;
-(double)computeTime: (double)G andTime: (double)t;
-(double)computeAsr: (double)step andTime:(double)t;

//---------------------- Misc Functions -----------------------
-(double)timeDiff:(double)time1 andTime2:(double) time2;

//-------------------- Interface Functions --------------------
-(NSMutableArray*)getDatePrayerTimes:(int)year andMonth:(int)month andDay:(int)day andLatitude:(double)latitude andLongitude:(double)longitude andtimeZone:(double)tZone;
-(NSMutableArray*)getPrayerTimes: (NSDateComponents*)date andLatitude:(double)latitude andLongitude:(double)longitude andtimeZone:(double)tZone;
-(void)setCalcMethod: (int)methodID;
-(void)setAsrMethod: (int)methodID;
-(void)setCustomParams: (NSMutableArray*)params;
-(void)setFajrAngle:(double)angle;
-(void)setMaghribAngle:(double)angle;
-(void)setIshaAngle:(double)angle;
-(void)setDhuhrMinutes:(double)minutes;
-(void)setMaghribMinutes:(double)minutes;
-(void)setIshaMinutes:(double)minutes;
-(void)setHighLatsMethod:(int)methodID;
-(void)setTimeFormat: (int)tFormat;
-(NSString*)floatToTime24:(double)time;
-(NSString*)floatToTime12:(double)time andnoSuffix:(BOOL)noSuffix;
-(NSString*)floatToTime12NS:(double)time;

//---------------------- Compute Prayer Times -----------------------
-(NSMutableArray*)computeTimes:(NSMutableArray*)times;
-(NSMutableArray*)computeDayTimes;
-(NSMutableArray*)adjustTimes:(NSMutableArray*)times;
-(NSMutableArray*)adjustTimesFormat:(NSMutableArray*)times;
-(NSMutableArray*)adjustHighLatTimes:(NSMutableArray*)times;
-(double)nightPortion:(double)angle;
-(NSMutableArray*)dayPortion:(NSMutableArray*)times;
-(void)tune:(NSMutableDictionary*)offsets;
-(NSMutableArray*)tuneTimes:(NSMutableArray*)times;

@end
