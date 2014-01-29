//
//  ViewController.m
//  Gokturk
//
//  Created by Tekin Beyaz on 13/01/14.
//  Copyright (c) 2014 Tekin Beyaz. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Observer.h"
#import "Astronomy.h"



@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *latText;
@property (weak, nonatomic) IBOutlet UITextField *lonText;
@property (weak, nonatomic) IBOutlet UIButton *calculateBtn;
@property (weak, nonatomic) IBOutlet UISlider *gmtSlider;
@property (weak, nonatomic) IBOutlet UILabel *gmtLabel;
@property (weak, nonatomic) IBOutlet UISwitch *DSTSwitch;
@property (weak, nonatomic) IBOutlet UIButton *getPosition;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property double latitude;
@property double longitude;
@property int rawOffset;
@property int dstOffset;
@property NSString *timeZoneName;
@property NSString *timeZoneId;
@property int day, month, year;
@property double zenith_offical, zenith_civil, zenith_nautical, zenith_astronomical;
@property Observer *observer;
@property BOOL hasRecievedLocation;
@end

@implementation ViewController
- (IBAction)getPosition:(id)sender {
    /* We need a location */
        [locationManager startUpdatingLocation];


}

- (IBAction)gmtUpdate:(id)sender {
    _gmtSlider.value = (int) _gmtSlider.value;
    _gmtLabel.text = [NSString stringWithFormat:@"%i Hours.", (int)_gmtSlider.value];
}

- (IBAction)calculate:(id)sender {
   
    //Create Observer instance
    _observer = [[Observer alloc] init];
    if (!_hasRecievedLocation) {
        _latitude = [_latText.text floatValue];
        _longitude = [_lonText.text floatValue];
        _rawOffset = _gmtSlider.value;
        if (_DSTSwitch.on) {
            _dstOffset = 1;
        } else {
            _dstOffset = 0;
        }
    }
    [_observer createObserverWithLatitude:_latitude andLongitude:_longitude andHeading:180
                             andTimeZoneId:_timeZoneId andTimeZoneName:_timeZoneName
                             andDSTOffset:_dstOffset andRawOffset:_rawOffset];
    NSDate *date = _datePicker.date;
    Astronomy *astronomy = [[Astronomy alloc] init];
    NSString *sunSet = [astronomy sunSet:_observer andDate:date andZenith:_zenith_offical];
    NSString *sunRise = [astronomy sunRise:_observer andDate:date andZenith:_zenith_offical];
    
    NSString *message = [@"Sun Rise : " stringByAppendingString:sunRise];
    message = [message stringByAppendingString:@"\n"];
    message = [message stringByAppendingString:@"Sun Set : "];
    message = [message stringByAppendingString:sunSet];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sun Times" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    
    [alertView show];
    _gmtSlider.enabled = YES;
    _DSTSwitch.enabled = YES;
    _hasRecievedLocation = NO;

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [_spinner stopAnimating];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Initialize location Manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    _zenith_offical = 90.833;
    _zenith_civil   = 96;
    _zenith_nautical = 102;
    _zenith_astronomical = 108;
    textField = _lonText;
    [_lonText setReturnKeyType:UIReturnKeyDone];
    [_latText setReturnKeyType:UIReturnKeyDone];
    self.lonText.delegate = self;
    self.latText.delegate = self;
    
    _hasRecievedLocation = NO;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CLLocation Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    _latitude = (double) newLocation.coordinate.latitude;
    _longitude = (double) newLocation.coordinate.longitude;
    _latText.text = [NSString stringWithFormat:@"%f", _latitude];
    _lonText.text = [NSString stringWithFormat:@"%f", _longitude];
    _hasRecievedLocation = YES;
    
    /* We should retrieve UTC Offset and DST */
    /* We will use Google Time Zone API */
    
    NSString *urlAsString = @"https://maps.googleapis.com/maps/api/timezone/json";
    urlAsString = [urlAsString stringByAppendingString:@"?location="];
    urlAsString = [urlAsString stringByAppendingString:_latText.text];
    urlAsString = [urlAsString stringByAppendingString:@","];
    urlAsString = [urlAsString stringByAppendingString:_lonText.text];
    urlAsString = [urlAsString stringByAppendingString:@"&timestamp="];
    
    /* Calculate timestamp */
    
    NSDate *date;
    date = [[NSDate alloc] init];
    date = _datePicker.date;
    int timestamp;
    timestamp = (int)[date timeIntervalSince1970];
    
    
    
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"%i", timestamp]];
    urlAsString = [urlAsString stringByAppendingString:@"&sensor=false"];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    [_spinner startAnimating];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [connection start];


    
    //We had a location, so we dont need this.
    [locationManager stopUpdatingLocation];
    
    
    
}


#pragma mark NSURLConnection Delegate Methods


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now

    NSError *jsonError;
    
    id jsonData = [NSJSONSerialization
                   JSONObjectWithData:_responseData
                   options: NSJSONReadingAllowFragments
                   error:&jsonError];
    
    if (jsonData != nil && jsonError == nil) {
        if ([jsonData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *deserializedDictionary = jsonData;
            NSString *dstOff = [deserializedDictionary  valueForKey:@"dstOffset" ];
            NSString *rawOff = [deserializedDictionary valueForKey:@"rawOffset"];
            _timeZoneId = [deserializedDictionary valueForKey:@"timeZoneId"];
            _timeZoneName = [deserializedDictionary valueForKey:@"timeZoneName"];
            _dstOffset = [dstOff intValue];
            
            _rawOffset = [rawOff intValue];
            _rawOffset /= 3600;
            _dstOffset /= 3600;
            _gmtSlider.value = _rawOffset;
            
            if (_dstOffset>0) {
                [_DSTSwitch setOn:YES animated:YES];

                
            } else {
                [_DSTSwitch setOn:NO animated:YES];
            }

            _DSTSwitch.enabled = NO;
        }
    }
    _gmtLabel.text = [NSString stringWithFormat:@"%i Hours.", _rawOffset];
    _gmtSlider.enabled = NO;
    [_spinner stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error."
                                                        message:@"Error retrieving data from Google API. You should set values by hand."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
    [alertView show];
    [_spinner stopAnimating];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_lonText resignFirstResponder];
    [_latText resignFirstResponder];
    return YES;
}
@end

