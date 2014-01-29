//
//  Observer.m
//  Gokturk
//
//  Created by Tekin Beyaz on 23/01/14.
//  Copyright (c) 2014 Tekin Beyaz. All rights reserved.
//

#import "Observer.h"

@implementation Observer
@synthesize latitude, longitude, heading, timeZoneId, timeZoneName, DSTOffset, rawOffset;

-(void) createObserverWithLatitude:(double) newLatitude andLongitude:(double) newLongitude andHeading:(int) newHeading andTimeZoneId:(NSString *) newTimeZoneId andTimeZoneName:(NSString *) newTimeZoneName andDSTOffset:(double) newDSTOffset andRawOffset:(double)newRawOffset {
    self.latitude = newLatitude;
    self.longitude = newLongitude;
    self.heading= newHeading;
    self.rawOffset = newRawOffset;
    self.DSTOffset = newDSTOffset;
    self.timeZoneId = newTimeZoneId;
    self.timeZoneName = newTimeZoneName;
}
@end
