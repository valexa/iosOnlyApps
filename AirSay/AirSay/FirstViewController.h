//
//  FirstViewController.h
//  AirSay
//
//  Created by Vlad Alexa on 4/6/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>

@class RemoteIOAU;

@interface FirstViewController : UIViewController{
    IBOutlet UIView *centerView;
    
    IBOutlet MPVolumeView *volume;
    IBOutlet MPVolumeView *route; 
    IBOutlet UIImageView *speaker;
    
    IBOutlet UILabel *inNameLabel;
    IBOutlet UIProgressView *inMeter;
    IBOutlet UIButton *mute;    
    RemoteIOAU *remoteIOAU;
}

@property (readonly, nonatomic)  RemoteIOAU *remoteIOAU;

-(IBAction)mute:(id)sender;

-(void)playPause;

-(UIImage *)UIImageFromPDF:(NSString*)fileName size:(CGSize)size;
-(void)animatePush:(id)target;


@end
