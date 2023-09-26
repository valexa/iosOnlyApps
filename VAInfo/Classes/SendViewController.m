//
//  SendViewController.m
//  VAinfo
//
//  Created by Vlad Alexa on 4/3/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//

#import "SendViewController.h"

@implementation SendViewController

@synthesize list;

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
	if (theTextField == theAddress) {
		[thePort becomeFirstResponder];
	}else {
		[thePort resignFirstResponder];		
	}									   
    return YES;
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{		
	//enable send button if address and port have text
	if ([theAddress.text length] > 7 && [thePort.text length] > 1){	
		[sendButton setEnabled:YES];		
	}else{	
		[sendButton setEnabled:NO];		
	}
	
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    [thePort resignFirstResponder];	
	[self textFieldShouldReturn:theAddress];	
}


- (IBAction)sendButtonPressed{	
	
	if ( [[list objectForKey:@"Network"] isEqual:@"None"] ){
		UIAlertView *sendAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Connection Unavailable" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil];                                              				                                             		
		[sendAlert show];
		[sendAlert release];		
	}else{		
		[sendButton setTitle:@"Sending ...." forState:UIControlStateDisabled];		
		[sendButton setEnabled:NO];		
		NSMutableString *str = [NSMutableString stringWithFormat:@"%f\n",CFAbsoluteTimeGetCurrent()];		
		//parse dictionary		 
		id mykey;
		NSEnumerator *enumerator = [list keyEnumerator];
		while ((mykey = [enumerator nextObject])) {
			[str appendString:[NSString stringWithFormat:@"%@ : %@\n", mykey, [list objectForKey:mykey]]];
		}	
		//send		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];	
		int ret = doSend(str,theAddress.text,thePort.text);
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];			
		//3way notification
		NSLog(@"Sent data to %@:%@",theAddress.text,thePort.text);
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); 
		UIAlertView *dataAlert;
		if (ret > 0){
			dataAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Data was sent successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil];                                              			
		}else{
			dataAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Data could not be sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil];                                              						
		}		
		[dataAlert show];
		[dataAlert release];	
		[sendButton setEnabled:YES];		
	}			
	
}      

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	//AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//MainViewController *controller = (MainViewController *)delegate.navigationController.topViewController;	
	//NSString *orientation = controller.orientation;
	//NSLog(@"got %@",orientation);
    [sendButton setEnabled:NO];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait); // Portrait mode only
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data	
}

- (void)dealloc {
	[super dealloc];
}

-(IBAction)siteButtonPressed{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vladalexa.com/apps/iphone/vainfo"]]; 		
} 

-(IBAction)doneButtonPressed{
	[self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
