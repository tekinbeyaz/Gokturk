//
//  Astronomy.h
//  Gokturk
//
//  Created by Tekin Beyaz on 23/01/14.
//  Copyright (c) 2014 Tekin Beyaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Observer.h"

@interface Astronomy : NSObject
-(NSString *) sunSet :(Observer *) observer andDate:(NSDate *) date andZenith:(double) newZenith;
-(NSString *) sunRise : (Observer *) observer andDate:(NSDate *) date andZenith:(double) newZenith;

//setOrRise : True for Set, False for Rise
@end
