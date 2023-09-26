//
//  SpeakTimeController.m
//  SpeakTime
//
//  Created by Vlad Alexa on 9/11/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "SpeakTimeController.h"

#import "FliteTTS.h"
#import "EditController.h"
#import "LoadingView.h"
#import "ZonesController.h"

@implementation SpeakTimeController

@synthesize audioPlayer;


- (void)viewDidLoad{		
	
	defaults = [NSUserDefaults standardUserDefaults];
    
    spokenText = [[NSMutableString alloc] init];
	
	if ([defaults objectForKey:@"hourPrefix"] == nil) {
		[defaults setObject:@"It's" forKey:@"hourPrefix"];
	}
	
	if ([defaults objectForKey:@"minutePrefix"] == nil) {
		[defaults setObject:@"o clock," forKey:@"minutePrefix"];
	}	
	
	if ([defaults objectForKey:@"endingPrefix"] == nil) {
		[defaults setObject:@"minutes" forKey:@"endingPrefix"];
	}	
    
	if ([defaults objectForKey:@"voice"] == nil) {
		[defaults setObject:@"slt" forKey:@"voice"];
	}	
        	
    int mutesize = 24;
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad) mutesize = mutesize*2;    
	if ([defaults boolForKey:@"mute"] == NO) {
        [muteButton setImage:[self UIImageFromPDF:@"unmute.pdf" size:CGSizeMake(mutesize,mutesize)] forState:UIControlStateNormal];
	}else {
        [muteButton setImage:[self UIImageFromPDF:@"mute.pdf" size:CGSizeMake(mutesize,mutesize)] forState:UIControlStateNormal];        
    } 
    
    if ([defaults objectForKey:@"activetimezone"] == nil) [defaults setObject:@"1" forKey:@"activetimezone"];
    if ([defaults objectForKey:@"timezone2"] == nil) [defaults setObject:@"America/New_York" forKey:@"timezone2"];
    if ([defaults objectForKey:@"timezone3"] == nil) [defaults setObject:@"America/Los_Angeles" forKey:@"timezone3"];
    
    [defaults synchronize];
    
	//AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Woosh" ofType:@"aifc"]], &Woosh);      
    
    [[AVAudioSession sharedInstance] setDelegate:self];  
    
	UILongPressGestureRecognizer *recognizePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressRecognized:)];
    [recognizePress setMinimumPressDuration:0.5];
	[self.view addGestureRecognizer:recognizePress];
	[recognizePress release];	
	
	UISwipeGestureRecognizer *recognizeSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
	[self.view addGestureRecognizer:recognizeSwipe];
	[recognizeSwipe release];
	
	UISwipeGestureRecognizer *recognizeDoubleSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeTwoRecognized:)];
    [recognizeDoubleSwipe setNumberOfTouchesRequired:2];
	[self.view addGestureRecognizer:recognizeDoubleSwipe];
	[recognizeDoubleSwipe release];  
    
    [self syncUI];
}

- (void)beginInterruption
{
    //NSLog(@"intrerupted by another process");
}

- (void)dealloc {
	[spokenText release];    
    [super dealloc];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);	
	return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {                    
        [selectorKnob setHidden:NO];
        [selectorRail setHidden:NO];        
        [muteButton setHidden:NO];        
        [infoButton setHidden:NO];        
    }
    [self refreshSwipeAnimation]; //update text rendering with rotations
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {   
        [selectorKnob setHidden:YES];
        [selectorRail setHidden:YES];        
        [infoButton setHidden:YES];
        [muteButton setHidden:YES];
    }   
    [self closeinfo:nil];
    [popOver dismissPopoverAnimated:NO]; 
    [self popoverControllerDidDismissPopover:popOver];
}

- (BOOL)becomeFirstResponder
{    
    [self syncUI];
    return YES;
}

-(IBAction)info:(id)sender
{
    UIView *view = helpView;
    if (INTERFACE_IS_4INCH) view = helpView4inch;
    
    if (![self.view.subviews containsObject:view]) {     
        [self.view addSubview:view];
    }   
}

-(IBAction)closeinfo:(id)sender
{
    UIView *view = helpView;
    if (INTERFACE_IS_4INCH) view = helpView4inch;
    
    if ([self.view.subviews containsObject:view]) {
        [view removeFromSuperview];
    }    
}

-(void)syncUI
{    
	//[self tapAnimation];
	[self refreshSwipeAnimation];    
    
    [self setTimeZone:[NSTimeZone defaultTimeZone] forView:timezone1];
    [self setTimeZone:[NSTimeZone timeZoneWithName:[defaults objectForKey:@"timezone2"]] forView:timezone2];    
    [self setTimeZone:[NSTimeZone timeZoneWithName:[defaults objectForKey:@"timezone3"]] forView:timezone3];
    
    if ([[defaults objectForKey:@"activetimezone"] intValue] == 1) [selectorKnob setFrame:[selector1 frame]];            
    if ([[defaults objectForKey:@"activetimezone"] intValue] == 2) [selectorKnob setFrame:[selector2 frame]];        
    if ([[defaults objectForKey:@"activetimezone"] intValue] == 3) [selectorKnob setFrame:[selector3 frame]];     
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popOver release];
    popOver = nil;
    [self syncUI];
}

#pragma mark gestures

- (void)pressRecognized:(UITapGestureRecognizer *)gestureRecognizer 
{
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {	
		[self speakTime];
	}
}

- (void)swipeRecognized:(UISwipeGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded && gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {	
        
        int old = [[defaults objectForKey:@"activetimezone"] intValue];
        int new = 1;
        if (old == 1 || old == 2) new = old+1;
        [defaults setObject:[NSString stringWithFormat:@"%i",new] forKey:@"activetimezone"];
        [defaults synchronize];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
		if (new == 1) [selectorKnob setFrame:[selector1 frame]]; 
		if (new == 2) [selectorKnob setFrame:[selector2 frame]]; 
		if (new == 3) [selectorKnob setFrame:[selector3 frame]];         
        [UIView commitAnimations];	
        
        if (![theText.layer animationForKey:@"changeTextTransition"]) {
            CATransition *animation = [CATransition animation];
            animation.duration = 0.5;
            animation.type = kCATransitionPush;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [theText.layer addAnimation:animation forKey:@"changeTextTransition"];         
        }        
        
        [self syncUI]; 
        [self speakTime];    
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:theText.layer selector:@selector(removeAllAnimations) userInfo:nil repeats:NO];
	}    
}

- (void)swipeTwoRecognized:(UISwipeGestureRecognizer *)gestureRecognizer 
{
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded && gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {	
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad) return; //do not edit in landscape except ipad
        }          
        
        Class available = NSClassFromString(@"UIPopoverController");
        if (available && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            if (popOver != nil) return;            
            EditController *controller = [[EditController alloc] initWithNibName:@"EditView" bundle:nil];
            popOver = [[UIPopoverController alloc] initWithContentViewController:controller];
            popOver.delegate = self;
            controller.parentPopOver = popOver;
            [popOver setPopoverContentSize:CGSizeMake(460,560) animated:YES];		
            [controller release];	
            [popOver presentPopoverFromRect:swipeView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else {
            EditController *controller = [[EditController alloc] initWithNibName:@"EditView" bundle:nil];
            controller.speakTimeController = self;
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            controller.modalPresentationStyle = UIModalPresentationFormSheet;		
            [self presentModalViewController:controller animated:YES];
            [controller release];
        }                  
		
	}
}

//- (void)shakeRecognized:(UISwipeGestureRecognizer *)gestureRecognizer {
//	AudioServicesPlaySystemSound (Woosh);    
//    [self toggleMute:self];
//}

#pragma mark TTS

-(NSString*)getTimeString
{    
    NSString *ret = nil;
	NSTimeZone *zone = [SpeakTimeController getTimeZone];
	NSArray *theArr = [SpeakTimeController getHourAndMinutes:zone];	
	NSString *theHours = [theArr objectAtIndex:0];
	NSString *theMinutes = [theArr objectAtIndex:1];		
	NSString *theEnding = [theArr objectAtIndex:2];
	
	if([theMinutes isEqualToString:@"00"]){
		ret = [NSString stringWithFormat:@"%@ %@ %@ %@ !",[defaults objectForKey:@"hourPrefix"],theHours,[defaults objectForKey:@"minutePrefix"],theEnding];				
	}else if([theMinutes isEqualToString:@"01"] && [[defaults objectForKey:@"endingPrefix"] isEqualToString:@"minutes"]) {
		ret = [NSString stringWithFormat:@"%@ %@ %@ and one minute %@ !",[defaults objectForKey:@"hourPrefix"],theHours,[defaults objectForKey:@"minutePrefix"],theEnding];			
	}else {
		ret = [NSString stringWithFormat:@"%@ %@ %@ and %@ %@ %@ !",[defaults objectForKey:@"hourPrefix"],theHours,[defaults objectForKey:@"minutePrefix"],theMinutes,[defaults objectForKey:@"endingPrefix"],theEnding];
	}
    
    //update text
	theText.text = [NSString stringWithFormat:@"%@:%@ %@",theHours,theMinutes,theEnding];
    
    return ret;
}

+(NSTimeZone*)getTimeZone
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    if ([[defaults objectForKey:@"activetimezone"] intValue] == 1) return [NSTimeZone defaultTimeZone];            
    if ([[defaults objectForKey:@"activetimezone"] intValue] == 2) return [NSTimeZone timeZoneWithName:[defaults objectForKey:@"timezone2"]];        
    if ([[defaults objectForKey:@"activetimezone"] intValue] == 3) return [NSTimeZone timeZoneWithName:[defaults objectForKey:@"timezone3"]]; 
    return  nil;
}

+(NSArray*)getHourAndMinutes:(NSTimeZone*)zone
{        
	NSString *theHours = @"";
	NSString *theMinutes = @"";
	NSString *theEnding = @"";	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"h:mm:a"];	
    [formatter setTimeZone:zone];
	NSString *theTime = [formatter stringFromDate:[NSDate date]];	
	[formatter release];	
	NSArray *theArr = [theTime componentsSeparatedByString:@":"];
	if ([theArr count] == 3) {
		theHours = [SpeakTimeController check24hour:[theArr objectAtIndex:0]];
		theMinutes = [theArr objectAtIndex:1];
		theEnding = [theArr objectAtIndex:2];        
	}else {
		NSLog(@"Error getting time");
	}
    
    if (zone == [NSTimeZone defaultTimeZone]){
        NSString *theEnding_ = [SpeakTimeController getLocalCTime:@"%p"];
        if ([theEnding length] < 1) {
            theEnding = theEnding_; //fill in if missing AM/PM
        }          
        if (![theEnding isEqualToString:theEnding_]){
            NSLog(@"%@ is wrong",theEnding_); //just check there is no weird stuff going on
        }          
    } else {
        if ([theEnding length] < 1) {
            NSString *theEnding_ = [SpeakTimeController getAMPMForTimezone:zone];            
            theEnding = theEnding_; //fill in if missing AM/PM
        }          
    }   
	return [NSArray arrayWithObjects:theHours,theMinutes,theEnding,nil];
}

+(NSString*)check24hour:(NSString*)string
{
	int value = [string intValue];
	if (value > 12) {
		return [NSString stringWithFormat:@"%i",value-12];
	}
	return string;
}

+(NSString*)getLocalCTime:(NSString*)stringFormat
{
	const char *format = [stringFormat UTF8String];	
	time_t currentTime = time(NULL);
	struct tm timeStruct;
	localtime_r(&currentTime, &timeStruct);
	char buffer[50];
	strftime(buffer, sizeof(buffer), format, &timeStruct);
	return [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
}

+(NSString*)getGMTCTime:(NSString*)stringFormat
{
	const char *format = [stringFormat UTF8String];	
	time_t currentTime = time(NULL);
	struct tm timeStruct;
	gmtime_r(&currentTime, &timeStruct);
	char buffer[50];
	strftime(buffer, sizeof(buffer), format, &timeStruct);
	return [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
}

+(NSString*)getAMPMForTimezone:(NSTimeZone*)zone
{
    NSString *gmt = [SpeakTimeController getGMTCTime:@"%H"];
    int diff = (int)[zone secondsFromGMT]/3600; 
    int hour = [gmt intValue]+diff;
    if (hour > 12) {
        return @"PM";
    }else {
        return @"AM";        
    }
}

-(void)speakTime
{    
	if ([defaults boolForKey:@"mute"] == YES) return;     
    if ([audioPlayer isPlaying]) return;
    NSString *text = [self getTimeString];   
    if ([text isEqualToString:spokenText]) {
        [self playFile:nil];  
        return;
    }    
    NSString *file = [NSString stringWithFormat:@"%@/time.wav",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];	
	//change AM and PM into A M and P M for clarity	
    if ([text length] > 3) text = [text stringByReplacingCharactersInRange:NSMakeRange([text length]-3,3) withString:@" M "];    
    //append timezone if different than current
	NSTimeZone *zone = [SpeakTimeController getTimeZone];    
    NSString *name = [SpeakTimeController nameFromTimeZone:zone];    
    if (zone != [NSTimeZone defaultTimeZone]) text = [text stringByAppendingFormat:@"in %@ !",name];      
    
    LoadingView *loadingView = nil;
    if (![[defaults objectForKey:@"voice"] isEqualToString:@"kal"] && ![[defaults objectForKey:@"voice"] isEqualToString:@"kal16"]) {
        loadingView = [LoadingView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];        //show overlay                 
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{           
        //save it		
        [FliteTTS speakText:text toFile:file voice:[defaults objectForKey:@"voice"]];
        [spokenText setString:text];        
        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
            if (loadingView != nil) [loadingView performSelectorOnMainThread:@selector(removeView) withObject:nil waitUntilDone:YES];             
            [self performSelectorOnMainThread:@selector(playFile:) withObject:nil waitUntilDone:NO];                  
        }else {
            NSLog(@"Failed to speak %@",text);
        }   
    });     

}

-(void)playFile:(id)sender
{
	if (![NSThread isMainThread]){
		NSLog(@"playFile called outside main thread: %@", [NSThread currentThread]);
		return;		
	}	    
    
    NSString *file = [NSString stringWithFormat:@"%@/time.wav",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];   
    
    NSError *error;	
    self.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:file] error:&error] autorelease];
    audioPlayer.numberOfLoops = 0;	
    if (!error) {
        [audioPlayer play];		
    }else {
        NSLog(@"Error playing %@",file);
    }
}

#pragma mark animations

/*
-(void)tapAnimation{
	UIImage *textImage = [self UIImageFromPDF:@"tap.pdf" size:CGSizeMake(32,32)];
	CGFloat textWidth = textImage.size.width;
	CGFloat textHeight = textImage.size.height;
	
	CALayer *textLayer = [CALayer layer];
	textLayer.contents = (id)[textImage CGImage];
	textLayer.frame = CGRectMake(0.0f, 0.0f, textWidth, textHeight);
	
	CALayer *maskLayer = [CALayer layer];
	
	// Mask image ends with 0.15 opacity on both sides. Set the background color of the layer
	// to the same value so the layer can extend the mask image.
	maskLayer.backgroundColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.15f] CGColor];
	maskLayer.contents = (id)[[UIImage imageNamed:@"tap_mask.png"] CGImage];
	
	// Center the mask image on twice the width of the text layer, so it starts to the left
	// of the text layer and moves to its right when we translate it by width.
	maskLayer.contentsGravity = kCAGravityCenter;
	maskLayer.frame = CGRectMake(0.0f, 0.0f, textWidth, textHeight);
	
	//Create an animation with pulsating effect
	CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	theAnimation.duration = 3.0f;	
	theAnimation.repeatCount = FLT_MAX;
	theAnimation.autoreverses = YES;	
	theAnimation.fromValue = [NSNumber numberWithFloat:0.0f]; 
	theAnimation.toValue = [NSNumber numberWithFloat:0.8f];
	[maskLayer addAnimation:theAnimation forKey:@"pulseAnim"];
	
	textLayer.mask = maskLayer;
	[tapView.layer addSublayer:textLayer];	
}


-(void)refreshTapAnimation
{
    NSMutableArray *layers = [NSMutableArray arrayWithCapacity:1];    
	for (CALayer *layer in [tapView.layer sublayers]) {
        [layers addObject:layer];
	}
    for (CALayer *layer in layers) {
		[layer removeFromSuperlayer];
    }
	[self tapAnimation];	
}
*/ 

-(void)swipeAnimation
{
    NSString *text = [self getTimeString];    
	NSString *string = [text substringWithRange:NSMakeRange(0,[text length]-1)];
	UIImage *textImage = [self imageFromText:string];	
	CGFloat textWidth = textImage.size.width;
	CGFloat textHeight = textImage.size.height;
	
	CALayer *textLayer = [CALayer layer];
	textLayer.contents = (id)[textImage CGImage];
	textLayer.frame = CGRectMake(0.0f, 0.0f, textWidth, textHeight);
	
	CALayer *maskLayer = [CALayer layer];
	
	// Mask image ends with 0.15 opacity on both sides. Set the background color of the layer
	// to the same value so the layer can extend the mask image.
	maskLayer.backgroundColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.15f] CGColor];
	maskLayer.contents = (id)[[UIImage imageNamed:@"mask.png"] CGImage];
	
	// Center the mask image on twice the width of the text layer, so it starts to the left
	// of the text layer and moves to its right when we translate it by width.
	maskLayer.contentsGravity = kCAGravityCenter;
	maskLayer.frame = CGRectMake(-textWidth, 0.0f, textWidth * 2, textHeight);
	
	// Animate the mask layer's horizontal position
	CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
	maskAnim.byValue = [NSNumber numberWithFloat:textWidth];
	maskAnim.repeatCount = FLT_MAX;
	maskAnim.duration = 3.0f;
	maskAnim.fillMode = kCAFillModeForwards;
	[maskLayer addAnimation:maskAnim forKey:@"slideAnim"];
	
	textLayer.mask = maskLayer;
	[swipeView.layer addSublayer:textLayer];	
	swipeView.frame = CGRectMake((self.view.bounds.size.width/2)-(textWidth/2)+4,swipeView.frame.origin.y, textWidth+4, textHeight+4);
}

-(void)refreshSwipeAnimation
{
    NSMutableArray *layers = [NSMutableArray arrayWithCapacity:1];
	for (CALayer *layer in [swipeView.layer sublayers]) {
        [layers addObject:layer];
	}
    for (CALayer *layer in layers) {
		[layer removeFromSuperlayer];
    }
	[self swipeAnimation];	
}

-(UIImage *)imageFromText:(NSString *)text
{
    float fontsize = 20.0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad) fontsize = fontsize*1.4;     
    UIFont *font = [UIFont systemFontOfSize:fontsize];  
    CGSize size  = [text sizeWithFont:font];
	
	UIGraphicsBeginImageContextWithOptions(size,NO,0.0);						
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColor(ctx, CGColorGetComponents([UIColor whiteColor].CGColor));

    [text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();   
	
    UIGraphicsEndImageContext();    
    return image;
}

#pragma mark tools

-(UIImage *)UIImageFromPDF:(NSString*)fileName size:(CGSize)size
{
	CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), ( CFStringRef)fileName, NULL, NULL);	
	if (pdfURL) {		
		CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(pdfURL);
		CFRelease(pdfURL);	
		//create context with scaling 0.0 as to get the main screen's
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);						
		CGContextRef context = UIGraphicsGetCurrentContext();		
		//translate the content
		CGContextTranslateCTM(context, 0.0, size.height);	
		CGContextScaleCTM(context, 1.0, -1.0);		
		CGContextSaveGState(context);	
		//scale to our desired size
		CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
		CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, CGRectMake(0, 0, size.width, size.height), 0, true);
		CGContextConcatCTM(context, pdfTransform);
		CGContextDrawPDFPage(context, page);	
		CGContextRestoreGState(context);
		//return autoreleased UIImage
		UIImage *ret = UIGraphicsGetImageFromCurrentImageContext(); 	
		UIGraphicsEndImageContext();
		CGPDFDocumentRelease(pdf);		
		return ret;		
	}else {
		NSLog(@"Could not load %@",fileName);
	}
	return nil;	
}

-(void)animatePush:(id)target
{    	
	///Scale the X and Y dimmensions by a factor of 0.8
	CATransform3D tt = CATransform3DMakeScale(0.8,0.8,1);	
    
	CABasicAnimation *animation = [CABasicAnimation animation];
	animation.fromValue = [NSValue valueWithCATransform3D: CATransform3DIdentity];
	animation.toValue = [NSValue valueWithCATransform3D: tt];
	animation.duration = 0.2;
	animation.removedOnCompletion = YES;
	animation.fillMode = kCAFillModeBoth;
	[target addAnimation:animation forKey:@"transform"];
	
}

#pragma mark mute
- (IBAction)toggleMute:(id)sender
{
    int mutesize = 24;
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad) mutesize = mutesize*2;      
	if ([defaults boolForKey:@"mute"] == NO) {
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"mute"];
        [muteButton setImage:[self UIImageFromPDF:@"mute.pdf" size:CGSizeMake(mutesize,mutesize)] forState:UIControlStateNormal];        
    }else {
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"mute"];        
        [muteButton setImage:[self UIImageFromPDF:@"unmute.pdf" size:CGSizeMake(mutesize,mutesize)] forState:UIControlStateNormal];        
    }    
    //[self animatePush:sender];    
    [defaults synchronize];
}


#pragma mark timezones

+(NSString*)nameFromTimeZone:(NSTimeZone*)zone
{
    NSString *ret = [[[[zone name] componentsSeparatedByString:@"/"] lastObject] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    if (!ret) ret = [zone name];    
    return ret;
}

-(void)setTimeZone:(NSTimeZone*)zone forView:(UIView*)view
{
    if ([[view subviews] count] != 3){
        NSLog(@"setTimeZone error at %@",view);
        return;
    }  
    UILabel *title = [[view subviews] objectAtIndex:0];
    UILabel *hour = [[view subviews] objectAtIndex:1];
    UILabel *ampm = [[view subviews] objectAtIndex:2];     
    if (!zone){
        NSLog(@"setTimeZone missing timezone");
        [title setText:@""];    
        [hour setText:@""];    
        [ampm setText:@""];        
        return;
    }    
    
	NSArray *theArr = [SpeakTimeController getHourAndMinutes:zone];	
	NSString *theHours = [theArr objectAtIndex:0];
	NSString *theMinutes = [theArr objectAtIndex:1];		
	NSString *theEnding = [theArr objectAtIndex:2];	     
    NSString *name = [SpeakTimeController nameFromTimeZone:zone];
    [title setText:name];    
    [hour setText:[NSString stringWithFormat:@"%@:%@",theHours,theMinutes]];    
    [ampm setText:theEnding];        
}

- (IBAction)editZone:(id)sender
{    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad) return; //do not edit in landscape except ipad
    }   
    
    if (sender == timezone1){
        UIAlertView *dataAlert = [[UIAlertView alloc] initWithTitle:@"Chose another timezone to edit" message:@"The local timezone can not be changed, it changes automatically based on your system settings." delegate:self  cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];                                              
        [dataAlert show];			
        [dataAlert release];            
        return;
    }    

    NSString *zoneName;
    if (sender == timezone2) zoneName = @"timezone2";
    if (sender == timezone3) zoneName = @"timezone3";    
    
	Class available = NSClassFromString(@"UIPopoverController");
	if (available && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (popOver != nil) return;
		ZonesController *controller = [[ZonesController alloc] initWithNibName:@"ZonesController" bundle:nil];
        controller.zoneName = zoneName;       
		popOver = [[UIPopoverController alloc] initWithContentViewController:controller];
        popOver.delegate = self;
        controller.parentPopOver = popOver;         
		[popOver setPopoverContentSize:CGSizeMake(460,560) animated:YES];		
		[controller release];	
        UIView *view = (UIView*)sender;          
		CGRect rect = CGRectMake(-2,18,view.frame.size.width,view.frame.size.height);
		[popOver presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];			
	}else {
        ZonesController *controller = [[ZonesController alloc] initWithNibName:@"ZonesController" bundle:nil];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.zoneName = zoneName;
        [self presentModalViewController:controller animated:YES];
        [controller release];
	}    
	
}

@end
