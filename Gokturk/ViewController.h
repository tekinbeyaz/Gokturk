//
//  ViewController.h
//  Gokturk
//
//  Created by Tekin Beyaz on 13/01/14.
//  Copyright (c) 2014 Tekin Beyaz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, NSURLConnectionDelegate, UITextFieldDelegate> {
    CLLocationManager *locationManager;
    NSMutableData *_responseData;
    UITextField *textField;
}
@end
