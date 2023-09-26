//
//  AppDelegate.m
//  VAinfo
//
//  Created by Vlad Alexa on 07/7/08.
//  Copyright 2008 __VladAlexa__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

#import "AppData.h"
#import "CFHsend.h"
#import "MyCLController.h"
#import "MyIPController.h"
#import "AddressResolver.h"

#import "MainViewController.h"
#import "SendViewController.h"
#import "ProcViewController.h"

#import "CompassView.h"

#import "VAInfo-Swift.h"

@interface AppDelegate : NSObject <UIApplicationDelegate , MyCLControllerDelegate , MyIPControllerDelegate ,AddressResolverDelegate> {

	UIWindow *window;
	
	UINavigationController *navigationController;
	
	MainViewController *mainViewController;
	ProcViewController *procViewController;
    GraphsViewController *graphsViewController;
			
	NSMutableDictionary *list;	
	
	UIAccelerationValue	myAccelerometer[3];	
    MyCLController *locationController;
		
	SystemSoundID New;
	SystemSoundID Click;		
	
	NSUserDefaults *defaults;
	
	CompassView *compassView;	
    
}

@property (nonatomic, retain) NSMutableDictionary *list;
@property (nonatomic, retain) CompassView *compassView;

- (void) locationUpdate:(CLLocation *)location;
- (void) connectionDidFinish:(MyIPController *)theConnection;
- (NSString*)humanizeCourse:(float)course;

-(void)sendButtonPressed;

@end

