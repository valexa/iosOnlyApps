//
//  UserPrompts.m
//  VTrace
//
//  Created by Vlad Alexa on 6/26/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "UserPrompts.h"


@implementation UserPrompts

@synthesize delegate,appID;

- (id) initWithAppID:(int)theID delegate:(id<UserPromptsDelegate>)theDelegate
{
    self = [super init];    
	if (self) {		
		self.delegate = theDelegate;
		self.appID = theID;	
		
        defaults = [NSUserDefaults standardUserDefaults]; 
		
	}
	return self;
}

-(void)incrementRunCount{
    
    NSDate *lastCount = [defaults objectForKey:@"lastCountDate"];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastCount];
    
    if (interval > 86400 || lastCount == nil) {
        int count = [[defaults objectForKey:@"runCount"] intValue];
        NSLog(@"App %i loaded for the %ith time/day",appID,count);				
        [defaults setInteger:count+1 forKey:@"runCount"];	
        [defaults setObject:[NSDate date] forKey:@"lastCountDate"];
        [defaults synchronize];	
        
        //show review prompt every 50 runs if did not review or rate
        if (count > 0 && count % 50 == 0 && [defaults boolForKey:@"didReview"] == FALSE) {	
            [self askForReview:count];
        }
        
        //show ads prompt every 100 runs if did not remove ads
        if (count > 0 && count % 100 == 0 && [defaults boolForKey:@"removedAds"] == FALSE) {	
            [self askForPurchase:count];
        }        
    }
    
}

- (void)askForReview:(int)count{
	UIAlertView *sendAlert = [[UIAlertView alloc] initWithTitle:@"The AppStore needs your feedback" message:[NSString stringWithFormat:@"It looks like you found this free application usefull (%i uses), do you want to open the AppStore and review or rate it ?",count] delegate:self cancelButtonTitle:@"Maybe Later" otherButtonTitles:@"OK" , nil];                                              				                                             		
	[sendAlert addButtonWithTitle:@"Already Did"];
	[sendAlert show];
}

- (void)askForPurchase:(int)count{
	UIAlertView *sendAlert = [[UIAlertView alloc] initWithTitle:@"The iAd can be removed for a one time fee on all your devices" message:[NSString stringWithFormat:@"Are you interested in doing this ?"] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"OK" , nil];                                              				                                             		
	[sendAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if ([alertView.title isEqualToString:@"The AppStore needs your feedback"]){
		if (buttonIndex == 1) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/app/vtrace/id%i?mt=8",appID]]];			
		}
		if (buttonIndex == 2) {
			[defaults setBool:FALSE forKey:@"didReview"];
			[defaults synchronize];				
		}
	}	
	if ([alertView.title isEqualToString:@"The iAd can be removed for a one time fee on all your devices"]){
		if (buttonIndex == 1) {
			if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(adsButtonPressed)] ) {	
				[self.delegate adsButtonPressed];			
			} else {
				NSLog(@"Delegate does not respond to adsButtonPressed");
			}			
		}
	}	
}

- (void)dealloc {
	NSLog(@"UserPrompts freed");
}

@end
