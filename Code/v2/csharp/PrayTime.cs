//--------------------- Copyright Block ----------------------
/* 

PrayTime.cs: Prayer Times Calculator (ver 1.2)
Copyright (C) 2007-2010 PrayTimes.org

C# Code By: Jandost Khoso
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


using System;

public class PrayTime
{

//------------------------ Constants --------------------------

// Calculation Methods
	public  static int Jafari     = 0;    // Ithna Ashari
	public  static int Karachi    = 1;    // University of Islamic Sciences, Karachi
	public  static int ISNA       = 2;    // Islamic Society of North America (ISNA)
	public  static int MWL        = 3;    // Muslim World League (MWL)
	public  static int Makkah     = 4;    // Umm al-Qura, Makkah
	public  static int Egypt      = 5;    // Egyptian General Authority of Survey
	public  static int Custom     = 6;    // Custom Setting
	public  static int Tehran     = 7;    // Institute of Geophysics, University of Tehran

	// Juristic Methods
	public  static int Shafii     = 0;    // Shafii (standard)
	public  static int Hanafi     = 1;    // Hanafi

	// Adjusting Methods for Higher Latitudes
	public  static int None       = 0;    // No adjustment
	public  static int MidNight   = 1;    // middle of night
	public  static int OneSeventh = 2;    // 1/7th of night
	public  static int AngleBased = 3;    // angle/60th of night


	// Time Formats
	public  static int Time24     = 0;    // 24-hour format
	public  static int Time12     = 1;    // 12-hour format
	public  static int Time12NS   = 2;    // 12-hour format with no suffix
	public  static int Floating      = 3;    // floating point number

	// Time Names
	public  static String [] timeNames ={	"Fajr", "Sunrise", "Dhuhr", "Asr", "Sunset", "Maghrib",

"Isha"};
	static String InvalidTime = "----";	 // The string used for inv




//---------------------- Global Variables --------------------


	private int calcMethod = 3;		// caculation method
	private int asrJuristic ;		// Juristic method for Asr
	private int dhuhrMinutes = 0;		// minutes after mid-day for Dhuhr
	private int adjustHighLats = 1;	// adjusting method for higher latitudes

	private int timeFormat   = 0;		// time format

	private double lat;        // latitude
	private double lng;        // longitude
	private int timeZone;   // time-zone
	private double JDate;      // Julian date

	private int [] times ;


//--------------------- Technical Settings --------------------


	private int numIterations = 1;		// number of iterations needed to compute times



//------------------- Calc Method Parameters --------------------

	private double [][] methodParams;
	public PrayTime ()
	{
		times = new int [7];
		methodParams = new double [8][];
		this.methodParams[Jafari]	= new double []{16, 0, 4, 0, 14};
		this.methodParams[Karachi]	= new double [] {18, 1, 0, 0, 18};
		this.methodParams[ISNA] 	= new double [] {15, 1, 0, 0, 15};
		this.methodParams[MWL]		= new double [] {18, 1, 0, 0, 17};
		this.methodParams[Makkah]	= new double [] {18.5, 1, 0, 1, 90};
		this.methodParams[Egypt]	= new double [] {19.5, 1, 0, 0, 17.5};
		this.methodParams[Tehran]	= new double [] {17.7, 0, 4.5, 0, 14};
		this.methodParams[Custom]	= new double [] {18, 1, 0, 0, 17};
	}






// return prayer times for a given date
public String [] getPrayerTimes (int year, int month , int day , double latitude, double  longitude, int

timeZone)
{
	return this.getDatePrayerTimes(year, month+ 1, day, latitude, longitude, timeZone);
}

// set the calculation method
public void setCalcMethod (int methodID)
{
	this.calcMethod = methodID;
}

// set the juristic method for Asr
public void setAsrMethod (int methodID)
{
	if (methodID < 0 || methodID > 1)
		return;
	this.asrJuristic = methodID;
}

// set the angle for calculating Fajr
public void setFajrAngle (double angle)
{
	this.setCustomParams(new int [] {(int)angle, -1, -1, -1, -1});
}

// set the angle for calculating Maghrib
public void setMaghribAngle (double angle)
{
	this.setCustomParams(new int [] {-1, 0, (int)angle, -1, -1});
}

// set the angle for calculating Isha
public void setIshaAngle (double angle)
{
	this.setCustomParams(new int [] {-1, -1, -1, 0, (int)angle});
}

// set the minutes after mid-day for calculating Dhuhr
public void setDhuhrMinutes (int  minutes)
{
	this.dhuhrMinutes = minutes;
}

// set the minutes after Sunset for calculating Maghrib
public void setMaghribMinutes (int minutes)
{
	this.setCustomParams(new int []{-1, 1, minutes, -1, -1});
}

// set the minutes after Maghrib for calculating Isha
public void setIshaMinutes (int minutes)
{
	this.setCustomParams(new int [] {-1, -1, -1, 1, minutes});
}

// set custom values for calculation parameters
public void setCustomParams( int [] param)
{
	for (int i=0; i<5; i++)
	{
		if (param[i] == -1)
			this.methodParams[Custom][i] = this.methodParams[this.calcMethod][i];
		else
			this.methodParams[Custom][i] = param[i];
	}
	this.calcMethod = Custom;
}

// set adjusting method for higher latitudes
public void setHighLatsMethod (int methodID)
{
	this.adjustHighLats = methodID;
}

// set the time format
public void setTimeFormat (int timeFormat)
{
	this.timeFormat = timeFormat;
}

// convert float hours to 24h format
public String floatToTime24 (double time)
{
	if (time < 0)
		return InvalidTime;
	time = this.FixHour(time+ 0.5/ 60);  // add 0.5 minutes to round
	double  hours = Math.Floor(time);
	double minutes = Math.Floor((time- hours)* 60);
	return this.twoDigitsFormat((int)hours)+":"+ this.twoDigitsFormat((int)minutes);
}

// convert float hours to 12h format
public String floatToTime12 (double time, bool noSuffix)
{
	if (time < 0)
		return InvalidTime;
	time = this.FixHour(time+ 0.5/ 60);  // add 0.5 minutes to round
	double hours = Math.Floor(time);
	double minutes = Math.Floor((time- hours)* 60);
	String suffix = hours >= 12 ? " pm" : " am";
	hours = (hours+ 12 -1)% 12+ 1;
	return ((int)hours)+":"+ this.twoDigitsFormat((int)minutes)+ (noSuffix ? "" : suffix);
}

// convert float hours to 12h format with no suffix
public String floatToTime12NS (double time)
{
	return this.floatToTime12(time, true);
}

//---------------------- Compute Prayer Times -----------------------


// return prayer times for a given date
public String [] getDatePrayerTimes ( int year, int month, int day, double latitude, double longitude,

int timeZone)
{
	this.lat = latitude;
	this.lng = longitude;
	this.timeZone = timeZone;
    this . JDate = this . JulianDate ( year , month , day ) - longitude / ( 15 * 24 ); 

	return this.computeDayTimes();
}

// compute declination angle of sun and equation of time
public double [] sunPosition ( double jd )
{
	double D = jd - 2451545.0;
	double g = this.FixAngle(357.529 + 0.98560028* D);
	double q = this.FixAngle(280.459 + 0.98564736* D);
	double L = this.FixAngle(q + 1.915* this.dsin(g) + 0.020* this.dsin(2*g));

	double R = 1.00014 - 0.01671* this.dcos(g) - 0.00014* this.dcos(2*g);
	double e = 23.439 - 0.00000036* D;

	double d = this.darcsin(this.dsin(e)* this.dsin(L));
	double RA = this.darctan2(this.dcos(e)* this.dsin(L), this.dcos(L))/ 15;
	RA = this.FixHour(RA);
	double  EqT = q/15 - RA;

	return new double [] {d, EqT};
}

// compute equation of time
public double equationOfTime (double jd)
{
	return this.sunPosition(jd)[1];
}

// compute declination angle of sun
public double sunDeclination (double jd)
{
	return this.sunPosition(jd)[0];
}

// compute mid-day (Dhuhr, Zawal) time
public double computeMidDay ( double t)
{
	double T = this.equationOfTime(this.JDate+ t);
	double Z = this.FixHour(12- T);
	return Z;
}

// compute time for a given angle G
public double computeTime (double G, double t)
{
//System.out.println("G: "+G);

	double D = this.sunDeclination(this.JDate+ t);
	double Z = this.computeMidDay(t);
	double V = ((double)1/15)* this.darccos((-this.dsin(G)- this.dsin(D)* this.dsin(this.lat)) /
			(this.dcos(D)* this.dcos(this.lat)));
	return Z+ (G>90 ? -V : V);
}

// compute the time of Asr
public double computeAsr (int step, double t)  // Shafii: step=1, Hanafi: step=2
{
	double D = this.sunDeclination(this.JDate+ t);
	double G = -this.darccot(step+ this.dtan(Math.Abs(this.lat-D)));
	return this.computeTime(G, t);
}

//---------------------- Compute Prayer Times -----------------------

// compute prayer times at given julian date
public double [] computeTimes ( double [] times)
{
	double []  t = this.dayPortion(times);


	double Fajr    = this.computeTime(180- this.methodParams[this.calcMethod][0], t[0]);
	double Sunrise = this.computeTime(180- 0.833, t[1]);
	double Dhuhr   = this.computeMidDay(t[2]);
	double Asr     = this.computeAsr(1+ this.asrJuristic, t[3]);
	double Sunset  = this.computeTime(0.833, t[4]);;
	double Maghrib = this.computeTime(this.methodParams[this.calcMethod][2], t[5]);
	double Isha    = this.computeTime(this.methodParams[this.calcMethod][4], t[6]);

	return new double [] {Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha};
}

// adjust Fajr, Isha and Maghrib for locations in higher latitudes
public double [] adjustHighLatTimes (double [] times)
{
	double nightTime =  this.GetTimeDifference(times[4], times[1]); // sunset to sunrise

	// Adjust Fajr
	double FajrDiff =  this.nightPortion(this.methodParams[this.calcMethod][0])* nightTime;
	if (this.GetTimeDifference(times[0], times[1]) > FajrDiff)
		times[0] = times[1]- FajrDiff;

	// Adjust Isha
	double IshaAngle = (this.methodParams[this.calcMethod][3] == 0) ? this.methodParams

[this.calcMethod][4] : 18;
	double IshaDiff =  this.nightPortion(IshaAngle)* nightTime;
	if (this.GetTimeDifference(times[4], times[6]) > IshaDiff)
		times[6] = times[4]+ IshaDiff;

	// Adjust Maghrib
	double MaghribAngle = (methodParams[this.calcMethod][1] == 0) ? this.methodParams

[this.calcMethod][2] : 4;
	double MaghribDiff =  this.nightPortion(MaghribAngle)* nightTime;
	if (this.GetTimeDifference(times[4], times[5]) > MaghribDiff)
		times[5] = times[4]+ MaghribDiff;

	return times;
}

// the night portion used for adjusting times in higher latitudes
public double nightPortion ( double angle)
{
	double val = 0;
	if (this.adjustHighLats == AngleBased)
		val = 1.0/60.0* angle;
	if (this.adjustHighLats == MidNight)
		val = 1.0/2.0;
	if (this.adjustHighLats == OneSeventh)
		val =1.0/7.0;

	return val;
}

public double [] dayPortion ( double [] times)
{
    for ( int i = 0 ; i < times . Length ; i++ )
    {
        times [ i ] /= 24;
    }
	return times;
}

// compute prayer times at given julian date
public String [] computeDayTimes ()
{
	double [] times = {5, 6, 12, 13, 18, 18, 18}; //default times

    for ( int i = 0 ; i < this . numIterations ; i++ )
    {
        times = this . computeTimes ( times );
    }

	times = this.adjustTimes(times);
	return this.adjustTimesFormat(times);
}


// adjust times in a prayer time array
public double [] adjustTimes  ( double []  times)
{
    for ( int i = 0 ; i < 7 ; i++ )
    {
        times [ i ] += this . timeZone - this . lng / 15;
    }
	times[2] += this.dhuhrMinutes/ 60; //Dhuhr
	if (this.methodParams[this.calcMethod][1] == 1) // Maghrib
		times[5] = times[4]+ this.methodParams[this.calcMethod][2]/ 60.0;
	if (this.methodParams[this.calcMethod][3] == 1) // Isha
		times[6] = times[5]+ this.methodParams[this.calcMethod][4]/ 60.0;

    if ( this . adjustHighLats != None )
    {
        times = this . adjustHighLatTimes ( times );
    }

	return times;
}

public String [] adjustTimesFormat (double [] times)
{
	String [] formatted = new String [times.Length];

	if (this.timeFormat == Floating)
		{
			for	( int i = 0 ; i < times.Length ; ++i )
			{
				formatted [i] = times[i]+"";
			}
			return formatted;
		}
        for ( int i = 0 ; i < 7 ; i++ )
        {
            if ( this . timeFormat == Time12 )
                formatted [ i ] = this . floatToTime12 ( times [ i ] , true );
            else if ( this . timeFormat == Time12NS )
                formatted [ i ] = this . floatToTime12NS ( times [ i ] );
            else
                formatted [ i ] = this . floatToTime24 ( times [ i ] );
        }
	return formatted;
}

//---------------------- Misc Functions -----------------------

	// compute the difference between two times
	public double GetTimeDifference (double c1 , double c2)
	{
		double diff = this.FixHour(c2 - c1);;
		return diff;
	}

	// add a leading 0 if necessary
	public String twoDigitsFormat ( int num)
	{

		return (num <10) ? "0"+ num : num+"";
	}

//---------------------- Julian Date Functions -----------------------

// calculate julian date from a calendar date
    public double JulianDate ( int year , int month , int day )
    {
        if ( month <= 2 )
        {
            year -= 1;
            month += 12;
        }
        double A = ( double ) Math . Floor ( year / 100.0 );
        double B = 2 - A + Math . Floor ( A / 4 );

        double JD = Math . Floor ( 365.25 * ( year + 4716 ) ) + Math . Floor ( 30.6001 * ( month + 1 ) ) + day + B - 1524.5;
        return JD;
    }


//---------------------- Time-Zone Functions -----------------------

	
	// detect daylight saving in a given date
	public bool UseDayLightaving ( int year, int month , int day )
	{
        return TimeZone . CurrentTimeZone . IsDaylightSavingTime ( new DateTime ( year , month , day ) ); 
	}

	// ---------------------- Trigonometric Functions -----------------------

	// degree sin
	public double dsin (double d)
	{
	    return Math.Sin(this.DegreeToRadian(d));
	}

	// degree cos
	public double dcos (double d)
	{
	    return Math.Cos(this.DegreeToRadian(d));
	}

	// degree tan
	public double dtan (double d)
	{
	    return Math.Tan(this.DegreeToRadian(d));
	}

	// degree arcsin
	public double darcsin (double x)
	{
	    return this.RadianToDegree(Math.Asin(x));
	}

	// degree arccos
	public double darccos (double x)
	{
	    return this.RadianToDegree(Math.Acos(x));
	}

	// degree arctan
	public double darctan (double x)
	{
	    return this.RadianToDegree(Math.Atan(x));
	}

	// degree arctan2
	public double darctan2 (double y, double x)
	{
	    return this.RadianToDegree(Math.Atan2(y, x));
	}

	// degree arccot
	public double darccot (double x)
	{
	    return this.RadianToDegree(Math.Atan(1/x));
	}


	// Radian to Degree
	public double RadianToDegree ( double radian)
	{
		return (radian * 180.0) / Math.PI;
	}

	// degree to radian
	public double DegreeToRadian (double degree)
	{
	    return (degree * Math.PI) / 180.0;
	}

	public double FixAngle ( double angel )
	{
		angel = angel - 360.0 * (Math.Floor(angel / 360.0));
		angel = angel < 0 ? angel + 360.0 : angel;
		return angel;
	}

	// range reduce hours to 0..23
	public double FixHour ( double hour )
	{
		hour = hour - 24.0 * (Math.Floor(hour / 24.0));
		hour = hour < 0 ? hour + 24.0 : hour;
		return hour;
	}
}