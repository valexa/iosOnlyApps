//
//  MainViewController.m
//  TestHelper
//
//  Created by Vlad Alexa on 1/30/13.
//  Copyright (c) 2013 Vlad Alexa. All rights reserved.
//

#import "MainViewController.h"

#import <QuartzCore/CoreAnimation.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (storeDidChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
    
    defaults = [NSUbiquitousKeyValueStore defaultStore];
    
    if ([defaults objectForKey:@"tests"]) {
        [listButton setImage:[self UIImageFromPDF:@"list.pdf" size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
    }
    
    //automate opening test just completed
    if ([self.title isEqualToString:@"autoShowResult"])
    {
        [self performSelector:@selector(togglePopover:) withObject:self afterDelay:1];
    }    
    
}


-(void)storeDidChange:(NSNotification* )notif
{
    NSMutableArray *duplicates = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *tests = [NSMutableArray arrayWithArray:[defaults objectForKey:@"tests"]];
    for (NSDictionary* test in tests)
    {
        NSDate *date = [test objectForKey:@"startTime"];
        BOOL removeRest = NO;
        for (NSDictionary* test1 in tests)
        {
            if ([date isEqualToDate:[test1 objectForKey:@"startTime"]] )
            {
                if (removeRest == NO) {
                    removeRest = YES;
                }else{
                    [duplicates addObject:test1];                    
                }
            }
        }
    }
    
    if ([duplicates count] > 0) {
        [tests removeObjectsInArray:duplicates];
        [defaults setObject:tests forKey:@"tests"];
        NSLog(@"Duplicate test removed");        
        return;
    }

    [self animateBlink:listButton];
    NSLog(@"New test added");
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

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
        
        FlipsideViewController *destination = nil;
        if ([[segue destinationViewController] isKindOfClass:[FlipsideViewController class]])
        {
            destination = [segue destinationViewController];            
        }
        else
        {
            //need to forward the delegate down the chain if the destination is a relationship segued nav controler
            if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *nav = [segue destinationViewController];
                if ([nav.topViewController isKindOfClass:[FlipsideViewController class]])
                {
                    destination = (FlipsideViewController*)nav.topViewController;
                }
            }
        }
        if (destination) {
            [destination setDelegate:self];            
            if ([self.title isEqualToString:@"autoShowResult"])
            {
                [destination setTitle:@"autoShowResult"];
                [self setTitle:nil];
            }
        }else{
            NSLog(@"ERROR unable to delegate");
        }
        
    }
    
    if ([[segue identifier] isEqualToString:@"startTest"]) {
        if ([sender isKindOfClass:[NSDictionary class]]) {
            [[segue destinationViewController] setValue:sender forKey:@"testDict"];
        }
    }
    
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];      
    }
}


- (IBAction)startTest:(id)sender
{

    int time = [[testTime text] intValue];
    int questions = [[testQuestions text] intValue];
    int goal = [[testGoal text] intValue];

    if ([[testName text] length] < 1) {
        [self shakeView:testName];
        return;
    }
    
    if (time < 1) {
        [self shakeView:testTime];
        return;
    }
    
    if (questions < 1) {
        [self shakeView:testQuestions];
        return;
    }
    
    if (goal < 1 || goal > questions) {
        [self shakeView:testGoal];
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[testName text],@"name",[testTime text],@"time",[testQuestions text],@"questions",[testGoal text],@"goal", nil];
        
    [self performSegueWithIdentifier:@"startTest" sender:dict];
    
}

-(IBAction)info:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vladalexa.com/apps/ios/testhelper/"]];
}

-(void)animateBlink:(id)target
{	
	///Scale the X and Y dimmensions by a factor of 2
	CATransform3D tt = CATransform3DMakeScale(2,2,1);
    
	CABasicAnimation *animation = [CABasicAnimation animation];
	animation.fromValue = [NSValue valueWithCATransform3D: CATransform3DIdentity];
	animation.toValue = [NSValue valueWithCATransform3D: tt];
	animation.duration = 0.2;
	animation.removedOnCompletion = YES;
    animation.autoreverses = YES;
	animation.fillMode = kCAFillModeBoth;
	[target addAnimation:animation forKey:@"transform"];	
}


-(void)shakeView:(UIView*)theView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.1];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([theView center].x - 5.0f, [theView center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:CGPointMake([theView center].x + 5.0f, [theView center].y)]];
    [[theView layer] addAnimation:animation forKey:@"position"];
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if ([theTextField isFirstResponder]) {
        //take focus away from the text field so that the keyboard is dismissed.
        [theTextField resignFirstResponder];
    }
    
    [self startTest:self];
	
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    if ([testName isFirstResponder]) [testName resignFirstResponder];
    if ([testTime isFirstResponder]) [testTime resignFirstResponder];
    if ([testQuestions isFirstResponder]) [testQuestions resignFirstResponder];
    if ([testGoal isFirstResponder]) [testGoal resignFirstResponder];
    
    [super touchesBegan:touches withEvent:event];    
    
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

@end
