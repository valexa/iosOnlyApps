//
//  RemoteIOAU.h
//  AirSay
//
//  Created by Vlad Alexa on 4/5/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface RemoteIOAU : NSObject <AVAudioSessionDelegate>{

    AudioComponentInstance audioUnit;
    float micLevel;
    BOOL micRouted;    
    BOOL micMuted;
}
@property (nonatomic) BOOL micMuted;
@property (nonatomic) BOOL micRouted;
@property (nonatomic) float micLevel;
@property (readonly, nonatomic) AudioComponentInstance audioUnit;


-(void)startListeningWithFrequency:(float)frequency;
-(void)stopUnit;
-(void)startUnit;

-(void)setSpeakerDefault;
-(void)setSpeaker;
-(BOOL)audioIsAlreadyPlaying;
-(NSString*)routeName;
-(NSArray*)outputDestinations;
-(NSNumber*)outputDestination;


@end
