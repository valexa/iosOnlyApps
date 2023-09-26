//
//  AppDelegate.h
//  SpeakTime
//
//  Created by Vlad Alexa on 4/10/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpeakTimeController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;	
	SpeakTimeController *speakTimeController;
    NSUserDefaults *defaults;
	NSTimeInterval lastFire;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
