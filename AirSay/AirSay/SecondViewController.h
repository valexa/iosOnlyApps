//
//  SecondViewController.h
//  AirSay
//
//  Created by Vlad Alexa on 4/6/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface SecondViewController : UIViewController <AVAudioPlayerDelegate,UITextViewDelegate>{
    IBOutlet UIView *centerView;
    
    IBOutlet MPVolumeView *volume;
    IBOutlet MPVolumeView *route;
    IBOutlet UIImageView *speaker;    
    
    IBOutlet UIImageView *typewriter;
    IBOutlet UITextView *txt;
    IBOutlet UIButton *startTyping;

    IBOutlet UIImageView *radio;    
	IBOutlet UISlider   *progressBar;
	IBOutlet UILabel	*currentTime;
	IBOutlet UILabel	*duration;
	IBOutlet UIProgressView   *meter;
	IBOutlet UIButton  *closeRadio;    
       
	BOOL	inBackground;        
    NSTimer *updateTimer;
	NSTimeInterval previousTime;
}

-(void)radio:(BOOL)show;
-(void)typewriter:(BOOL)show;

-(void)speakText;
-(IBAction)playFile:(id)sender;

-(IBAction)closeRadio:(id)sender;
-(IBAction)startTyping:(id)sender;

@end
