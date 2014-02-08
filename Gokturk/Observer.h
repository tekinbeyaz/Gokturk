//
//  Observer.h
//  Gokturk
//
//  Created by Tekin Beyaz on 23/01/14.
//  Copyright (c) 2014 Tekin Beyaz. All rights reserved.
//
// This class will only hold values for now. I may use it for calculations later.

#import <Foundation/Foundation.h>

@interface Observer : NSObject
@property double latitude;
@property double longitude;
@property int  heading;
@property double DSTOffset;
@property double rawOffset;
@property NSString *timeZoneId;
@property NSString *timeZoneName;

-(void) createObserverWithLatitude:(double) newLatitude andLongitude:(double) newLongitude andHeading:(int) newHeading andTimeZoneId:(NSString *) newTimeZoneId andTimeZoneName:(NSString *) newTimeZoneName andDSTOffset:(int) newDSTOffset andRawOffset:(int)newRawOffset ;

@end
