
// Pray Times Example
// By: Jandost Khoso

class Program
{
    static void Main ( string [ ] args )
    {
        PrayerTime p = new PrayTime();
        double lo = 25;
        double la = 55;
        int y = 0 , m = 0 , d = 0 , tz = 0;

        DateTime cc = DateTime.Now;
        y = cc.Year;
        m = cc.Month;
        d = cc.Day;
        tz = TimeZone.CurrentTimeZone.GetUtcOffset(new DateTime (y,m,d)).Hours;
        String [] s ;

        p.setCalcMethod ( 2 );
        p . setAsrMethod ( 0 );
        s = p . getDatePrayerTimes ( y , m , d , lo , la , tz );
        for(int i = 0 ; i < s.Length ; ++i )
        {
            Console . WriteLine ( s [ i ] );
        }
    }
}