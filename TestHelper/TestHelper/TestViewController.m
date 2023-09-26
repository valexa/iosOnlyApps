//
//  TestViewController.m
//  TestHelper
//
//  Created by Vlad Alexa on 2/5/13.
//  Copyright (c) 2013 Vlad Alexa. All rights reserved.
//

#import "TestViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface TestViewController ()

@end

@implementation TestViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foreground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
	UIImage *imgGray = [[self UIImageFromPDF:@"button_gray.pdf" size:CGSizeMake(46,65)] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
	UIImage *imgOrange = [[self UIImageFromPDF:@"button_orange.pdf" size:CGSizeMake(46,65)] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
	UIImage *imgBlue = [[self UIImageFromPDF:@"button_blue.pdf" size:CGSizeMake(46,65)] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
	[correctButton setBackgroundImage:imgOrange forState:UIControlStateNormal];
	[notsureButton setBackgroundImage:imgGray forState:UIControlStateNormal];
	[endButton setBackgroundImage:imgBlue forState:UIControlStateNormal];
    
    defaults  = [NSUbiquitousKeyValueStore defaultStore];
}

- (void)viewWillAppear:(BOOL)animated
{
    startTime = CFAbsoluteTimeGetCurrent();
        
    int time = [[_testDict objectForKey:@"time"] intValue];
    int questions = [[_testDict objectForKey:@"questions"] intValue];
    int goal = [[_testDict objectForKey:@"goal"] intValue];
    
    [timeLeft setTag:time];
    [self performSelector:@selector(minuteTick:) withObject:nil afterDelay:60];
    
    [questionsLeft setTag:questions];
    [questionsLeft setText:[NSString stringWithFormat:@"%i questions left",questions]];
    [questionsSlack setTag:questions-goal];
    [questionsSlack setText:[NSString stringWithFormat:@"%i question slack",questions-goal]];
    [corectNeeded setText:[NSString stringWithFormat:@"You need %i correct answers to pass",goal]];
    [correctAssesed setText:@""];
    
    [timeLeft setText:[NSString stringWithFormat:@"%i min left",time]];
    [timeLeft setTag:time];
    [timePerQuestion setText:[NSString stringWithFormat:@"You need to answer %.1f questions/min",(float)questions/time]];
    [timeAtQuestionNeeded setText:@"You should be on the first question"];
    [timeAtQuestionAssesed setText:@""];
    [timeAdvantage setText:@""];
    
    [timeProgress setProgress:0];
    [scoreProgress setProgress:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //IOS 6+ to override iphone default UIInterfaceOrientationMaskAllButUpsideDown
    return UIInterfaceOrientationMaskAll;
}

- (void)foreground
{
    // get changes that might have happened while this instance of your app wasn't running
    [defaults synchronize];
    
    int timePassed = (CFAbsoluteTimeGetCurrent()-startTime)/60;
    int totalTime = [[_testDict objectForKey:@"time"] intValue];
    [timeLeft setTag:totalTime-timePassed];
}

#pragma mark test


-(void)minuteTick:(id)sender
{
    int left = [timeLeft tag]-1;
    
    if (left <= 0 ) {
        [self endTest:self];
        return;
    }
    
    [timeLeft setTag:left];
    
    int totalTime = [[_testDict objectForKey:@"time"] intValue];    
    int totalQuestions = [[_testDict objectForKey:@"questions"] intValue];
    float initialTimeperQ = totalQuestions/totalTime;
    float timePerQ = (float)[questionsLeft tag]/left;
    int pastQ = (totalTime-left) * initialTimeperQ;
    int advantage = ([timeAtQuestionAssesed tag] + 1 - pastQ) * initialTimeperQ;
    
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:1.0f];
    [timeLeft setText:[NSString stringWithFormat:@"%i min left",left]];
    [timePerQuestion setText:[NSString stringWithFormat:@"You need to answer %.1f questions/min",timePerQ]];
    [timeAtQuestionNeeded setText:[NSString stringWithFormat:@"You should be past the %ith question",pastQ]];
    if (advantage > 1) {
        [timeAdvantage setText:[NSString stringWithFormat:@"time advantage %i",advantage]];
        [timeAtQuestionAssesed setTextColor:[UIColor greenColor]];
    }else if (advantage < -2) {
        [timeAtQuestionAssesed setTextColor:[UIColor redColor]];
        [timeAdvantage setText:@""];
    }else{
        [timeAtQuestionAssesed setTextColor:[UIColor lightGrayColor]];
        [timeAdvantage setText:@""];
    }
    [UIView commitAnimations];
    
    [timeProgress setProgress:(float)(totalTime-left)/totalTime];
    
    [self performSelector:@selector(minuteTick:) withObject:nil afterDelay:60];
}


- (IBAction)correct:(id)sender
{
    int remain = [questionsLeft tag]-1;
    
    [questionsLeft setTag:remain];
    if (remain == 1) {
        [questionsLeft setText:@"Only this question left"];
    }else{
        [questionsLeft setText:[NSString stringWithFormat:@"%i questions left",remain]];
    }
    
    int goal = [[_testDict objectForKey:@"goal"] intValue];
    int correct = [correctAssesed tag]+1;
    [correctAssesed setTag:correct];
    [correctAssesed setText:[NSString stringWithFormat:@"You assessed %i correct answers",correct]];
    if (correct >= goal) {
        [correctAssesed setTextColor:[UIColor greenColor]];
    }
    
    int assessed = [timeAtQuestionAssesed tag]+1;
    [timeAtQuestionAssesed setTag:assessed];
    [scoreProgress setProgress:(float)assessed/(assessed+remain)];
    
    if (remain == 0) {
        [correctButton setHidden:YES];
        [notsureButton setHidden:YES];
    }else{
        [timeAtQuestionAssesed setText:[NSString stringWithFormat:@"You are on the %ith question",assessed+1]];
    }
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [self ASPlaySound:@"button"];
}

- (IBAction)notsure:(id)sender
{
    int remain = [questionsLeft tag]-1;
    
    [questionsLeft setTag:remain];
    if (remain == 1) {
        [questionsLeft setText:@"Only this question left"];
    }else{
        [questionsLeft setText:[NSString stringWithFormat:@"%i questions left",remain]];
    }
    
    int goal = [[_testDict objectForKey:@"goal"] intValue];
    if (goal - [correctAssesed tag] > remain) {
        [correctAssesed setTextColor:[UIColor redColor]];
    }
    
    int slack = [questionsSlack tag]-1;
    [questionsSlack setTag:slack];
    [questionsSlack setText:[NSString stringWithFormat:@"%i question slack",slack]];
    if (slack == 0) {
        [questionsSlack setTextColor:[UIColor orangeColor]];
    }else if (slack < 0) {
        [questionsSlack setText:@""];
    }
    
    int assessed = [timeAtQuestionAssesed tag]+1;
    [timeAtQuestionAssesed setTag:assessed];
    [scoreProgress setProgress:(float)assessed/(assessed+remain)];
    
    if (remain == 0) {
        [correctButton setHidden:YES];
        [notsureButton setHidden:YES];
    }else{
        [timeAtQuestionAssesed setText:[NSString stringWithFormat:@"You are on the %ith question",assessed+1]];
    }
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self ASPlaySound:@"button"];

}

- (IBAction)endTest:(id)sender
{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[defaults objectForKey:@"tests"]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [_testDict objectForKey:@"name"],@"testName",
                          [_testDict objectForKey:@"time"],@"timeLimit",
                          [NSDate dateWithTimeIntervalSinceReferenceDate:startTime],@"startTime",
                          [NSDate date],@"endTime",
                          [_testDict objectForKey:@"questions"],@"questions",
                          [_testDict objectForKey:@"goal"],@"goal",
                          [NSString stringWithFormat:@"%i",[correctAssesed tag]],@"assessed",
                          nil];
    [arr addObject:dict];
    [defaults setArray:arr forKey:@"tests"];
    
    [self performSegueWithIdentifier:@"endTest" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"endTest"])
    {
        UIViewController *controller = [segue destinationViewController];
        [controller setTitle:@"autoShowResult"];
    }
}

-(UIImage *)UIImageFromPDF:(NSString*)fileName size:(CGSize)size
{
	CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)fileName, NULL, NULL);
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

-(void)AVPlaySound:(NSString*)name
{
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"m4a"];
    
    if (!url) {
        NSLog(@"Error loading %@",name);
        return;
    }
    
    NSError *err;
    
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    
    if(err){
        NSLog(@"%@",err);
        return;
    }
    
    audioPlayer.numberOfLoops = 0;
    
    if (![audioPlayer play]) {
        NSLog(@"Error playing %@",name);
    }

}

-(void)ASPlaySound:(NSString*)name
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"m4a"];
    
    if (!url) {
        NSLog(@"Error loading %@",name);
        return;
    }
    
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &soundID);
    AudioServicesPlaySystemSound (soundID);
}


@end
