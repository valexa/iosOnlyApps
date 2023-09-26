//
//  SecondViewController.m
//  AirSay
//
//  Created by Vlad Alexa on 4/6/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import "SecondViewController.h"

#import "LoadingView.h"
#import "FliteTTS.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"TextToSpeech", @"TextToSpeech");
        self.tabBarItem.image = [UIImage imageNamed:@"keyboard"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *text = [[NSUserDefaults standardUserDefaults] objectForKey:@"text"];
    if (text) [txt setText:text];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setInBackgroundFlag) name:UIApplicationWillResignActiveNotification object:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearInBackgroundFlag) name:UIApplicationWillEnterForegroundNotification object:nil];    
    
    [volume setShowsRouteButton:NO];
    [volume setShowsVolumeSlider:YES];
    
    [route setShowsRouteButton:YES];
    [route setShowsVolumeSlider:NO];  
    
    [speaker setImage:[self UIImageFromPDF:@"volume.pdf" size:CGSizeMake(24,24)]];        
    
    [self radio:NO];
    [self typewriter:YES];
    
    [centerView setFrame:CGRectMake((self.view.frame.size.width-centerView.frame.size.width)/2, (speaker.frame.origin.y-speaker.frame.size.height-centerView.frame.size.height)/2, centerView.frame.size.width, centerView.frame.size.height)];
    [self.view addSubview:centerView];//add view centered below speaker icon
        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    [txt resignFirstResponder];		
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]){
        [[NSUserDefaults standardUserDefaults] setObject:txt.text forKey:@"text"];
        [textView resignFirstResponder];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(speakText) userInfo:nil repeats:NO];
        return NO;
    }else{
        NSString *file = [NSString stringWithFormat:@"%@/tts.wav",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];        
        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:file error:&error];
            if (error) NSLog(@"Could not remove %@",file);
        }      
        return YES;
    }
}

-(void)speakText
{
    NSString *str = txt.text;
    NSString *file = [NSString stringWithFormat:@"%@/tts.wav",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        //we already have a render of the text to file
        [self playFile:self];
        return;
    }  
    
    LoadingView *loadingView = [LoadingView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];        //show overlay         
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{           
        [FliteTTS speakText:str toFile:file voice:[[NSUserDefaults standardUserDefaults] objectForKey:@"voice"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
            [loadingView performSelectorOnMainThread:@selector(removeView) withObject:nil waitUntilDone:YES];             
            [self performSelectorOnMainThread:@selector(playFile:) withObject:nil waitUntilDone:NO];                  
        }else {
            NSLog(@"Failed to speak %@",str);
        }   
    });     
}

-(IBAction)startTyping:(id)sender
{
    [txt becomeFirstResponder];
}

#pragma mark player

-(IBAction)closeRadio:(id)sender
{
    [self radio:NO];
    [self typewriter:YES];
	if (updateTimer) [updateTimer invalidate]; 
    updateTimer = nil;    
}

-(void)playFile:(id)sender
{
	if (![NSThread isMainThread]){
		NSLog(@"playFile called outside main thread: %@", [NSThread currentThread]);
		return;		
	}	    
    
    NSString *file = [NSString stringWithFormat:@"%@/tts.wav",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];    
    
    NSError *error;	
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:file] error:&error];
    if (!error) {
        audioPlayer.numberOfLoops = 0;	
        audioPlayer.meteringEnabled = YES;
        audioPlayer.delegate = self;            
        [audioPlayer play];	         
        //NSLog(@"Playing %@", [NSString stringWithFormat: @"%@ (%d ch.)", file, audioPlayer.numberOfChannels]);
        previousTime = audioPlayer.currentTime;
        duration.text = [NSString stringWithFormat:@"%d:%02d", (int)audioPlayer.duration / 60, (int)audioPlayer.duration % 60, nil];
        progressBar.maximumValue = audioPlayer.duration; 
        [self radio:YES];
        [self typewriter:NO];         
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateCurrentTimeForPlayerTimer:) userInfo:audioPlayer repeats:NO];              
    }else {
        NSLog(@"Error playing %@: %@",file,error);
    }
}

-(void)updateCurrentTimeForPlayerTimer:(NSTimer*)timer
{
    AVAudioPlayer *p = [timer userInfo];
    [self updateCurrentTimeForPlayer:p];
}

-(void)updateCurrentTimeForPlayer:(AVAudioPlayer*)p
{
    //prevent bug if audioPlayerDidFinishPlayin does not fire
    if (previousTime-p.currentTime > 0.1 && p.currentTime > 0) {
        NSLog(@"Whoa there, going back in time are we %f %f",p.currentTime, previousTime);  
        [self closeRadio:self];
        return;
    }else {
        previousTime = p.currentTime;        
    }
    
    currentTime.text = [NSString stringWithFormat:@"%d:%02d", (int)p.currentTime / 60, (int)p.currentTime % 60, nil];
    progressBar.value = p.currentTime; 
    if (p.currentTime > 0) {
        [p updateMeters];
        meter.progress = ([p averagePowerForChannel:0]+25.0)/25.0;
    }else {
        meter.progress = 0.0;         
    }
    
	if (updateTimer) [updateTimer invalidate];    
	if (p.playing){
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateCurrentTimeForPlayerTimer:) userInfo:p repeats:NO];
	}else{
		updateTimer = nil;
	}
}


#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{  
	if (flag == NO)	NSLog(@"Playback finished unsuccessfully");    
	[p setCurrentTime:0.];
    [self updateCurrentTimeForPlayer:p];    
    [self radio:NO];
    [self typewriter:YES];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@", error); 
}

// we will only get these notifications if playback was interrupted
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption begin. Updating UI for new state");
    [self updateCurrentTimeForPlayer:p];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption ended. Resuming playback");
	[p pause];
    [self updateCurrentTimeForPlayer:p];
}

#pragma mark background notifications

- (void)setInBackgroundFlag
{
	inBackground = YES; //not used
}

- (void)clearInBackgroundFlag
{
	inBackground = NO; //not used
}


#pragma mark helpers

-(void)radio:(BOOL)show
{
    BOOL hide = NO;
    if (show == YES) hide = NO;
    if (show == NO) hide = YES;
    
    [radio setHidden:hide];    
	[progressBar setHidden:hide];
	[currentTime setHidden:hide];
	[duration setHidden:hide];
	[meter setHidden:hide];
    [closeRadio setHidden:hide];
}

-(void)typewriter:(BOOL)show
{
    BOOL hide = NO;
    if (show == YES) hide = NO;
    if (show == NO) hide = YES;
    
    [typewriter setHidden:hide];    
	[txt setHidden:hide];
    [startTyping setHidden:hide];
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

@end
