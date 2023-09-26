//
//  FirstViewController.m
//  AirSay
//
//  Created by Vlad Alexa on 4/6/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import "FirstViewController.h"

#import "RemoteIOAU.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize remoteIOAU;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Microphone", @"Microphone");
        self.tabBarItem.image = [UIImage imageNamed:@"microphone"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    remoteIOAU = [[RemoteIOAU alloc] init];       
    
    [volume setShowsRouteButton:NO];
    [volume setShowsVolumeSlider:YES];
    
    [route setShowsRouteButton:YES];
    [route setShowsVolumeSlider:NO];
    
	[mute setImage:[self UIImageFromPDF:@"mute.pdf" size:CGSizeMake(48,48)] forState:UIControlStateNormal];   

	[speaker setImage:[self UIImageFromPDF:@"volume.pdf" size:CGSizeMake(24,24)]];    
    
    BOOL inputAvailable = [[AVAudioSession sharedInstance] inputIsAvailable];    
    if (!inputAvailable) {
        NSLog(@"No input available");
        [inNameLabel setText:@"No input available"];                    
        return;
    }else {
        [inNameLabel setText:[NSString stringWithFormat:@"%@ %5.fHz",[[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] localizedName],[[AVAudioSession sharedInstance] currentHardwareSampleRate]]];            
    }  
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelUpdate:) userInfo:nil repeats:YES];

    [centerView setFrame:CGRectMake((self.view.frame.size.width-centerView.frame.size.width)/2, (speaker.frame.origin.y-speaker.frame.size.height-centerView.frame.size.height)/2, centerView.frame.size.width, centerView.frame.size.height)];
    [self.view addSubview:centerView];//add view centered below speaker icon
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    //if (remoteIOAU.micRouted == YES) [remoteIOAU stopUnit];
}

- (void)viewWillAppear:(BOOL)animated
{
    //if (remoteIOAU.micRouted != YES) [remoteIOAU startUnit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (interfaceOrientation != UIInterfaceOrientationLandscapeLeft && interfaceOrientation != UIInterfaceOrientationLandscapeRight){
            return YES;
        }    
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }    
    return NO;
}

#pragma mark ui

-(void)levelUpdate:(NSTimer*)timer
{
    [inMeter setProgress:remoteIOAU.micLevel];
    //NSLog(@"%f",remoteIOAU.micLevel);
}

#pragma mark audio capture

-(IBAction)mute:(id)sender{
    if (remoteIOAU.micMuted == YES) {
        remoteIOAU.micMuted = NO;
        [mute setImage:[self UIImageFromPDF:@"mute.pdf" size:CGSizeMake(48,48)] forState:UIControlStateNormal]; 
        [mute setAlpha:0.2];
        [inMeter setProgressTintColor:[UIColor colorWithRed:0.23 green:0.57 blue:0.89 alpha:1.0]];
    }else {
        remoteIOAU.micMuted = YES;        
        [mute setImage:[self UIImageFromPDF:@"mute_red.pdf" size:CGSizeMake(48,48)] forState:UIControlStateNormal];         
        [mute setAlpha:0.4];        
        [inMeter setProgressTintColor:[UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0]];        
    }    
    [self animatePush:sender];    
}

#pragma mark audio controls

-(void)playPause
{
    if (remoteIOAU.micRouted == YES) {
        [remoteIOAU stopUnit];        
    }else {
        [remoteIOAU startUnit];
    }
}

#pragma mark tools

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


@end
