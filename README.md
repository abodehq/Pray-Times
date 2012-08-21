Pray-Times
==========

Welcome to Pray Times, an Islamic project aimed at providing an open-source library for calculating Muslim prayers times.

Project Source : http://praytimes.org 
Project Languges Support ( -Java Script -  Python - PHP - Java - C++ - C# - Objective C )

you can choose other islamic services by visiting our web site : https://mos7af.com

General Usage

The first step for using PrayTimes in a web-page or widget is to include it using a line like this:

 <script type="text/javascript" src="PrayTimes.js"></script> 
After including PrayTimes.js, an object named prayTimes is created and is ready to use. We can immediately get the prayer times (using the default settings) from this object. For example, to get today's prayer times for a location with latitude 43, longitude -80, and time zone -5, we can call:

 prayTimes.getTimes(new Date(), [43, -80], -5);
There are several functions for adjusting calculation parameters. For example, we can call the following function (before calling getTimes) to change the calculation method to ISNA:

 prayTimes.setMethod('ISNA'); 
Details of the functions available in PrayTimes along with their description are provided below.

Get Prayer Times

The following function is used to retrieve prayer times for a given date and location:

getTimes (date, coordinates, timezone, dst, format)
The input parameters are described below:

date
The date for which prayer times are calculated. You can use new Date() to specify today. Date can be also entered as a triple [year, month, day]. For example, [2009, 2, 26] specifies February 26, 2009.
coordinates
Specifies the coordinates of the input location as a triple [latitude, longitude, elevation]. Latitude is a real number between -90 and 90, longitude is between -180 and 180, and elevation is a positive number, specifying the height in meters with respect to the surrounding terrain. The elevation parameter is optional. Examples of valid coordinates are [-43.2, 80.6] and [12.5, -25.8, 300].
timezone
The difference to Greenwich time (GMT) in hours. If omitted or set to 'auto', timezone is extracted from the system.
dst
Daylight Saving Time: 1 if date is in daylight saving time, 0 otherwise. If omitted or set to 'auto', dst is extracted from the system.
format
Output time format, according to the following table:
Format  Description	Example
24h	 24-hour time format	 16:45
12h	 12-hour time format	 4:45 pm
12hNS	 12-hour format with no suffix  	 4:45
Float	 Floating point number	 16.75
Return Value

getTimes return an associative array containing 9 prayer times (see here for the list of times and their definition). Each time can be accessed thorough its name. For example, if the output of getTimes function is stored in an object times, the time for sunrise can be accessed through times.sunrise.

Example

 var times = prayTimes.getTimes(new Date(), [43, -80], -5);
 document.write('Sunrise : '+ times.sunrise)
Set Calculation Method

There are several conventions for calculating prayer times. The default convention used in PrayTimes is Muslim World League. You can change the calculation method using the following function:

setMethod (method)
method can be any of the followings:

Method	Description
MWL	 Muslim World League
ISNA	 Islamic Society of North America
Egypt	 Egyptian General Authority of Survey
Makkah	 Umm al-Qura University, Makkah
Karachi	 University of Islamic Sciences, Karachi
Tehran	 Institute of Geophysics, University of Tehran
Jafari	 Shia Ithna Ashari (Ja`fari)

More information on the above calculation methods is provided here.


Example

 prayTimes.setMethod('Makkah');
Adjusting Parameters

The calculating parameters can be adjusted using the following function:

adjust (parameters)
parameters is an associative array composed of any number of the following parameters:

Parameter	Values	Description	Sample Value
imsak	 degrees  	 twilight angle	 18
minutes	 minutes before fajr	 10 min
fajr	 degrees	 twilight angle	 15
dhuhr	 minutes	 minutes after mid-day	 1 min
asr	 method	 asr juristic method; see the table below	 Standard
factor	 shadow length factor for realizing asr	 1.7
maghrib	 degrees	 twilight angle	 4
minutes	 minutes after sunset	 15 min
isha	 degrees	 twilight angle	 18
minutes	 minutes after maghrib	 90 min
midnight	 method	 midnight method; see the table below	 Standard
highLats	 method	higher latitudes adjustment; see below	 None

asr methods
Method	Description (more info)
Standard	 Shafii, Maliki, Jafari and Hanbali (shadow factor = 1)
Hanafi	 Hanafi school of tought (shadow factor = 2)

midnight methods
Method	Description
Standard	 The mean time from Sunset to Sunrise
Jafari	 The mean time from Maghrib to Fajr

higher latitudes methods
Method	Description (more info)
None	 No adjustments
NightMiddle	 The middle of the night method
OneSeventh	 The 1/7th of the night method
AngleBased	 The angle-based method (recommended)

Example

 prayTimes.adjust( {fajr: 16, dhuhr: '5 min', asr: 'Hanafi', isha: 15} );
Tuning Times

You can further tune calculated prayer times (for precaution) using the following function:

tune (offsets)
where offsets is an associative array containing time offsets in minutes for each prayer time.


Example

 prayTimes.tune( {sunrise: -1, sunset: 3.5} );
Notes:
By default, PrayTimes rounds minutes to the nearest values. To round a specific time up, you can tune it by +0.5 minutes, and to round it down, you can tune it by -0.5 minutes.
Tuning is the last step after calculating step, and thus, it has no effect on the calculation parameters. For example, if Isha is set to be 90 minutes after sunset, tuning sunset by 5 minutes will not push Isha forward.