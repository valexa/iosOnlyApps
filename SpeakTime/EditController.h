//
//  EditController.h
//  SpeakTime
//
//  Created by Vlad Alexa on 10/4/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpeakTimeController;

@interface EditController : UIViewController <UITextFieldDelegate> {

	SpeakTimeController *speakTimeController;
	NSUserDefaults *defaults;
	IBOutlet UITextField *hourPrefixField;
	IBOutlet UITextField *minutePrefixField;
	IBOutlet UITextField *endingPrefixField;
	IBOutlet UILabel *timezoneLabel;	
	IBOutlet UILabel *hourLabel;
	IBOutlet UILabel *minuteLabel;
	IBOutlet UILabel *endingLabel;
	IBOutlet UITextView *helpText;
	IBOutlet UILabel *andText;	
	BOOL textChanged;

    UIPopoverController *parentPopOver;      
	
}

@property (nonatomic, assign) SpeakTimeController *speakTimeController;
@property (nonatomic, assign) UIPopoverController *parentPopOver;

-(IBAction)dismissSelf:(id)sender;
-(IBAction)setDefault:(id)sender;

@end
