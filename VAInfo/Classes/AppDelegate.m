//
//  AppDelegate.h
//  VAinfo
//
//  Created by Vlad Alexa on 07/7/08.
//  Copyright 2008 __VladAlexa__. All rights reserved.
//

#import "AppDelegate.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import Firebase;

@implementation AppDelegate

@synthesize list,compassView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Fabric with:@[[Crashlytics class]]];

    [FIRApp configure];
		
	//get defaults
	defaults = [NSUserDefaults standardUserDefaults];
    
    //register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theEvent:) name:@"AppDelegateEvent" object:nil];
			
	//
	//get startup data
	//
	self.list = [AppData getData];
	//CFShow(list);

	//
	//do UI stuff
	//
		
	//main view
	mainViewController = [[MainViewController alloc] initWithNibName:nil bundle:nil];
	mainViewController.list = list;
	
	//proc view
	//procViewController = [[ProcViewController alloc] initWithNibName:nil bundle:nil];

	//nav controller
	navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    graphsViewController = [storyboard instantiateViewControllerWithIdentifier:@"GraphsViewController"];
		
	//add Send button
	UIBarButtonItem* sendBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendButtonPressed)];
	mainViewController.navigationItem.rightBarButtonItem = sendBarButtonItem;
	[sendBarButtonItem release];
	
	//add Tasks button
	UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Graphs" style:UIBarButtonItemStyleBordered target:self action:@selector(graphsButtonPressed)];
	mainViewController.navigationItem.leftBarButtonItem = leftBarButtonItem;
	[leftBarButtonItem release];	
		
	//create the window
	window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [window setRootViewController:navigationController]; //needed for autorotate since iOS 6.0
	[window addSubview:[navigationController view]]; //still needed to add the view now otherwise it is added last over everything else
		
	//Load the sounds
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"New" ofType:@"caf"]], &New);
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Click" ofType:@"caf"]], &Click);	
	
	//
	//add more data
	//	
	
	//get location data	
	[list setValue:[NSString stringWithFormat:@"Loading ...."] forKey:@"Latitude, Longitude"];
	[list setValue:[NSString stringWithFormat:@"N/A"] forKey:@"Place"];	
	[list setValue:[NSString stringWithFormat:@"N/A"] forKey:@"Altitude (precision)"];
	[list setValue:[NSString stringWithFormat:@"N/A"] forKey:@"Speed"];	
	[list setValue:[NSString stringWithFormat:@"N/A"] forKey:@"Heading"];	
    locationController = [[MyCLController alloc] init];
    locationController.delegate = self;
	
	//get ip data
	[list setValue:[NSString stringWithFormat:@"Loading ...."] forKey:@"IP (public)"];
	[[[MyIPController alloc] initWithURL:@"http://vladalexa.com/scripts/php/var.php" delegate:self] autorelease];
	//NSURL *netIPURL = [NSURL URLWithString:@"http://whatismyip.org"];
	//NSString *pubIP = [NSString stringWithContentsOfURL:netIPURL encoding:NSUTF8StringEncoding error:nil];
	//[list setValue:pubIP forKey:@"IP (public)"];	
	
	//get hostname data
	[list setValue:[NSString stringWithFormat:@"N/A"] forKey:@"Hostname"];	
	
	//monitor battery
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:@"UIDeviceBatteryLevelDidChangeNotification" object:[UIDevice currentDevice]];
	
	//and compass button
	compassView = [[CompassView alloc] initWithFrame:CGRectZero];
	compassView.magnif = 0.1;
	[compassView setHidden:YES];
	[window addSubview:compassView];    
    //[[navigationController view] addSubview:compassView]; //breaks rotation
    
	[window makeKeyAndVisible];
        
    return YES;
	
}


- (void)dealloc {
	[mainViewController release];
	//[procViewController release];
	[navigationController release];
    [window release];
	[list release];
	[compassView release];
    [super dealloc];    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	self.list = [AppData getData];	
	mainViewController.list = list;		
	[[[MyIPController alloc] initWithURL:@"http://vladalexa.com/scripts/php/var.php" delegate:self] autorelease];
	//refresh view
	[mainViewController.table reloadData];
	//NSLog(@"Foregrounded");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

-(void)theEvent:(NSNotification*)notif
{
    if ([[notif object] isKindOfClass:[NSString class]])
    {
        if ([[notif object] isEqualToString:@"refresh"])
        {
            self.list = [AppData getData];
            mainViewController.list = list;
            [[[MyIPController alloc] initWithURL:@"http://vladalexa.com/scripts/php/var.php" delegate:self] autorelease];
            [locationController.locationManager startUpdatingLocation];
            //refresh view
            [mainViewController.table reloadData];
        }

    }
    if ([[notif userInfo] isKindOfClass:[NSDictionary class]])
    {
    }	
}

#pragma mark actions

-(void)tasksButtonPressed{		
	//[navigationController pushViewController:procViewController animated:YES];
}

-(void)graphsButtonPressed{
    //GraphsViewController *controller = [GraphsViewController alloc];

    [navigationController pushViewController:graphsViewController animated:YES];
}

-(void)sendButtonPressed{		
	SendViewController *controller = [[SendViewController alloc] initWithNibName:@"SendView" bundle:nil];
	controller.list = list;	
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	controller.modalPresentationStyle = UIModalPresentationFormSheet;
	[navigationController presentViewController:controller animated:YES completion:^{
        
    }];
	[controller release];
}     

/*
- (void)doneButtonPressed{
	//[secondNavigationController dismissModalViewControllerAnimated:YES];
	[navigationController popToRootViewControllerAnimated:YES];
}
*/ 
     

#pragma mark callbacks

- (void)locationUpdate:(CLLocation *)location
{
	//NSLog(@"Updated %@",[location description]);
	CLLocationDegrees mylat=location.coordinate.latitude;
	CLLocationDegrees mylong=location.coordinate.longitude;
	[list setValue:[NSString stringWithFormat:@"%f, %f",mylat,mylong] forKey:@"Latitude, Longitude"];	
	if (location.verticalAccuracy > 0) 	[list setValue:[NSString stringWithFormat:@"%1.0f (%1.0fm)", location.altitude,location.verticalAccuracy] forKey:@"Altitude (precision)"];
	if (location.speed > 0) [list setValue:[NSString stringWithFormat:@"%1.0f km/h", location.speed*3.6] forKey:@"Speed"];
	if (location.course >= 0) [list setValue:[self humanizeCourse:location.course] forKey:@"Heading"];		
	if ([compassView isHidden]) {
		[compassView setHidden:NO];
	}	
	[compassView syncCourse:location];	
	//get geocoded data on coords
	if (location.horizontalAccuracy > 0 && location.horizontalAccuracy < 500 ) {
		[self resolveCoords:location.coordinate];
		[list setValue:[NSString stringWithFormat:@"Loading ...."] forKey:@"Place"];
	}
	[mainViewController.table reloadData];	
}

-(void)resolveCoords:(CLLocationCoordinate2D)coord
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    [reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error){
        if ([placemarks count] > 0)
        {
            CLPlacemark *pmark = [placemarks objectAtIndex:0];
            AudioServicesPlaySystemSound (Click);
            [list setValue:[NSString stringWithFormat:@"%@, %@, %@",pmark.thoroughfare,pmark.locality,pmark.country] forKey:@"Place"];
            [mainViewController.table reloadData];
            NSLog(@"Geocoded %@",[list objectForKey:@"Place"]);
        }else{
            NSLog(@"No placemarks found for %f %f %@",location.coordinate.latitude,location.coordinate.longitude,[error localizedDescription]);
        }
    }];
}

- (void)headingUpdate:(CLHeading*)heading{
	//NSLog(@"Updated %@",[heading description]);	
	if ([compassView isHidden]) {
		[compassView setHidden:NO];
	}
	[compassView syncHeading:heading];	
}

- (void)addressResolver:(AddressResolver *)resolver didFinishWithStatus:(NSError *)error{
	if (error == nil){	
	    NSLog(@"Got hostname [%@]",resolver.name);	
		[list setValue:resolver.name forKey:@"Hostname"];							
	}else {
		[list setValue:@"Error" forKey:@"Hostname"];			
	}
	[mainViewController.table reloadData];
	[resolver release];
}

- (void) connectionDidFinish:(MyIPController *)connection{
	NSData *myData = connection.receivedData;	
	NSString *downdata = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    NSArray *lines = [downdata componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSString *ip = [lines objectAtIndex:2];
	if ([ip length] > 6 && [lines count] > 3) {
        NSLog(@"Updated ip [%@]",ip);
        [list setValue:ip forKey:@"IP (public)"];        
        AudioServicesPlaySystemSound (New);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];	
        //get hostname
        AddressResolver *addressResolver = [[AddressResolver alloc] initWithAddress:ip];
        addressResolver.delegate = self;
        [list setValue:[NSString stringWithFormat:@"Loading ...."] forKey:@"Hostname"];		
        [mainViewController.table reloadData];	     
    }        
    [downdata release];       
}

- (void) connectionDidFail:(MyIPController *)connection{
	[list setValue:@"Error" forKey:@"IP (public)"];	
	[mainViewController.table reloadData];	
}

- (void) batteryChanged:(NSNotification *)notification
{
	UIDevice *device = [notification object];
	float batt = device.batteryLevel;
	NSLog(@"Updated battery [%f]",batt);
	NSString *state = @""; 	
	if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) state = @"charging";
	[list setValue:[NSString stringWithFormat:@"%1.0f%% %@",batt*100,state] forKey:@"Battery"];	
	AudioServicesPlaySystemSound (New);
	[mainViewController.table reloadData];	
}

-(NSString*)humanizeCourse:(float)course
{
	
    NSString *latDirection = @"";
    if (course < 90 || course > 270) {
		latDirection = @"N";
	}else {
		latDirection = @"S";
	}
	
    NSString *longDirection = @"";
    if (course < 180){
		longDirection = @"E";
	}else {
		longDirection = @"W";
	}
	
    return [NSString stringWithFormat:@"%@%@",latDirection,longDirection];  
}

@end
