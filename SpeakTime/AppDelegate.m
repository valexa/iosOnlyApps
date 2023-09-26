//
//  AppDelegate.m
//  SpeakTime
//
//  Created by Vlad Alexa on 4/10/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import "AppDelegate.h"

#import "SpeakTimeController.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation AppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        speakTimeController = [[SpeakTimeController alloc] initWithNibName:@"SpeakTimeController_iPhone" bundle:nil];     
    } else {
        speakTimeController = [[SpeakTimeController alloc] initWithNibName:@"SpeakTimeController_iPad" bundle:nil];
    }
    self.window.rootViewController = speakTimeController;
    [self.window makeKeyAndVisible];
	
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerLoop:) userInfo:nil repeats:YES]; 
    
    //[application beginReceivingRemoteControlEvents]; 
      
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    //not fired on temporary backgrounding intreruptions
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //fired on all backgrounding
    if ([speakTimeController.audioPlayer isPlaying] == YES) {
        [speakTimeController.audioPlayer stop];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //not fired on app start
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //fired on all foregrounding    
    
	[defaults synchronize];    
    
    NSError *activationErr  = nil;    
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];    
    if (activationErr) NSLog(@"Error activating our audio session");  
    
    if ([defaults boolForKey:@"mixEnabled"] == NO) { //stops outher sounds, plays while locked
        //UInt32 audioRouteOverride = kAudioSessionCategory_MediaPlayback;
        //AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,sizeof (audioRouteOverride),&audioRouteOverride);         
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil]; 
    }else { //mixes with sound, does not play while locked
        //UInt32 audioRouteOverride = kAudioSessionCategory_AmbientSound;
        //AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,sizeof (audioRouteOverride),&audioRouteOverride);
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];                        
    }  
    
    lastFire = CFAbsoluteTimeGetCurrent();    
	[speakTimeController performSelector:@selector(speakTime) withObject:nil afterDelay:2];
	[speakTimeController syncUI];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

-(void)timerLoop:(NSTimer*)timer
{	
    [speakTimeController syncUI]; 
    
    NSNumber *interval = [defaults objectForKey:@"timerInterval"];
    if (!interval) interval = [NSNumber numberWithInt:60];
    if (CFAbsoluteTimeGetCurrent()-lastFire > [interval intValue]) {
        lastFire = CFAbsoluteTimeGetCurrent();
        [speakTimeController speakTime];        
    }  
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"play");
                break;                
            case UIEventSubtypeRemoteControlPreviousTrack:
            
                break;                
            case UIEventSubtypeRemoteControlNextTrack:

                break;                
            default:
                break;
        }
    }
}

@end
