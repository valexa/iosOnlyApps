//
//  MyCLController.h
//  VAinfo
//
//  Created by Vlad Alexa on 3/30/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>



@interface MyCLController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
    id delegate;	
}

@property (nonatomic, retain) CLLocationManager *locationManager;  
@property (nonatomic, assign) id  delegate;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

@end

@protocol MyCLControllerDelegate 
@required

- (void)locationUpdate:(CLLocation *)location;
- (void)headingUpdate:(CLHeading*)heading;

@end