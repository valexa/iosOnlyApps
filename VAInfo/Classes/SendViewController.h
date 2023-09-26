//
//  SendViewController.h
//  VAinfo
//
//  Created by Vlad Alexa on 4/3/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//

#import "CFHsend.h"
#import <AudioToolbox/AudioServices.h>

@interface SendViewController : UIViewController <UITextFieldDelegate> {
	
	NSMutableDictionary *list;
	
	IBOutlet UITextField *theAddress;
	IBOutlet UITextField *thePort;
	IBOutlet UIButton *sendButton;	
	
}

@property (nonatomic, retain) NSMutableDictionary *list;


-(IBAction)sendButtonPressed;

-(IBAction)siteButtonPressed;
-(IBAction)doneButtonPressed;

@end
