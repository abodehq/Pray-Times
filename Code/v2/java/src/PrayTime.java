//--------------------- Copyright Block ----------------------
/* 

PrayTime.java: Prayer Times Calculator (ver 1.0)
Copyright (C) 2007-2010 PrayTimes.org

Java Code By: Hussain Ali Khan
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


import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

public class PrayTime {
	
		public static enum AstroEvents {
			 Fajr,
       Sunrise,
       Dhuhr,
       Asr,
       Sunset,
       Maghrib,
       Isha,
       Midnight
		}

    // ---------------------- Global Variables --------------------
    private int calcMethod; // caculation method
    private int asrJuristic; // Juristic method for Asr
    private int dhuhrMinutes; // minutes after mid-day for Dhuhr
    private int adjustHighLats; // adjusting method for higher latitudes
    private int timeFormat; // time format
    private double lat; // latitude
    private double lng; // longitude
    private double elev; // elevation
    private double timeZone; // time-zone
    private double JDate; // Julian date
    // ------------------------------------------------------------
    // Calculation Methods
    private int Jafari; // Ithna Ashari
    private int Karachi; // University of Islamic Sciences, Karachi
    private int SMKA; // Calculation seting for the Assunnah Mosque in Karlsruhe (Germany). 
    private int ISNA; // Islamic Society of North America (ISNA)
    private int MWL; // Muslim World League (MWL)
    private int Makkah; // Umm al-Qura, Makkah
    private int Egypt; // Egyptian General Authority of Survey
    private int Custom; // Custom Setting
    private int Tehran; // Institute of Geophysics, University of Tehran
    // Juristic Methods
    private int Shafii; // Shafii (standard)
    private int Hanafi; // Hanafi
    // Adjusting Methods for Higher Latitudes
    private int None; // No adjustment
    private int MidNight; // middle of night
    private int OneSeventh; // 1/7th of night
    private int AngleBased; // angle/60th of night
    // Time Formats
    private int Time24; // 24-hour format
    private int Time12; // 12-hour format
    private int Time12NS; // 12-hour format with no suffix
    private int Floating; // floating point number
    // Time Names
    private ArrayList<String> timeNames;
    private String InvalidTime; // The string used for invalid times
    // --------------------- Technical Settings --------------------
    private int numIterations; // number of iterations needed to compute times
    // ------------------- Calc Method Parameters --------------------
    private HashMap<Integer, double[]> methodParams;

    /*
     * this.methodParams[methodNum] = new Array(fa, ms, mv, is, iv);
     *
     * fa : fajr angle ms : maghrib selector (0 = angle; 1 = minutes after
     * sunset) mv : maghrib parameter value (in angle or minutes) is : isha
     * selector (0 = angle; 1 = minutes after maghrib) iv : isha parameter value
     * (in angle or minutes)
     */
    private Map<AstroEvents, Double> offsets;

    public PrayTime() {
        // Initialize vars

        this.setCalcMethod(0);
        this.setAsrJuristic(0);
        this.setDhuhrMinutes(0);
        this.setAdjustHighLats(1);
        this.setTimeFormat(0);

        // Calculation Methods
        this.setJafari(0); // Ithna Ashari
        this.setKarachi(1); // University of Islamic Sciences, Karachi
        this.setISNA(2); // Islamic Society of North America (ISNA)
        this.setMWL(3); // Muslim World League (MWL)
        this.setMakkah(4); // Umm al-Qura, Makkah
        this.setEgypt(5); // Egyptian General Authority of Survey
        this.setTehran(6); // Institute of Geophysics, University of Tehran
        this.setCustom(7); // Custom Setting
        this.setSMKA(8); // Calculation setting for the Assunnah Mosque in Karlsruhe
        
        // Juristic Methods
        this.setShafii(0); // Shafii (standard)
        this.setHanafi(1); // Hanafi

        // Adjusting Methods for Higher Latitudes
        this.setNone(0); // No adjustment
        this.setMidNight(1); // middle of night
        this.setOneSeventh(2); // 1/7th of night
        this.setAngleBased(3); // angle/60th of night

        // Time Formats
        this.setTime24(0); // 24-hour format
        this.setTime12(1); // 12-hour format
        this.setTime12NS(2); // 12-hour format with no suffix
        this.setFloating(3); // floating point number

        InvalidTime = "-----"; // The string used for invalid times

        // --------------------- Technical Settings --------------------

        this.setNumIterations(1); // number of iterations needed to compute
        // times

        // ------------------- Calc Method Parameters --------------------
        offsets = new HashMap<>();
        for (AstroEvents astroEvent : AstroEvents.values()) {
        	offsets.put(astroEvent, 0.0);
        }
        
        /*
         *
         * fa : fajr angle ms : maghrib selector (0 = angle; 1 = minutes after
         * sunset) mv : maghrib parameter value (in angle or minutes) is : isha
         * selector (0 = angle; 1 = minutes after maghrib) iv : isha parameter
         * value (in angle or minutes)
         */
        methodParams = new HashMap<Integer, double[]>();

        // Jafari
        double[] Jvalues = {16,0,4,0,14};
        methodParams.put(Integer.valueOf(this.getJafari()), Jvalues);

        // Karachi
        double[] Kvalues = {18,1,0,0,18};
        methodParams.put(Integer.valueOf(this.getKarachi()), Kvalues);

        // ISNA
        double[] Ivalues = {15,1,0,0,15};
        methodParams.put(Integer.valueOf(this.getISNA()), Ivalues);

        // MWL
        double[] MWvalues = {18,1,0,0,17};
        methodParams.put(Integer.valueOf(this.getMWL()), MWvalues);

        // Makkah
        double[] MKvalues = {18.5,1,0,1,90};
        methodParams.put(Integer.valueOf(this.getMakkah()), MKvalues);

        // Egypt
        double[] Evalues = {19.5,1,0,0,17.5};
        methodParams.put(Integer.valueOf(this.getEgypt()), Evalues);

        // Tehran
        double[] Tvalues = {17.7,0,4.5,0,14};
        methodParams.put(Integer.valueOf(this.getTehran()), Tvalues);

        // Custom
        double[] Cvalues = {18,1,0,0,17};
        methodParams.put(Integer.valueOf(this.getCustom()), Cvalues);

        // SMKA
        double[] SMKAvalues = {13,0,0,0,14};
        methodParams.put(Integer.valueOf(this.getSMKA()), SMKAvalues);

    }

    // ---------------------- Trigonometric Functions -----------------------
    // range reduce angle in degrees.
    private double fixangle(double a) {

        a = a - (360 * (Math.floor(a / 360.0)));

        a = a < 0 ? (a + 360) : a;

        return a;
    }

    // range reduce hours to 0..23
    private double fixhour(double a) {
        a = a - (24.0 * Math.floor(a / 24.0));
        return a < 0 ? (a + 24) : a;
    }

    // radian to degree
    private double radiansToDegrees(double alpha) {
        return ((alpha * 180.0) / Math.PI);
    }

    // deree to radian
    private double DegreesToRadians(double alpha) {
        return ((alpha * Math.PI) / 180.0);
    }

    // degree sin
    private double dsin(double d) {
        return (Math.sin(DegreesToRadians(d)));
    }

    // degree cos
    private double dcos(double d) {
        return (Math.cos(DegreesToRadians(d)));
    }

    // degree tan
    private double dtan(double d) {
        return (Math.tan(DegreesToRadians(d)));
    }

    // degree arcsin
    private double darcsin(double x) {
        double val = Math.asin(x);
        return radiansToDegrees(val);
    }

    // degree arccos
    private double darccos(double x) {
        double val = Math.acos(x);
        return radiansToDegrees(val);
    }

    // degree arctan
    @SuppressWarnings("unused")
		private double darctan(double x) {
        double val = Math.atan(x);
        return radiansToDegrees(val);
    }

    // degree arctan2
    private double darctan2(double y, double x) {
        double val = Math.atan2(y, x);
        return radiansToDegrees(val);
    }

    // degree arccot
    private double darccot(double x) {
        double val = Math.atan2(1.0, x);
        return radiansToDegrees(val);
    }

    // ---------------------- Time-Zone Functions -----------------------
    // compute local time-zone for a specific date
    @SuppressWarnings("unused")
		private double getTimeZone1() {
        TimeZone timez = TimeZone.getDefault();
        double hoursDiff = (timez.getRawOffset() / 1000.0) / 3600;
        return hoursDiff;
    }

    // compute base time-zone of the system
    @SuppressWarnings("unused")
		private double getBaseTimeZone() {
        TimeZone timez = TimeZone.getDefault();
        double hoursDiff = (timez.getRawOffset() / 1000.0) / 3600;
        return hoursDiff;

    }

    // detect daylight saving in a given date
    @SuppressWarnings("unused")
		private double detectDaylightSaving() {
        TimeZone timez = TimeZone.getDefault();
        double hoursDiff = timez.getDSTSavings();
        return hoursDiff;
    }

    // ---------------------- Julian Date Functions -----------------------
    // calculate julian date from a calendar date
    private double julianDate(int year, int month, int day) {
        
        if (month <= 2) {
            year -= 1;
            month += 12;
        }
        double A = Math.floor(year / 100.0);

        double B = 2 - A + Math.floor(A / 4.0);

        double JD = Math.floor(365.25 * (year + 4716))
                + Math.floor(30.6001 * (month + 1)) + day + B - 1524.5;

        return JD;
    }

    // convert a calendar date to julian date (second method)
    @SuppressWarnings({"unused", "deprecation"})
		private double calcJD(int year, int month, int day) {
        double J1970 = 2440588.0;
        Date date = new Date(year, month - 1, day);
        
        double ms = date.getTime(); // # of milliseconds since midnight Jan 1,
        // 1970
        double days = Math.floor(ms / (1000.0 * 60.0 * 60.0 * 24.0));
        return J1970 + days - 0.5;

    }

    // ---------------------- Calculation Functions -----------------------
    // References:
    // http://www.ummah.net/astronomy/saltime
    // http://aa.usno.navy.mil/faq/docs/SunApprox.html
    // compute declination angle of sun and equation of time
    private double[] sunPosition(double jd) {

        double D = jd - 2451545;
        double g = fixangle(357.529 + 0.98560028 * D);
        double q = fixangle(280.459 + 0.98564736 * D);
        double L = fixangle(q + (1.915 * dsin(g)) + (0.020 * dsin(2 * g)));
       
        // double R = 1.00014 - 0.01671 * [self dcos:g] - 0.00014 * [self dcos:
        // (2*g)];
        double e = 23.439 - (0.00000036 * D);
        double d = darcsin(dsin(e) * dsin(L));
        double RA = (darctan2((dcos(e) * dsin(L)), (dcos(L))))/ 15.0;
        RA = fixhour(RA);
        double EqT = q/15.0 - RA;
        double[] sPosition = new double[2];
        sPosition[0] = d;
        sPosition[1] = EqT;

        return sPosition;
    }

    // compute equation of time
    private double equationOfTime(double jd) {
        double eq = sunPosition(jd)[1];
        return eq;
    }

    // compute declination angle of sun
    private double sunDeclination(double jd) {
        double d = sunPosition(jd)[0];
        return d;
    }

    // compute mid-day (Dhuhr, Zawal) time
    private double computeMidDay(double t) {
        double T = equationOfTime(this.getJDate() + t);
        double Z = fixhour(12 - T);
        return Z;
    }

    // compute time for a given angle G
    private double computeTime(double G, double t) {

        double D = sunDeclination(this.getJDate() + t);
        double Z = computeMidDay(t);
        double Beg = -dsin(G) - dsin(D) * dsin(this.getLat());
        double Mid = dcos(D) * dcos(this.getLat());
        double V = darccos(Beg/Mid)/15.0;
        
        return Z + (G > 90 ? -V : V);
    }

    // compute the time of Asr
    // Shafii: step=1, Hanafi: step=2
    private double computeAsr(double step, double t) {
        double D = sunDeclination(this.getJDate() + t);
        double G = -darccot(step + dtan(Math.abs(this.getLat() - D)));
        return computeTime(G, t);
    }

    // ---------------------- Misc Functions -----------------------
    // compute the difference between two times
    private double timeDiff(double time1, double time2) {
        return fixhour(time2 - time1);
    }

    // -------------------- Interface Functions --------------------
    // return prayer times for a given date
    private Map<AstroEvents, String> getDatePrayerTimes(int year, int month, int day, double latitude, double longitude, double elevation, double tZone) {
        this.setLat(latitude);
        this.setLng(longitude);
        this.setElev(elevation);
        this.setTimeZone(tZone);
        this.setJDate(julianDate(year, month, day));
        double lonDiff = longitude / (15.0 * 24.0);
        this.setJDate(this.getJDate() - lonDiff);
        return computeDayTimes();
    }

    @SuppressWarnings("unused")
		private Map<AstroEvents, String> getPrayerTimes(Calendar date, double latitude, double longitud, double tZone) {
    	return getPrayerTimes(date, latitude, longitud, 0, tZone);
    	
    }
    // return prayer times for a given date
    private Map<AstroEvents, String> getPrayerTimes(Calendar date, double latitude, double longitude, double elevation, double tZone) {

        int year = date.get(Calendar.YEAR);
        int month = date.get(Calendar.MONTH);
        int day = date.get(Calendar.DATE);

        return getDatePrayerTimes(year, month+1, day, latitude, longitude, elevation, tZone);
    }

    // set custom values for calculation parameters
    private void setCustomParams(double[] params) {

        for (int i = 0; i < 5; i++) {
            if (params[i] == -1) {
                params[i] = methodParams.get(this.getCalcMethod())[i];
                methodParams.put(this.getCustom(), params);
            } else {
                methodParams.get(this.getCustom())[i] = params[i];
            }
        }
        this.setCalcMethod(this.getCustom());
    }

    // set the angle for calculating Fajr
    public void setFajrAngle(double angle) {
        double[] params = {angle, -1, -1, -1, -1};
        setCustomParams(params);
    }

    // set the angle for calculating Maghrib
    public void setMaghribAngle(double angle) {
        double[] params = {-1, 0, angle, -1, -1};
        setCustomParams(params);

    }

    // set the angle for calculating Isha
    public void setIshaAngle(double angle) {
        double[] params = {-1, -1, -1, 0, angle};
        setCustomParams(params);

    }

    // set the minutes after Sunset for calculating Maghrib
    public void setMaghribMinutes(double minutes) {
        double[] params = {-1, 1, minutes, -1, -1};
        setCustomParams(params);

    }

    // set the minutes after Maghrib for calculating Isha
    public void setIshaMinutes(double minutes) {
        double[] params = {-1, -1, -1, 1, minutes};
        setCustomParams(params);

    }

    // convert double hours to 24h format
    public String floatToTime24(double time) {

        String result;

        if (Double.isNaN(time)) {
            return InvalidTime;
        }

        time = fixhour(time + 0.5 / 60.0); // add 0.5 minutes to round
        int hours = (int)Math.floor(time);
        double minutes = Math.floor((time - hours) * 60.0);

        if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
            result = "0" + hours + ":0" + Math.round(minutes);
        } else if ((hours >= 0 && hours <= 9)) {
            result = "0" + hours + ":" + Math.round(minutes);
        } else if ((minutes >= 0 && minutes <= 9)) {
            result = hours + ":0" + Math.round(minutes);
        } else {
            result = hours + ":" + Math.round(minutes);
        }
        return result;
    }

    // convert double hours to 12h format
    public String floatToTime12(double time, boolean noSuffix) {

        if (Double.isNaN(time)) {
            return InvalidTime;
        }

        time = fixhour(time + 0.5 / 60); // add 0.5 minutes to round
        int hours = (int)Math.floor(time);
        double minutes = Math.floor((time - hours) * 60);
        String suffix, result;
        if (hours >= 12) {
            suffix = "pm";
        } else {
            suffix = "am";
        }
        hours = ((((hours+ 12) -1) % (12))+ 1);
        /*hours = (hours + 12) - 1;
        int hrs = (int) hours % 12;
        hrs += 1;*/
        if (noSuffix == false) {
            if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
                result = "0" + hours + ":0" + Math.round(minutes) + " "
                        + suffix;
            } else if ((hours >= 0 && hours <= 9)) {
                result = "0" + hours + ":" + Math.round(minutes) + " " + suffix;
            } else if ((minutes >= 0 && minutes <= 9)) {
                result = hours + ":0" + Math.round(minutes) + " " + suffix;
            } else {
                result = hours + ":" + Math.round(minutes) + " " + suffix;
            }

        } else {
            if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
                result = "0" + hours + ":0" + Math.round(minutes);
            } else if ((hours >= 0 && hours <= 9)) {
                result = "0" + hours + ":" + Math.round(minutes);
            } else if ((minutes >= 0 && minutes <= 9)) {
                result = hours + ":0" + Math.round(minutes);
            } else {
                result = hours + ":" + Math.round(minutes);
            }
        }
        return result;

    }

    // convert double hours to 12h format with no suffix
    public String floatToTime12NS(double time) {
        return floatToTime12(time, true);
    }

    // ---------------------- Compute Prayer Times -----------------------
    // compute prayer times at given julian date
    private Map<AstroEvents, Double> computeTimes(Map<AstroEvents, Double> astroEventToTime) {

    		Map<AstroEvents, Double> t = dayPortion(astroEventToTime);

        double Fajr = this.computeTime(180 - methodParams.get(this.getCalcMethod())[0], t.get(AstroEvents.Fajr));
        astroEventToTime.put(AstroEvents.Fajr, Fajr);
        
        double Sunrise = this.computeTime(sunriseAngle(this.getElev()), t.get(AstroEvents.Sunrise));
        astroEventToTime.put(AstroEvents.Sunrise, Sunrise);
        
        double Dhuhr = this.computeMidDay(t.get(AstroEvents.Dhuhr));
        astroEventToTime.put(AstroEvents.Dhuhr, Dhuhr);
        
        double Asr = this.computeAsr(1 + this.getAsrJuristic(), t.get(AstroEvents.Asr));
        astroEventToTime.put(AstroEvents.Asr, Asr);

        double Sunset = this.computeTime(sunsetAngle(this.getElev()), t.get(AstroEvents.Sunset));
        astroEventToTime.put(AstroEvents.Sunset, Sunset);
        
        double Maghrib = this.computeTime(methodParams.get(this.getCalcMethod())[2], t.get(AstroEvents.Maghrib));
        astroEventToTime.put(AstroEvents.Maghrib, Maghrib);

        double Isha = this.computeTime(methodParams.get(this.getCalcMethod())[4], t.get(AstroEvents.Isha));
        astroEventToTime.put(AstroEvents.Isha, Isha);

        return astroEventToTime;
    }

    /**
		 * @param elevation
		 * @return
		 */
		private double sunsetAngle(double elevation) {
			return 0.833 + (0.0347 * Math.sqrt(elevation));
		}
		
		/**
		 * @param elevation
		 * @return
		 */
		private double sunriseAngle(double elevation) {
			return 180 - sunsetAngle(elevation);
		}

		// compute prayer times at given julian date
    private Map<AstroEvents, String> computeDayTimes() {
//        double[] times = {5, 6, 12, 13, 18, 18, 18}; // default times
        Map<AstroEvents, Double> astroEventToTime = new HashMap<AstroEvents, Double>() {
					private static final long serialVersionUID = 1599875645524655898L;
					{
						put(AstroEvents.Fajr, 5.0);
						put(AstroEvents.Sunrise, 6.0);
						put(AstroEvents.Dhuhr, 12.0);
						put(AstroEvents.Asr, 13.0);
						put(AstroEvents.Sunset, 18.0);
						put(AstroEvents.Maghrib, 18.0);
						put(AstroEvents.Isha, 18.0);
					}};

        for (int i = 1; i <= this.getNumIterations(); i++) {
            astroEventToTime = computeTimes(astroEventToTime);
        }
        
        astroEventToTime = adjustTimes(astroEventToTime);
        // add midnight time
        double sunsetTime = astroEventToTime.get(AstroEvents.Sunset);
    		if (calcMethod == this.Jafari) {
    			astroEventToTime.put(AstroEvents.Midnight, sunsetTime + (timeDiff(sunsetTime, astroEventToTime.get(AstroEvents.Fajr))/2));
    		} else {
    			astroEventToTime.put(AstroEvents.Midnight, sunsetTime + (timeDiff(sunsetTime, astroEventToTime.get(AstroEvents.Sunrise))/2));
    		}
        astroEventToTime = tuneTimes(astroEventToTime);
        
        return adjustTimesFormat(astroEventToTime);
    }

    // adjust times in a prayer time array
    private Map<AstroEvents, Double> adjustTimes(Map<AstroEvents, Double> astroEventToTime) {
        for (AstroEvents prayer : astroEventToTime.keySet()) {
        	  double currentTime = astroEventToTime.get(prayer);
            astroEventToTime.put(prayer, currentTime + (this.getTimeZone() - this.getLng() / 15));
        }
        
        double currentDhuhrTime = astroEventToTime.get(AstroEvents.Dhuhr);
        astroEventToTime.put(AstroEvents.Dhuhr, currentDhuhrTime + (this.getDhuhrMinutes() / 60)); // Dhuhr
        if (methodParams.get(this.getCalcMethod())[1] == 1) { // Maghrib
            astroEventToTime.put(AstroEvents.Maghrib, astroEventToTime.get(AstroEvents.Dhuhr) + (methodParams.get(this.getCalcMethod())[2]/ 60));
        }
        if (methodParams.get(this.getCalcMethod())[3] == 1) { // Isha
            astroEventToTime.put(AstroEvents.Isha, astroEventToTime.get(AstroEvents.Maghrib) + (methodParams.get(this.getCalcMethod())[4]/ 60));
        }
        
        if (this.getAdjustHighLats() != this.getNone()) {
        	astroEventToTime = adjustHighLatTimes(astroEventToTime);
        }
        
        return astroEventToTime;
    }

    // convert times array to given time format
    private Map<AstroEvents, String> adjustTimesFormat(Map<AstroEvents, Double> astroEventToTime) {
    	  Map<AstroEvents, String> astroEventToTimeStr = new HashMap<>();

        if (this.getTimeFormat() == this.getFloating()) {
            for (AstroEvents dayTime : astroEventToTime.keySet()) {
            	astroEventToTimeStr.put(dayTime, String.valueOf(astroEventToTime.get(dayTime)));
            }
            return astroEventToTimeStr;
        }

        for (AstroEvents dayTime : astroEventToTime.keySet()) {
            if (this.getTimeFormat() == this.getTime12()) {
                astroEventToTimeStr.put(dayTime, floatToTime12(astroEventToTime.get(dayTime), false));
            } else if (this.getTimeFormat() == this.getTime12NS()) {
            		astroEventToTimeStr.put(dayTime, floatToTime12(astroEventToTime.get(dayTime), true));
            } else {
            		astroEventToTimeStr.put(dayTime, floatToTime24(astroEventToTime.get(dayTime)));
            }
        }
        return astroEventToTimeStr;
    }

    // adjust Fajr, Isha and Maghrib for locations in higher latitudes
    private Map<AstroEvents, Double> adjustHighLatTimes(Map<AstroEvents, Double> astroEventToTime) {
        double nightTime = timeDiff(astroEventToTime.get(AstroEvents.Sunset), astroEventToTime.get(AstroEvents.Sunrise)); // sunset to sunrise
        
        // Adjust Fajr
        double FajrDiff = nightPortion(methodParams.get(this.getCalcMethod())[0]) * nightTime;
        
        if (Double.isNaN(astroEventToTime.get(AstroEvents.Fajr)) || timeDiff(astroEventToTime.get(AstroEvents.Fajr), astroEventToTime.get(AstroEvents.Sunrise)) > FajrDiff) {
        		astroEventToTime.put(AstroEvents.Fajr, astroEventToTime.get(AstroEvents.Sunrise) - FajrDiff);
        }

        // Adjust Isha
        double IshaAngle = (methodParams.get(this.getCalcMethod())[3] == 0) ? methodParams.get(this.getCalcMethod())[4] : 18;
        double IshaDiff = this.nightPortion(IshaAngle) * nightTime;
        if (Double.isNaN(astroEventToTime.get(AstroEvents.Isha)) || this.timeDiff(astroEventToTime.get(AstroEvents.Sunset), astroEventToTime.get(AstroEvents.Isha)) > IshaDiff) {
        	astroEventToTime.put(AstroEvents.Isha, astroEventToTime.get(AstroEvents.Sunset) + IshaDiff);
        }

        // Adjust Maghrib
        double MaghribAngle = (methodParams.get(this.getCalcMethod())[1] == 0) ? methodParams.get(this.getCalcMethod())[2] : 4;
        double MaghribDiff = nightPortion(MaghribAngle) * nightTime;
        if (Double.isNaN(astroEventToTime.get(AstroEvents.Maghrib)) || this.timeDiff(astroEventToTime.get(AstroEvents.Sunset), astroEventToTime.get(AstroEvents.Maghrib)) > MaghribDiff) {
        	astroEventToTime.put(AstroEvents.Maghrib, astroEventToTime.get(AstroEvents.Sunset) + MaghribDiff);
        }
        
        return astroEventToTime;
    }

    // the night portion used for adjusting times in higher latitudes
    private double nightPortion(double angle) {
       double calc = 0;

       if (adjustHighLats == AngleBased)
      	 calc = (angle)/60.0;
       else if (adjustHighLats == MidNight)
      	 calc = 0.5;
       else if (adjustHighLats == OneSeventh)
      	 calc = 0.14286;

       return calc;
    }

    // convert hours to day portions
    private Map<AstroEvents, Double> dayPortion(Map<AstroEvents, Double> astroEventToTime) {
    		Map<AstroEvents, Double> dayEventToPortion = new HashMap<>();
        for (AstroEvents prayer : astroEventToTime.keySet()) {
        	dayEventToPortion.put(prayer, astroEventToTime.get(prayer)/24);
        }
        return dayEventToPortion;
    }

    // Tune timings for adjustments
    // Set time offsets
    public void tune(Map<AstroEvents, Double> offsetTimes) {

        for (AstroEvents dayTime : AstroEvents.values() ) {
        		Double offsetUpdate = offsetTimes.get(dayTime);
        		if (offsetUpdate != null) {
        			offsets.put(dayTime, offsetTimes.get(dayTime));
        		}
        }
    }

    private Map<AstroEvents, Double> tuneTimes(Map<AstroEvents, Double> astroEventToTime) {
        for (AstroEvents dayTime : astroEventToTime.keySet()) {
        		double thisPrayerTime = astroEventToTime.get(dayTime);
            astroEventToTime.put(dayTime, thisPrayerTime + (this.offsets.get(dayTime) / 60.0));
        }
        return astroEventToTime;
    }

    /**
     * @param args
     * @throws ParseException 
     */
    public static void main(String[] args) throws ParseException { //49.009466696187275, 8.406098655728469, 118
        double latitude = 49.009466696187275;
        double longitude = 8.406098655728469;
        double elevation = 118;
        int timezone = 2;

        // Handling DST
        ZoneId germnayZoneId = ZoneId.of("Europe/Berlin");
        
        // Test Prayer times here
        PrayTime prayers = new PrayTime();

        prayers.setTimeFormat(prayers.Time24);
        prayers.setCalcMethod(prayers.SMKA);
        prayers.setAsrJuristic(prayers.Shafii);
        prayers.setAdjustHighLats(prayers.AngleBased);
        prayers.tune(prayers.offsets);
        
        Date now = new Date();
        LocalDate localNow = LocalDate.now();
        SimpleDateFormat dayFormatter = new SimpleDateFormat("dd.MM.yyyy"); 
        if (args.length > 0) {
        	now = dayFormatter.parse(args[0]);
        	localNow = LocalDate.parse(args[0], DateTimeFormatter.ofPattern("dd.MM.yyyy"));
        }
        
        Calendar cal = Calendar.getInstance();
        cal.setTime(now);

        Map<AstroEvents, String> prayerTimes = prayers.getPrayerTimes(cal, latitude, longitude, elevation, timezone);

        String dict = "{";
        for (AstroEvents astroEvent : AstroEvents.values()) {
        	LocalDateTime time_wo_dst = LocalTime.parse(prayerTimes.get(astroEvent)).atDate(localNow);
        	Instant instant_wo_dst = time_wo_dst.toInstant(ZoneOffset.ofHours(timezone));
        	ZonedDateTime instant_w_dst = instant_wo_dst.atZone(germnayZoneId);
        	dict = dict + astroEvent.name() + ":" + instant_w_dst.format(DateTimeFormatter.ofPattern("HH:mm")) + ",";
        }
        dict = dict + "}";
        System.out.println(dict);
        
    }

    public int getCalcMethod() {
        return calcMethod;
    }

    public void setCalcMethod(int calcMethod) {
        this.calcMethod = calcMethod;
    }

    public int getAsrJuristic() {
        return asrJuristic;
    }

    public void setAsrJuristic(int asrJuristic) {
        this.asrJuristic = asrJuristic;
    }

    public int getDhuhrMinutes() {
        return dhuhrMinutes;
    }

    public void setDhuhrMinutes(int dhuhrMinutes) {
        this.dhuhrMinutes = dhuhrMinutes;
    }

    public int getAdjustHighLats() {
        return adjustHighLats;
    }

    public void setAdjustHighLats(int adjustHighLats) {
        this.adjustHighLats = adjustHighLats;
    }

    public int getTimeFormat() {
        return timeFormat;
    }

    public void setTimeFormat(int timeFormat) {
        this.timeFormat = timeFormat;
    }

    public double getLat() {
        return lat;
    }

    public void setLat(double lat) {
        this.lat = lat;
    }

    public double getLng() {
        return lng;
    }

    public void setLng(double lng) {
        this.lng = lng;
    }
    
    public double getElev() {
    	return elev;
    }
    
    public void setElev(double elv) {
    	this.elev = elv;
    }

    public double getTimeZone() {
        return timeZone;
    }

    public void setTimeZone(double timeZone) {
        this.timeZone = timeZone;
    }

    public double getJDate() {
        return JDate;
    }

    public void setJDate(double jDate) {
        JDate = jDate;
    }

    private int getJafari() {
        return Jafari;
    }

    private void setJafari(int jafari) {
        Jafari = jafari;
    }

    private int getKarachi() {
        return Karachi;
    }

    private void setKarachi(int karachi) {
        Karachi = karachi;
    }

    private int getISNA() {
        return ISNA;
    }
    
    private void setISNA(int iSNA) {
        ISNA = iSNA;
    }

    private int getMWL() {
        return MWL;
    }

    private void setMWL(int mWL) {
        MWL = mWL;
    }

    private int getMakkah() {
        return Makkah;
    }

    private void setMakkah(int makkah) {
        Makkah = makkah;
    }

    private int getEgypt() {
        return Egypt;
    }

    private void setEgypt(int egypt) {
        Egypt = egypt;
    }

    private int getCustom() {
        return Custom;
    }

    private void setCustom(int custom) {
        Custom = custom;
    }
    
    private int getSMKA() {
    	return SMKA;
    }
    
    private void setSMKA(int SMKA) {
    	this.SMKA = SMKA;
    }

    private int getTehran() {
        return Tehran;
    }

    private void setTehran(int tehran) {
        Tehran = tehran;
    }

    @SuppressWarnings("unused")
		private int getShafii() {
        return Shafii;
    }

    private void setShafii(int shafii) {
        Shafii = shafii;
    }

    @SuppressWarnings("unused")
		private int getHanafi() {
        return Hanafi;
    }

    private void setHanafi(int hanafi) {
        Hanafi = hanafi;
    }

    private int getNone() {
        return None;
    }

    private void setNone(int none) {
        None = none;
    }

    @SuppressWarnings("unused")
		private int getMidNight() {
        return MidNight;
    }

    private void setMidNight(int midNight) {
        MidNight = midNight;
    }

    @SuppressWarnings("unused")
		private int getOneSeventh() {
        return OneSeventh;
    }

    private void setOneSeventh(int oneSeventh) {
        OneSeventh = oneSeventh;
    }

    @SuppressWarnings("unused")
		private int getAngleBased() {
        return AngleBased;
    }

    private void setAngleBased(int angleBased) {
        AngleBased = angleBased;
    }

    @SuppressWarnings("unused")
		private int getTime24() {
        return Time24;
    }

    private void setTime24(int time24) {
        Time24 = time24;
    }

    private int getTime12() {
        return Time12;
    }

    private void setTime12(int time12) {
        Time12 = time12;
    }

    private int getTime12NS() {
        return Time12NS;
    }

    private void setTime12NS(int time12ns) {
        Time12NS = time12ns;
    }

    private int getFloating() {
        return Floating;
    }

    private void setFloating(int floating) {
        Floating = floating;
    }

    private int getNumIterations() {
        return numIterations;
    }

    private void setNumIterations(int numIterations) {
        this.numIterations = numIterations;
    }

    public ArrayList<String> getTimeNames() {
        return timeNames;
    }
}
