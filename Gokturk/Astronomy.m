//
//  Astronomy.m
//  Gokturk
//
//  Created by Tekin Beyaz on 23/01/14.
//  Copyright (c) 2014 Tekin Beyaz. All rights reserved.
//

#import "Astronomy.h"
#import "Observer.h"
#import "Math.h"

@implementation Astronomy
double pi = 3.14159265358979323846;
-(NSString *) sunSet :(Observer *) observer andDate:(NSDate *) date andZenith:(double) newZenith{
    return [Astronomy calculate:observer andDate:date andZenith:newZenith andSetOrRise:true];
}
-(NSString *) sunRise : (Observer *) observer andDate:(NSDate *) date andZenith:(double) newZenith {
    return [Astronomy calculate:observer andDate:date andZenith:newZenith andSetOrRise:false];
}
+(NSString *) calculate : (Observer *) observer andDate:(NSDate *) date andZenith:(double) newZenith andSetOrRise:(BOOL) setOrRise {
    
    //Calculate Day of Year first.
    
    //retrieve secelcted day, month, year from selected date
    
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone: [NSTimeZone systemTimeZone]];
    
    // Specify the date components manually (year, month, day, hour, minutes, etc.)
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDateComponents *timeZoneComps=[[NSDateComponents alloc] init];
    [timeZoneComps setHour:23];
    [timeZoneComps setMinute:59];
    [timeZoneComps setSecond:0];
    [timeZoneComps setDay:[comps day]];
    [timeZoneComps setMonth:[comps month]];
    [timeZoneComps setYear:[comps year]];
    
    // transform the date compoments into a date, based on current calendar settings
    NSDate *newDate = [calendar dateFromComponents:timeZoneComps];
    
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: newDate];

//    NSDateComponents *components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    int N1 = floor(275 * [components month]/9);
    int N2 = floor(([components month] + 9) / 12);
    int N3 = (1 + floor(([components year] - 4 * floor([components year] / 4) + 2) / 3));
    int N = N1 - (N2 * N3) + [components day] - 30;
    
    
    //    convert the longitude to hour value and calculate an approximate time
    double lngHour = observer.longitude / 15;
    double t;
    if (setOrRise) {
            t = N + ((18 - lngHour) / 24);  //Settimg Time
    } else {
            t = N + ((6 - lngHour) / 24); //Rising Time
    }
    
    //Calculate the Sun's mean anomaly
    double M = (0.9856 * t) - 3.289;
    //Calculate the Sun's true longitude
    double L = M + (1.916 * sin(M * (pi/180))) + (0.020 * sin(2*M* (pi/180))) + 282.634;
    if (L>360) {
        L -= 360;   //First substract then assign
    } else {
        if (L<0) {
            L += 360;   //First add then assign
        }
    }
    //Calculate the Sun's Right Ascension
    double RA = (180/pi) * atan(0.91764 * tan(L * (pi/180)));
    
    //RA value needs to be in the same quadrant as L
    double LQuadrant = (floor(L/90)) * 90;
    double RQuadrant = (floor(RA/90)) * 90;
    RA = RA + (LQuadrant - RQuadrant);
    
    //RA value needs to be converted into hours
    RA = RA / 15;
    
    //Calculate the Sun's declination
    double sinDec = 0.39782 * sin(L* (pi/180));
    double cosDec = cos(((180/pi) * asin(sinDec))* (pi/180));
    //Calculate the Sun's local hour angle
    double zenith = 90.833f;
    double cosH = (cos(zenith* (pi/180)) - (sinDec * sin(observer.latitude* (pi/180)))) / (cosDec * cos(observer.latitude* (pi/180)));
    //Finish calculating H and convert into hours
    double H;
    if (setOrRise) {
        H = (180/pi) * acos(cosH);
    } else {
        H = 360 - ((180/pi) * acos(cosH));
    }

    H /= 15;
    //Calculate local mean time of rising / setting
    double T = H + RA - (0.06571 * t) - 6.622;
    //Adjust back to UTC
    double UT = T - lngHour;
    if (UT>24) {
        UT = UT - 24;
    } else {
        if (UT<0) {
            UT = UT + 24;
        }
    }
 //do conversion
    UT = UT + observer.rawOffset + observer.DSTOffset;
    NSString *hour = [NSString stringWithFormat:@"%i", (int)floor(UT)];
    NSString *minute = [NSString stringWithFormat:@"%i", (int)((UT - floor(UT))*60)];
    if ([hour intValue] < 10) {hour = [@"0" stringByAppendingString:hour];}
    if ([minute intValue] < 10) {minute = [@"0" stringByAppendingString:minute];}
    return [hour stringByAppendingString:[@":" stringByAppendingString:minute]];
}
@end
