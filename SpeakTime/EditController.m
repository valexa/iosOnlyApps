    //
//  EditController.m
//  SpeakTime
//
//  Created by Vlad Alexa on 10/4/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "EditController.h"

#import "SpeakTimeController.h"

@implementation EditController

@synthesize speakTimeController,parentPopOver;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
		
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	defaults = [NSUserDefaults standardUserDefaults];	
    
    NSTimeZone *zone = [SpeakTimeController getTimeZone];
	NSArray *theArr = [SpeakTimeController getHourAndMinutes:zone];	
	NSString *theHours = [theArr objectAtIndex:0];
	NSString *theMinutes = [theArr objectAtIndex:1];		
	NSString *theEnding = [theArr objectAtIndex:2];	
    NSString *name = [SpeakTimeController nameFromTimeZone:zone];    
    
	hourPrefixField.text = [defaults objectForKey:@"hourPrefix"];
	minutePrefixField.text = [defaults objectForKey:@"minutePrefix"];
	endingPrefixField.text = [defaults objectForKey:@"endingPrefix"];	
	hourLabel.text = theHours;
	minuteLabel.text = theMinutes;
	endingLabel.text = theEnding;
	timezoneLabel.text = [NSString stringWithFormat:@"in %@",name];    	    
    if (zone == [NSTimeZone defaultTimeZone]) timezoneLabel.text = @"";
	
	if ([theMinutes isEqualToString:@"00"]) {
		[andText setHidden:YES];
	}
	
	if (self.view.bounds.size.height < 400) {
		[helpText setHidden:YES];
	}else {
		[helpText setHidden:NO];		
	}	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad) return (interfaceOrientation == UIInterfaceOrientationPortrait);     
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

-(IBAction)dismissSelf:(id)sender
{
    if (parentPopOver == nil) {
        [self dismissModalViewControllerAnimated:YES];            
    }else {
        [parentPopOver dismissPopoverAnimated:NO];
        [parentPopOver.delegate popoverControllerDidDismissPopover:parentPopOver]; //we have to do this manually it seems
    }
}

-(IBAction)setDefault:(id)sender{
	[defaults setObject:@"It's" forKey:@"hourPrefix"];
	[defaults setObject:@"o clock," forKey:@"minutePrefix"];
	[defaults setObject:@"minutes" forKey:@"endingPrefix"];	
	[defaults synchronize];		
	hourPrefixField.text = [defaults objectForKey:@"hourPrefix"];
	minutePrefixField.text = [defaults objectForKey:@"minutePrefix"];
	endingPrefixField.text = [defaults objectForKey:@"endingPrefix"];	
	[speakTimeController speakTime];
	if (self.modalPresentationStyle == UIModalPresentationFormSheet) [speakTimeController refreshSwipeAnimation];	
}

#pragma mark calbacks

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
	//NSLog(@"textFieldShouldReturn");
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    [theTextField resignFirstResponder];		
    return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField{	
	//NSLog(@"textFieldDidEndEditing");
	if (textChanged == YES) {
		[defaults setObject:hourPrefixField.text forKey:@"hourPrefix"];
		[defaults setObject:minutePrefixField.text forKey:@"minutePrefix"];
		[defaults setObject:endingPrefixField.text forKey:@"endingPrefix"];		
		[defaults synchronize];	
		[speakTimeController speakTime];
		if (self.modalPresentationStyle == UIModalPresentationFormSheet) [speakTimeController refreshSwipeAnimation];
		textChanged = NO;
	}
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{	
	//NSLog(@"shouldChangeCharactersInRange");
	textChanged = YES;
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // Dismiss the keyboard when the view outside the text field is touched.
    [hourPrefixField resignFirstResponder];	
	[self textFieldShouldReturn:hourPrefixField];	
    [minutePrefixField resignFirstResponder];	
	[self textFieldShouldReturn:minutePrefixField];	
    [endingPrefixField resignFirstResponder];	
	[self textFieldShouldReturn:endingPrefixField];		
}

@end
