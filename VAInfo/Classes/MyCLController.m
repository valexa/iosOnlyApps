//
//  MyCLController.m
//  VAinfo
//
//  Created by Vlad Alexa on 3/30/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//

#import "MyCLController.h"

@implementation MyCLController

@synthesize locationManager;
@synthesize delegate;

- (id) init {
    self = [super init];
    if (self != nil) {
        locationManager = [[CLLocationManager alloc] init];
		
        locationManager.delegate = self; // send loc updates to myself		
		
		[locationManager startUpdatingLocation];
        
        [locationManager requestWhenInUseAuthorization];
		
		if ([CLLocationManager headingAvailable]){
			locationManager.headingFilter = 5;
			[locationManager startUpdatingHeading];
		}
		
    }
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	[self.delegate locationUpdate:[locations firstObject]];
    CLLocation *location = [locations firstObject];
	if (location.horizontalAccuracy > 0 && location.horizontalAccuracy < 500 ) {
        [manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[self.delegate locationUpdate:newLocation];	
    //NSLog(@"Location: %@", [newLocation description]);
	//NSLog(@"latitude %+.6f, longitude %+.6f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);		
    if (newLocation.horizontalAccuracy > 0 && newLocation.horizontalAccuracy < 500 ) {
        [manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading
{
	// If the accuracy is valid, go ahead and process the event.
	if (newHeading.headingAccuracy > 0)	{
		//NSLog(@"Heading: %f true: %f", newHeading.magneticHeading,newHeading.trueHeading);		
		[self.delegate headingUpdate:newHeading];			
	    //[manager stopUpdatingHeading];	
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
	//NSLog([NSString localizedStringWithFormat:@"Error domain: \"%@\"  Error code: %d\n Description: \"%@\"\n", [error domain], [error code] , [error localizedDescription]]);					
}

- (void)dealloc {
    [locationManager release];
    [super dealloc];     
}

@end
