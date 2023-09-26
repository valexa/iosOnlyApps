//
//  ZonesController.m
//  SpeakTime
//
//  Created by Vlad Alexa on 4/24/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import "ZonesController.h"

#import "DashedView.h"

#import "SpeakTimeController.h"

@interface ZonesController ()

@end

@implementation ZonesController

@synthesize zone,zoneName,parentPopOver;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        defaults = [NSUserDefaults standardUserDefaults];	
        timezonesDB = [[NSMutableDictionary alloc] initWithCapacity:1];  
        timezoneAlternatives = [[NSMutableArray alloc] initWithCapacity:1];  
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.zone = [NSTimeZone timeZoneWithName:[defaults objectForKey:zoneName]];    
    
    NSString *gmt = [self humanizeGMT];   
    [gmtLabel setText:gmt]; 
    
    [dashedView setTag:[gmt intValue]];
    
    NSString *name = [[[zone name] stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByReplacingOccurrencesOfString:@"/" withString:@", "];  
    [nameLabel setText:name];    
    [abrevLabel setText:[zone abbreviation]];    

    [self createTimezoneAssocDB];   
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [dashedView becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [dashedView resignFirstResponder];
    [super viewWillDisappear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad) return (interfaceOrientation == UIInterfaceOrientationPortrait);    
    return YES;
}

- (void)dealloc
{
    [timezonesDB release];
    [timezoneAlternatives release];
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{ 
    //update ui with new gmt from tag
    
    [timezoneAlternatives removeAllObjects];
    for (NSString *key in timezonesDB) {
        NSDictionary *dict = [timezonesDB objectForKey:key];
        int g = [[dict objectForKey:@"gmt"] intValue];
        if (g == dashedView.tag) {  
            self.zone = [NSTimeZone timeZoneWithName:key];
            [timezoneAlternatives addObject:key];
            //NSLog(@"%@ %@",key,[zone abbreviation]);
        }
    }
    NSString *gmt = [self humanizeGMT];
    [gmtLabel setText:gmt];     
    
    NSString *name = [[[zone name] stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByReplacingOccurrencesOfString:@"/" withString:@", "];  
    [nameLabel setText:name];       
    [abrevLabel setText:[zone abbreviation]];    
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

-(NSString*)humanizeGMT
{
    int hoursFromGMT = [zone secondsFromGMT]/3600;
    if ([zone isDaylightSavingTime]) hoursFromGMT = hoursFromGMT-1; //remove a hour if observing DST

    NSString *sign;
    if (hoursFromGMT < 0) {
        hoursFromGMT = hoursFromGMT*-1;
        sign = @"-";
    }else {
        sign = @"+";         
    }
    
    if (hoursFromGMT != 0) {
        return [NSString stringWithFormat:@"%@%i",sign,hoursFromGMT];           
    }
    
    return @"0";
}

-(void)createTimezoneAssocDB
{    
    for (NSString *name in [NSTimeZone knownTimeZoneNames]) {
        NSTimeZone *z = [NSTimeZone timeZoneWithName:name];       
        int hoursFromGMT = [z secondsFromGMT]/3600;
        if ([z isDaylightSavingTime]) hoursFromGMT = hoursFromGMT-1; //remove a hour if observing DST
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[z abbreviation],@"abr",[NSNumber numberWithInt:hoursFromGMT],@"gmt", nil];
        [timezonesDB setValue:d forKey:name];
    }    
}

-(IBAction)done:(id)sender
{
    if ([timezoneAlternatives count] < 1) {
        [defaults setObject:[zone name] forKey:zoneName];
        [defaults synchronize];
        [self dismissSelf:self];     
    }else {
        NSArray *sorted = [timezoneAlternatives sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        [timezoneAlternatives setArray:sorted];
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Chose a place from this timezone." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [sheet addButtonWithTitle:@"OK"];
        [sheet addButtonWithTitle:@"Cancel"];        
        
        int width = self.view.frame.size.width;
        int pickerHeight = 216;
        int offset = 165;
        if ([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad) offset = offset-10;
        
        CGRect pickerFrame = CGRectMake(0, offset, width, pickerHeight);
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        [sheet addSubview:pickerView];
        [pickerView release];                

        [sheet showFromRect:doneButton.frame inView:self.view animated:YES];        
        [sheet setBounds:CGRectMake(0, 0, width, pickerHeight+380)];
        [sheet release];         
    }   
   
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [defaults setObject:[zone name] forKey:zoneName];
        [defaults synchronize];
        [self dismissSelf:self];           
    }
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [timezoneAlternatives count];
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *name = [timezoneAlternatives objectAtIndex:row];    
    return [[name stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByReplacingOccurrencesOfString:@"/" withString:@", "];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.zone = [NSTimeZone timeZoneWithName:[timezoneAlternatives objectAtIndex:row]];
    NSString *name = [[[zone name] stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByReplacingOccurrencesOfString:@"/" withString:@", "];  
    [nameLabel setText:name];    
    [abrevLabel setText:[zone abbreviation]];      
}

@end
