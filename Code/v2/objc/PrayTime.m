//--------------------- Copyright Block ----------------------
/* 

PrayTime.m: Prayer Times Calculator (ver 1.2)
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


#import "PrayTime.h"

//---------------------- Global Variables --------------------


int calcMethod   = 0;		// caculation method
int asrJuristic  = 0;		// Juristic method for Asr
int dhuhrMinutes = 0;		// minutes after mid-day for Dhuhr
int adjustHighLats = 1;	// adjusting method for higher latitudes

int timeFormat   = 0;		// time format

double lat;        // latitude 
double lng;        // longitude 
double timeZone;   // time-zone 
double JDate;      // Julian date

//------------------------------------------------------------

@implementation PrayTime

@synthesize Jafari;
@synthesize Karachi;
@synthesize ISNA;
@synthesize MWL;
@synthesize Makkah;
@synthesize Egypt;
@synthesize Custom;
@synthesize Tehran;

@synthesize Shafii;
@synthesize Hanafi;

@synthesize None;
@synthesize MidNight;
@synthesize OneSeventh;
@synthesize AngleBased;

@synthesize Time24;
@synthesize Time12;
@synthesize Time12NS;
@synthesize Float;

@synthesize timeNames;
@synthesize InvalidTime;

@synthesize numIterations;

@synthesize methodParams;

@synthesize prayerTimesCurrent;
@synthesize offsets;

-(id) init {
	self = [super init];
	
	if(self){
		// Calculation Methods
		Jafari     = 0;    // Ithna Ashari
		Karachi    = 1;    // University of Islamic Sciences, Karachi
		ISNA       = 2;    // Islamic Society of North America (ISNA)
		MWL        = 3;    // Muslim World League (MWL)
		Makkah     = 4;    // Umm al-Qura, Makkah
		Egypt      = 5;    // Egyptian General Authority of Survey
		Custom     = 7;    // Custom Setting
		Tehran     = 6;    // Institute of Geophysics, University of Tehran
		
		// Juristic Methods
		Shafii     = 0;    // Shafii (standard)
		Hanafi     = 1;    // Hanafi
		
		// Adjusting Methods for Higher Latitudes
		None       = 0;    // No adjustment
		MidNight   = 1;    // middle of night
		OneSeventh = 2;    // 1/7th of night
		AngleBased = 3;    // angle/60th of night
		
		
		// Time Formats
		Time24     = 0;    // 24-hour format
		Time12     = 1;    // 12-hour format
		Time12NS   = 2;    // 12-hour format with no suffix
		Float      = 3;    // floating ponumber
		
		// Time Names
		timeNames = [[[NSMutableArray alloc] init] autorelease];
		[timeNames addObject:@"Fajr"];
		[timeNames addObject:@"Sunrise"];
		[timeNames addObject:@"Dhuhr"];
		[timeNames addObject:@"Asr"];
		[timeNames addObject:@"Sunset"];
		[timeNames addObject:@"Maghrib"];
		[timeNames addObject:@"Isha"];
		
		InvalidTime = @"-----";	 // The string used for invalid times
		
		//--------------------- Technical Settings --------------------
		
		numIterations = 1;		// number of iterations needed to compute times
		
		//------------------- Calc Method Parameters --------------------
		
		//Tuning offsets
		offsets = [[[NSMutableArray alloc] init] autorelease];
		[offsets addObject:[NSNumber numberWithInt:0]];//fajr
		[offsets addObject:[NSNumber numberWithInt:0]];//sunrise
		[offsets addObject:[NSNumber numberWithInt:0]];//dhuhr
		[offsets addObject:[NSNumber numberWithInt:0]];//asr
		[offsets addObject:[NSNumber numberWithInt:0]];//sunset
		[offsets addObject:[NSNumber numberWithInt:0]];//maghrib
		[offsets addObject:[NSNumber numberWithInt:0]];//isha

		/*
		 
		 fa : fajr angle
		 ms : maghrib selector (0 = angle; 1 = minutes after sunset)
		 mv : maghrib parameter value (in angle or minutes)
		 is : isha selector (0 = angle; 1 = minutes after maghrib)
		 iv : isha parameter value (in angle or minutes)
		 */
		methodParams = [[[NSMutableDictionary alloc] initWithCapacity:8] autorelease];
		
		NSMutableArray *Jvalues = [[[NSMutableArray alloc] init] autorelease];
		//Jafari
		[Jvalues addObject:[NSNumber numberWithInt:16]];
		[Jvalues addObject:[NSNumber numberWithInt:0]];
		[Jvalues addObject:[NSNumber numberWithInt:4]];
		[Jvalues addObject:[NSNumber numberWithInt:0]];
		[Jvalues addObject:[NSNumber numberWithInt:14]];
		
		
		[methodParams setObject:Jvalues forKey:[NSNumber numberWithInt: Jafari]];
		
		
		//Karachi
		NSMutableArray *Kvalues = [[[NSMutableArray alloc] init] autorelease];
		[Kvalues addObject:[NSNumber numberWithInt:18]];
		[Kvalues addObject:[NSNumber numberWithInt:1]];
		[Kvalues addObject:[NSNumber numberWithInt:0]];
		[Kvalues addObject:[NSNumber numberWithInt:0]];
		[Kvalues addObject:[NSNumber numberWithInt:18]];
		
		
		[methodParams setObject:Kvalues forKey:[NSNumber numberWithInt: Karachi]];
		
		//ISNA
		NSMutableArray *Ivalues = [[[NSMutableArray alloc] init] autorelease];
		[Ivalues addObject:[NSNumber numberWithInt:15]];
		[Ivalues addObject:[NSNumber numberWithInt:1]];
		[Ivalues addObject:[NSNumber numberWithInt:0]];
		[Ivalues addObject:[NSNumber numberWithInt:0]];
		[Ivalues addObject:[NSNumber numberWithInt:15]];
		
		
		[methodParams setObject:Ivalues forKey:[NSNumber numberWithInt: ISNA]];
		
		
		//MWL
		NSMutableArray *Mvalues = [[[NSMutableArray alloc] init] autorelease];
		[Mvalues addObject:[NSNumber numberWithInt:18]];
		[Mvalues addObject:[NSNumber numberWithInt:1]];
		[Mvalues addObject:[NSNumber numberWithInt:0]];
		[Mvalues addObject:[NSNumber numberWithInt:0]];
		[Mvalues addObject:[NSNumber numberWithInt:17]];
		
		
		[methodParams setObject:Mvalues forKey:[NSNumber numberWithInt: MWL]];
		
		
		//Makkah
		NSMutableArray *Mavalues = [[[NSMutableArray alloc] init] autorelease];
		[Mavalues addObject:[NSNumber numberWithDouble:18.5]];
		[Mavalues addObject:[NSNumber numberWithInt:1]];
		[Mavalues addObject:[NSNumber numberWithInt:0]];
		[Mavalues addObject:[NSNumber numberWithInt:1]];
		[Mavalues addObject:[NSNumber numberWithInt:90]];
		
		
		[methodParams setObject:Mavalues forKey:[NSNumber numberWithInt: Makkah]];
		
		//Egypt
		NSMutableArray *Evalues = [[[NSMutableArray alloc] init] autorelease];
		[Evalues addObject:[NSNumber numberWithDouble:19.5]];
		[Evalues addObject:[NSNumber numberWithInt:1]];
		[Evalues addObject:[NSNumber numberWithInt:0]];
		[Evalues addObject:[NSNumber numberWithInt:0]];
		[Evalues addObject:[NSNumber numberWithDouble:17.5]];
		
		
		[methodParams setObject:Evalues forKey:[NSNumber numberWithInt: Egypt]];
		
		//Tehran
		NSMutableArray *Tvalues = [[[NSMutableArray alloc] init] autorelease];
		[Tvalues addObject:[NSNumber numberWithDouble:17.7]];
		[Tvalues addObject:[NSNumber numberWithInt:0]];
		[Tvalues addObject:[NSNumber numberWithDouble:4.5]];
		[Tvalues addObject:[NSNumber numberWithInt:0]];
		[Tvalues addObject:[NSNumber numberWithInt:14]];
		
		
		[methodParams setObject:Tvalues forKey:[NSNumber numberWithInt: Tehran]];
		
		
		//Custom
		NSMutableArray *Cvalues = [[[NSMutableArray alloc] init] autorelease];
		[Cvalues addObject:[NSNumber numberWithInt:18]];
		[Cvalues addObject:[NSNumber numberWithInt:1]];
		[Cvalues addObject:[NSNumber numberWithInt:0]];
		[Cvalues addObject:[NSNumber numberWithInt:0]];
		[Cvalues addObject:[NSNumber numberWithInt:17]];
		
		
		[methodParams setObject:Cvalues forKey:[NSNumber numberWithInt: Custom]];
		
		
	}
	return self;
}

//---------------------- Trigonometric Functions -----------------------

// range reduce angle in degrees.
-(double) fixangle: (double) a {
	
	a = a - (360 * (floor(a / 360.0)));
	
	a = a < 0 ? (a + 360) : a;
	return a;
}

// range reduce hours to 0..23
-(double) fixhour: (double) a {
	a = a - 24.0 * floor(a / 24.0);
	a = a < 0 ? (a + 24) : a;
	return a;
}

// radian to degree
-(double) radiansToDegrees:(double)alpha {
	return ((alpha*180.0)/M_PI);	
}

//deree to radian
-(double) DegreesToRadians:(double)alpha {
	return ((alpha*M_PI)/180.0);	
}

// degree sin
-(double)dsin: (double) d {
	return (sin([self DegreesToRadians:d]));
}

// degree cos
-(double)dcos: (double) d {
	return (cos([self DegreesToRadians:d]));
}

// degree tan
-(double)dtan: (double) d {
	return (tan([self DegreesToRadians:d]));
}

// degree arcsin
-(double)darcsin: (double) x {
	double val = asin(x);
	return [self radiansToDegrees: val];
}

// degree arccos
-(double)darccos: (double) x {
	double val = acos(x);
	return [self radiansToDegrees: val];
}

// degree arctan
-(double)darctan: (double) x {
	double val = atan(x);
	return [self radiansToDegrees: val];
}

// degree arctan2
-(double)darctan2: (double)y andX: (double) x {
	double val = atan2(y, x);
	return [self radiansToDegrees: val];
}

// degree arccot
-(double)darccot: (double) x {
	double val = atan2(1.0, x);
	return [self radiansToDegrees: val];
}

//---------------------- Time-Zone Functions -----------------------

// compute local time-zone for a specific date
-(double)getTimeZone {
	NSTimeZone *timeZone = [NSTimeZone localTimeZone];
	double hoursDiff = [timeZone secondsFromGMT]/3600.0f;
	return hoursDiff;
}

// compute base time-zone of the system
-(double)getBaseTimeZone {
	
	NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
	double hoursDiff = [timeZone secondsFromGMT]/3600.0f;
	return hoursDiff;
	
}

// detect daylight saving in a given date
-(double)detectDaylightSaving {
	NSTimeZone *timeZone = [NSTimeZone localTimeZone];
	double hoursDiff = [timeZone daylightSavingTimeOffsetForDate:[NSDate date]];
	return hoursDiff;
}

//---------------------- Julian Date Functions -----------------------

// calculate julian date from a calendar date
-(double) julianDate: (int)year andMonth:(int)month andDay:(int)day {
	
	if (month <= 2) 
	{
		year -= 1;
		month += 12;
	}
	double A = floor(year/100.0);
	
	double B = 2 - A + floor(A/4.0);
	
	double JD = floor(365.25 * (year+ 4716)) + floor(30.6001 * (month + 1)) + day + B - 1524.5;
		
	return JD;
}


// convert a calendar date to julian date (second method)
-(double)calcJD: (int)year andMonth:(int)month andDay:(int)day {
	double J1970 = 2440588;
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	[components setWeekday:day]; // Monday
	//[components setWeekdayOrdinal:1]; // The first day in the month
	[components setMonth:month]; // May
	[components setYear:year];
	NSCalendar *gregorian = [[[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDate *date1 = [gregorian dateFromComponents:components];
	
	double ms = [date1 timeIntervalSince1970];// # of milliseconds since midnight Jan 1, 1970
	double days = floor(ms/ (1000.0 * 60.0 * 60.0 * 24.0)); 
	return J1970+ days- 0.5;
}

//---------------------- Calculation Functions -----------------------

// References:
// http://www.ummah.net/astronomy/saltime  
// http://aa.usno.navy.mil/faq/docs/SunApprox.html


// compute declination angle of sun and equation of time
-(NSMutableArray*)sunPosition: (double) jd {
	
	double D = jd - 2451545;
	double g = [self fixangle: (357.529 + 0.98560028 * D)];
	double q = [self fixangle: (280.459 + 0.98564736 * D)];
	double L = [self fixangle: (q + (1.915 * [self dsin: g]) + (0.020 * [self dsin:(2 * g)]))];
	
	//double R = 1.00014 - 0.01671 * [self dcos:g] - 0.00014 * [self dcos: (2*g)];
	double e = 23.439 - (0.00000036 * D);
	double d = [self darcsin: ([self dsin: e] * [self dsin: L])];
	double RA = ([self darctan2: ([self dcos: e] * [self dsin: L]) andX: [self dcos:L]])/ 15.0;
	RA = [self fixhour:RA];
	
	double EqT = q/15.0 - RA;
	
	NSMutableArray *sPosition = [[[NSMutableArray alloc] init] autorelease];
	[sPosition addObject:[NSNumber numberWithDouble:d]];
	[sPosition addObject:[NSNumber numberWithDouble:EqT]];
	
	return sPosition;
}

// compute equation of time
-(double)equationOfTime: (double)jd {
	double eq = [[[self sunPosition:jd] objectAtIndex:1] doubleValue];
	return eq;
}

// compute declination angle of sun
-(double)sunDeclination: (double)jd {
	double d = [[[self sunPosition:jd] objectAtIndex:0] doubleValue];
	return d;
}

// compute mid-day (Dhuhr, Zawal) time
-(double)computeMidDay: (double) t {
	double T = [self equationOfTime:(JDate+ t)];
	double Z = [self fixhour: (12 - T)];
	return Z;
}

// compute time for a given angle G
-(double)computeTime: (double)G andTime: (double)t {
	
	double D = [self sunDeclination:(JDate+ t)];
	double Z = [self computeMidDay: t];
	double V = ([self darccos: (-[self dsin:G] - ([self dsin:D] * [self dsin:lat]))/ ([self dcos:D] * [self dcos:lat])]) / 15.0f;

	return Z+ (G>90 ? -V : V);
}

// compute the time of Asr
// Shafii: step=1, Hanafi: step=2
-(double)computeAsr: (double)step andTime:(double)t {
	double D = [self sunDeclination:(JDate+ t)];
	double G = -[self darccot : (step + [self dtan:ABS(lat-D)])];
	return [self computeTime:G andTime:t];
}

//---------------------- Misc Functions -----------------------


// compute the difference between two times 
-(double)timeDiff:(double)time1 andTime2:(double) time2 {
	return [self fixhour: (time2- time1)];
}

//-------------------- Interface Functions --------------------


// return prayer times for a given date
-(NSMutableArray*)getDatePrayerTimes:(int)year andMonth:(int)month andDay:(int)day andLatitude:(double)latitude andLongitude:(double)longitude andtimeZone:(double)tZone {
	lat = latitude;
	lng = longitude; 
	
	//timeZone = this.effectiveTimeZone(year, month, day, timeZone); 
	//timeZone = [self getTimeZone];
	timeZone = tZone;
	JDate = [self julianDate:year andMonth:month andDay:day];
	
	double lonDiff = longitude/(15.0 * 24.0);
	JDate = JDate - lonDiff;
	return [self computeDayTimes];
}

// return prayer times for a given date
-(NSMutableArray*)getPrayerTimes: (NSDateComponents*)date andLatitude:(double)latitude andLongitude:(double)longitude andtimeZone:(double)tZone {
	
	NSInteger year = [date year];
	NSInteger month = [date month];
	NSInteger day = [date day];
	return [self getDatePrayerTimes:year andMonth:month andDay:day andLatitude:latitude andLongitude:longitude andtimeZone:tZone];
}

// set the calculation method 
-(void)setCalcMethod: (int)methodID {
	calcMethod = methodID;
}

// set the juristic method for Asr
-(void)setAsrMethod: (int)methodID {
	if (methodID < 0 || methodID > 1)
		return;
	asrJuristic = methodID;
}

// set custom values for calculation parameters
-(void)setCustomParams: (NSMutableArray*)params {
	int i;
	id j;
	id Cust = [methodParams objectForKey: [NSNumber numberWithInt:Custom]]; 
	id cal = [methodParams objectForKey: [NSNumber numberWithInt:calcMethod]];
	for (i=0; i<5; i++)
	{
		j = [params objectAtIndex:i];
		if ([j isEqualToNumber: [NSNumber numberWithInt:-1]])			
			[Cust replaceObjectAtIndex:i withObject:[cal objectAtIndex:i]] ;
		
		else
			[Cust replaceObjectAtIndex:i withObject:[params objectAtIndex:i]];
	}
	calcMethod = Custom;
}

// set the angle for calculating Fajr
-(void)setFajrAngle:(double)angle {
	NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
	[params addObject:[NSNumber numberWithDouble:angle]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[self setCustomParams:params];
}

// set the angle for calculating Maghrib
-(void)setMaghribAngle:(double)angle {
	NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:0]];
	[params addObject:[NSNumber numberWithDouble:angle]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[self setCustomParams:params];
}

// set the angle for calculating Isha
-(void)setIshaAngle:(double)angle {
	NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:0]];
	[params addObject:[NSNumber numberWithDouble:angle]];
	[self setCustomParams:params];
}

// set the minutes after mid-day for calculating Dhuhr
-(void)setDhuhrMinutes:(double)minutes {
	dhuhrMinutes = minutes;
}

// set the minutes after Sunset for calculating Maghrib
-(void)setMaghribMinutes:(double)minutes {
	NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:1]];
	[params addObject:[NSNumber numberWithDouble:minutes]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[self setCustomParams:params];
}

// set the minutes after Maghrib for calculating Isha
-(void)setIshaMinutes:(double)minutes {
	NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:-1]];
	[params addObject:[NSNumber numberWithDouble:1]];
	[params addObject:[NSNumber numberWithDouble:minutes]];
	[self setCustomParams:params];
}

// set adjusting method for higher latitudes 
-(void)setHighLatsMethod:(int)methodID {
	adjustHighLats = methodID;
}

// set the time format 
-(void)setTimeFormat: (int)tFormat {
	timeFormat = tFormat;
}

// convert double hours to 24h format
-(NSString*)floatToTime24:(double)time {
	
	NSString *result = nil;
	
	if (isnan(time))
		return InvalidTime;
	
	time = [self fixhour:(time + 0.5/ 60.0)];  // add 0.5 minutes to round
	int hours = floor(time); 
	double minutes = floor((time - hours) * 60.0);
	
	if((hours >=0 && hours<=9) && (minutes >=0 && minutes <=9)){
		result = [NSString stringWithFormat:@"0%d:0%.0f",hours, minutes];
	}
	else if((hours >=0 && hours<=9)){
		result = [NSString stringWithFormat:@"0%d:%.0f",hours, minutes];
	}
	else if((minutes >=0 && minutes <=9)){
		result = [NSString stringWithFormat:@"%d:0%.0f",hours, minutes];
	}
	else{
		result = [NSString stringWithFormat:@"%d:%.0f",hours, minutes];
	}
	return result;
}

// convert double hours to 12h format
-(NSString*)floatToTime12:(double)time andnoSuffix:(BOOL)noSuffix {
	
	if (isnan(time))
		return InvalidTime;
	
	time =[self fixhour:(time+ 0.5/ 60)];  // add 0.5 minutes to round
	double hours = floor(time); 
	double minutes = floor((time- hours)* 60);
	NSString *suffix, *result=nil;
	if(hours >= 12) {
		suffix = @"pm";
	}
	else{
		suffix = @"am";
	}
	//hours = ((((hours+ 12) -1) % (12))+ 1);
	hours = (hours + 12) - 1;
	int hrs = (int)hours % 12;
	hrs += 1;
	if(noSuffix == NO){
		if((hrs >=0 && hrs<=9) && (minutes >=0 && minutes <=9)){
			result = [NSString stringWithFormat:@"0%d:0%.0f %@",hrs, minutes, suffix];
		}
		else if((hrs >=0 && hrs<=9)){
			result = [NSString stringWithFormat:@"0%d:%.0f %@",hrs, minutes, suffix];
		}
		else if((minutes >=0 && minutes <=9)){
			result = [NSString stringWithFormat:@"%d:0%.0f %@",hrs, minutes, suffix];
		}
		else{
			result = [NSString stringWithFormat:@"%d:%.0f %@",hrs, minutes, suffix];
		}
		
	}
	else{
		if((hrs >=0 && hrs<=9) && (minutes >=0 && minutes <=9)){
			result = [NSString stringWithFormat:@"0%d:0%.0f",hrs, minutes];
		}
		else if((hrs >=0 && hrs<=9)){
			result = [NSString stringWithFormat:@"0%d:%.0f",hrs, minutes];
		}
		else if((minutes >=0 && minutes <=9)){
			result = [NSString stringWithFormat:@"%d:0%.0f",hrs, minutes];
		}
		else{
			result = [NSString stringWithFormat:@"%d:%.0f",hrs, minutes];
		}
	}
	return result;
	
}

// convert double hours to 12h format with no suffix
-(NSString*)floatToTime12NS:(double)time {
	return [self floatToTime12:time andnoSuffix:YES];
}

//---------------------- Compute Prayer Times -----------------------


// compute prayer times at given julian date
-(NSMutableArray*)computeTimes:(NSMutableArray*)times {
	
	NSMutableArray *t = [self dayPortion:times];
	
	id obj = [[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]]retain];
	double idk = [[obj objectAtIndex:0] doubleValue];
	double Fajr    = [self computeTime:(180 - idk) andTime: [[t objectAtIndex:0] doubleValue]];
	double Sunrise = [self computeTime:(180 - 0.833) andTime: [[t objectAtIndex:1] doubleValue]];
	double Dhuhr   = [self computeMidDay: [[t objectAtIndex:2] doubleValue]];
	double Asr     = [self computeAsr:(1 + asrJuristic) andTime: [[t objectAtIndex:3] doubleValue]];
	double Sunset  = [self computeTime:0.833 andTime: [[t objectAtIndex:4] doubleValue]];
	double Maghrib = [self computeTime:[[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:2] doubleValue] andTime: [[t objectAtIndex:5] doubleValue]];
	double Isha    = [self computeTime:[[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:4] doubleValue] andTime: [[t objectAtIndex:6] doubleValue]];
	
	NSMutableArray *Ctimes = [[[NSMutableArray alloc] init] autorelease];
	[Ctimes addObject:[NSNumber numberWithDouble:Fajr]];
	[Ctimes addObject:[NSNumber numberWithDouble:Sunrise]];
	[Ctimes addObject:[NSNumber numberWithDouble:Dhuhr]];
	[Ctimes addObject:[NSNumber numberWithDouble:Asr]];
	[Ctimes addObject:[NSNumber numberWithDouble:Sunset]];
	[Ctimes addObject:[NSNumber numberWithDouble:Maghrib]];
	[Ctimes addObject:[NSNumber numberWithDouble:Isha]];
	
	[obj release];
	//Tune times here
	//Ctimes = [self tuneTimes:Ctimes];
	
	return Ctimes;
}

// compute prayer times at given julian date
-(NSMutableArray*)computeDayTimes {
	
	//int i = 0;
	NSMutableArray *t1, *t2, *t3;
	NSMutableArray *times = [[[NSMutableArray alloc] init] autorelease]; //default times
	[times addObject:[NSNumber numberWithDouble:5.0]];
	[times addObject:[NSNumber numberWithDouble:6.0]];
	[times addObject:[NSNumber numberWithDouble:12.0]];
	[times addObject:[NSNumber numberWithDouble:13.0]];
	[times addObject:[NSNumber numberWithDouble:18.0]];
	[times addObject:[NSNumber numberWithDouble:18.0]];
	[times addObject:[NSNumber numberWithDouble:18.0]];
	
	for (int i=1; i<= numIterations; i++)  
		t1 = [[self computeTimes:times] retain];
	
	t2 = [[self adjustTimes:t1] retain];
	
	t2 = [self tuneTimes:t2];
	
	//Set prayerTimesCurrent here!!
	prayerTimesCurrent = [[[NSMutableArray alloc] initWithArray:t2] retain];
	
	t3 = [[self adjustTimesFormat:t2] retain];
	
	[t1 release];
	[t2 release];
	
	return t3;
}

//Tune timings for adjustments
//Set time offsets
-(void)tune:(NSMutableDictionary*)offsetTimes{

	[offsets replaceObjectAtIndex:0 withObject:[offsetTimes objectForKey:@"fajr"]];
	[offsets replaceObjectAtIndex:1 withObject:[offsetTimes objectForKey:@"sunrise"]];
	[offsets replaceObjectAtIndex:2 withObject:[offsetTimes objectForKey:@"dhuhr"]];
	[offsets replaceObjectAtIndex:3 withObject:[offsetTimes objectForKey:@"asr"]];
	[offsets replaceObjectAtIndex:4 withObject:[offsetTimes objectForKey:@"sunset"]];
	[offsets replaceObjectAtIndex:5 withObject:[offsetTimes objectForKey:@"maghrib"]];
	[offsets replaceObjectAtIndex:6 withObject:[offsetTimes objectForKey:@"isha"]];
}

-(NSMutableArray*)tuneTimes:(NSMutableArray*)times{
	double off, time;
	for(int i=0; i<[times count]; i++){
		//if(i==5)
		//NSLog(@"Normal: %d - %@", i, [times objectAtIndex:i]);
		off = [[offsets objectAtIndex:i] doubleValue]/60.0;
		time = [[times objectAtIndex:i] doubleValue] + off;
		[times replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:time]];
		//if(i==5)
		//NSLog(@"Modified: %d - %@", i, [times objectAtIndex:i]);
	}
	
	return times;
}

// adjust times in a prayer time array
-(NSMutableArray*)adjustTimes:(NSMutableArray*)times {
	
	int i = 0;
	NSMutableArray *a; //test variable
	double time = 0, Dtime, Dtime1, Dtime2;
	
	for (i=0; i<7; i++) {
		time = ([[times objectAtIndex:i] doubleValue]) + (timeZone- lng/ 15.0);
		
		[times replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:time]];
		
	}
	
	Dtime = [[times objectAtIndex:2] doubleValue] + (dhuhrMinutes/ 60.0); //Dhuhr
		
	[times replaceObjectAtIndex:2 withObject:[NSNumber numberWithDouble:Dtime]];
	
	a = [methodParams objectForKey:[NSNumber numberWithInt:calcMethod]];
	double val = [[a  objectAtIndex:1] doubleValue];
	
	if (val == 1) { // Maghrib
		Dtime1 = [[times objectAtIndex:4] doubleValue]+ ([[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:2] doubleValue]/60.0);
		[times replaceObjectAtIndex:5 withObject:[NSNumber numberWithDouble:Dtime1]];
	}
	
	if ([[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:3] doubleValue]== 1) { // Isha
		Dtime2 = [[times objectAtIndex:5] doubleValue] + ([[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:4] doubleValue]/60.0);
		[times replaceObjectAtIndex:6 withObject:[NSNumber numberWithDouble:Dtime2]];
	}
	
	if (adjustHighLats != None){
		times = [self adjustHighLatTimes:times];
	}
	return times;
}


// convert times array to given time format
-(NSMutableArray*)adjustTimesFormat:(NSMutableArray*)times {
	int i = 0;
	
	if (timeFormat == Float){
		return times;
	}
	for (i=0; i<7; i++) {
		if (timeFormat == Time12){
			[times replaceObjectAtIndex:i withObject:[self floatToTime12:[[times objectAtIndex:i] doubleValue] andnoSuffix:NO]];
		}
		else if (timeFormat == Time12NS){
			[times replaceObjectAtIndex:i withObject:[self floatToTime12:[[times objectAtIndex:i] doubleValue] andnoSuffix:YES]];
		}
		else{
			
			[times replaceObjectAtIndex:i withObject:[self floatToTime24:[[times objectAtIndex:i] doubleValue]]];
		}
	}
	return times;
}


// adjust Fajr, Isha and Maghrib for locations in higher latitudes
-(NSMutableArray*)adjustHighLatTimes:(NSMutableArray*)times {
	
	double time0 = [[times objectAtIndex:0] doubleValue];
	double time1 = [[times objectAtIndex:1] doubleValue];
	//double time2 = [[times objectAtIndex:2] doubleValue];
	//double time3 = [[times objectAtIndex:3] doubleValue];
	double time4 = [[times objectAtIndex:4] doubleValue];
	double time5 = [[times objectAtIndex:5] doubleValue];
	double time6 = [[times objectAtIndex:6] doubleValue];
	
	double nightTime = [self timeDiff:time4 andTime2:time1]; // sunset to sunrise
	
	// Adjust Fajr
	double obj0 =[[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:0] doubleValue];
	double obj1 =[[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:1] doubleValue];
	double obj2 =[[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:2] doubleValue];
	double obj3 =[[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:3] doubleValue];
	double obj4 =[[[methodParams objectForKey:[NSNumber numberWithInt:calcMethod]] objectAtIndex:4] doubleValue];
	
	double FajrDiff = [self nightPortion:obj0] * nightTime;
	
	if ((isnan(time0)) || ([self timeDiff:time0 andTime2:time1] > FajrDiff)) 
		[times replaceObjectAtIndex:0 withObject:[NSNumber numberWithDouble:(time1 - FajrDiff)]];
	
	// Adjust Isha
	double IshaAngle = (obj3 == 0) ? obj4: 18;
	double IshaDiff = [self nightPortion: IshaAngle] * nightTime;
	if (isnan(time6) ||[self timeDiff:time4 andTime2:time6] > IshaDiff) 
		[times replaceObjectAtIndex:6 withObject:[NSNumber numberWithDouble:(time4 + IshaDiff)]];
	
	
	// Adjust Maghrib
	double MaghribAngle = (obj1 == 0) ? obj2 : 4;
	double MaghribDiff = [self nightPortion: MaghribAngle] * nightTime;
	if (isnan(time5) || [self timeDiff:time4 andTime2:time5] > MaghribDiff) 
		[times replaceObjectAtIndex:5 withObject:[NSNumber numberWithDouble:(time4 + MaghribDiff)]];
	
	return times;
}


// the night portion used for adjusting times in higher latitudes
-(double)nightPortion:(double)angle {
	double calc = 0;
	
	if (adjustHighLats == AngleBased)
		calc = (angle)/60.0f;
	else if (adjustHighLats == MidNight)
		calc = 0.5f;
	else if (adjustHighLats == OneSeventh)
		calc = 0.14286f;
	
	return calc;
}


// convert hours to day portions 
-(NSMutableArray*)dayPortion:(NSMutableArray*)times {
	int i = 0;
	double time = 0;
	for (i=0; i<7; i++){
		time = [[times objectAtIndex:i] doubleValue];
		time = time/24.0;
		
		[times replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:time]];
		
	}
	return times;
}

-(void) dealloc{
	[super dealloc];
	[prayerTimesCurrent release];
}

@end