//
//  SpeakTimeController.h
//  SpeakTime
//
//  Created by Vlad Alexa on 9/11/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

#import <AudioToolbox/AudioServices.h>

@interface SpeakTimeController : UIViewController <UIPopoverControllerDelegate> {

	AVAudioPlayer *audioPlayer;
	NSString *hourPrefix;
	NSString *minutePrefix;
	NSUserDefaults *defaults;	
	IBOutlet UILabel *theText;
	IBOutlet UIView *swipeView;	
    IBOutlet UIButton *muteButton;
    IBOutlet UIButton *infoButton;    
    IBOutlet UIView *timezone1;
    IBOutlet UIView *timezone2;
    IBOutlet UIView *timezone3;    
	IBOutlet UIImageView *selectorRail;
	IBOutlet UIImageView *selectorKnob;
	IBOutlet UIImageView *selector1;
	IBOutlet UIImageView *selector2;
	IBOutlet UIImageView *selector3;    
	IBOutlet UIView *helpView;
	IBOutlet UIView *helpView4inch;
    NSMutableString *spokenText;
	//SystemSoundID Woosh;    
    BOOL inBackground;
    UIPopoverController *popOver;
}

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

-(IBAction)info:(id)sender;
-(IBAction)closeinfo:(id)sender;
- (IBAction)toggleMute:(id)sender;
- (IBAction)editZone:(id)sender;

-(void)syncUI;

+(NSTimeZone*)getTimeZone;
+(NSArray*)getHourAndMinutes:(NSTimeZone*)zone;
+(NSString*)check24hour:(NSString*)string;
+(NSString*)getLocalCTime:(NSString*)stringFormat;
+(NSString*)getGMTCTime:(NSString*)stringFormat;
+(NSString*)getAMPMForTimezone:(NSTimeZone*)zone;

-(void)speakTime;
-(NSString*)getTimeString;
-(void)speakTime;
-(void)playFile:(id)sender;
-(void)swipeAnimation;
-(void)refreshSwipeAnimation;
-(UIImage *)imageFromText:(NSString *)text;

+(NSString*)nameFromTimeZone:(NSTimeZone*)zone;
-(void)setTimeZone:(NSTimeZone*)zone forView:(UIView*)view;

@end
