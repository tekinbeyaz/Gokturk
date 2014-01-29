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
@property (strong, nonatomic) IBOutlet UILabel *timeZoneNameText;
@property (strong, nonatomic) IBOutlet UILabel *sunriseText;
@property (strong, nonatomic) IBOutlet UILabel *officalText;
@property (strong, nonatomic) IBOutlet UILabel *civilText;
@property (strong, nonatomic) IBOutlet UILabel *nauticalText;
@property (strong, nonatomic) IBOutlet UILabel *astonomicalText;
@property (strong, nonatomic) IBOutlet UILabel *sunsetText;
@property (strong, nonatomic) IBOutlet UILabel *locationText;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) CLGeocoder *myGeocoder;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [_spinner stopAnimating];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Initialize location Manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    
    [locationManager startUpdatingLocation];
    
    _zenith_offical = 90.833;
    _zenith_civil   = 96;
    _zenith_nautical = 102;
    _zenith_astronomical = 108;
    

    
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
    NSString *latitudeText = [NSString stringWithFormat:@"%f", _latitude];
    NSString *longitudeText = [NSString stringWithFormat:@"%f", _longitude];
    
    NSLog(@"Latitude : %f", _latitude);
    NSLog(@"Longitude : %f", _longitude);
    _hasRecievedLocation = YES;
    
    /* We should retrieve UTC Offset and DST */
    /* We will use Google Time Zone API */
    
    NSString *urlAsString = @"https://maps.googleapis.com/maps/api/timezone/json";
    urlAsString = [urlAsString stringByAppendingString:@"?location="];
    urlAsString = [urlAsString stringByAppendingString:latitudeText];
    urlAsString = [urlAsString stringByAppendingString:@","];
    urlAsString = [urlAsString stringByAppendingString:longitudeText];
    urlAsString = [urlAsString stringByAppendingString:@"&timestamp="];
    
    /* Calculate timestamp */
    
    NSDate *date;
    date = [[NSDate alloc] init];

    NSLog(@"Date : %@", date);
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


    
    
    //Create Observer instance
    _observer = [[Observer alloc] init];
    
    [_observer createObserverWithLatitude:_latitude andLongitude:_longitude andHeading:180
                            andTimeZoneId:_timeZoneId andTimeZoneName:_timeZoneName
                             andDSTOffset:_dstOffset andRawOffset:_rawOffset];
    
    Astronomy *astronomy = [[Astronomy alloc] init];
    

    NSString *sunSetOffical = [astronomy sunSet:_observer andDate:date andZenith:_zenith_offical];
    NSString *sunRise = [astronomy sunRise:_observer andDate:date andZenith:_zenith_offical];
    NSString *sunSetCivil = [astronomy sunSet:_observer andDate:date andZenith:_zenith_civil];
    NSString *sunSetNautical = [astronomy sunSet:_observer andDate:date andZenith:_zenith_nautical];
    NSString *sunSetAstronomical = [astronomy sunSet:_observer andDate:date andZenith:_zenith_astronomical];

    _sunriseText.text = sunRise;
    _officalText.text = sunSetOffical;
    _civilText.text = sunSetCivil;
    _nauticalText.text = sunSetNautical;
    _astonomicalText.text = sunSetAstronomical;
    
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
            
            
            NSLog(@"Time Zone Name : %@", _timeZoneId);
            _rawOffset = [rawOff intValue];
            _rawOffset /= 3600;
            _dstOffset /= 3600;
            _timeZoneId = [_timeZoneId stringByAppendingString:@"\n"];
            _timeZoneNameText.text = [_timeZoneId stringByAppendingString:_timeZoneName];

    }

        //Get the address.
        CLLocation *location = [[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude];
        self.myGeocoder = [[CLGeocoder alloc] init];
        [self.myGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error==nil && placemarks.count > 0) {
                 CLPlacemark *placemark = placemarks[0];
                 // We recieved the result
                 NSString *locationAddress = placemark.name;
                 locationAddress = [locationAddress stringByAppendingString:@"\n"];
                 locationAddress = [locationAddress stringByAppendingString:placemark.locality];
                 locationAddress = [locationAddress stringByAppendingString:@"\n"];
                 locationAddress = [locationAddress stringByAppendingString:placemark.country];
                 
                 _locationText.text = locationAddress;
                 
             } else { }
         }];
        
    [_spinner stopAnimating];
}
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error variable
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error."
                                                        message:@"Error retrieving data from Google API. You should set values by hand."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
    [alertView show];
    [_spinner stopAnimating];
}
@end

