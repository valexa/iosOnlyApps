//
//  FlipsideViewController.m
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
        
        defaults = [NSUserDefaults standardUserDefaults];
        
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    navBar.topItem.title = [self.account objectForKey:@"domain"];

    if ([[self.account objectForKey:@"type"] isEqualToString:@"cpanel"])
    {
        [metricControl setTitle:@"Bandwidth" forSegmentAtIndex:0];
        [metricControl setTitle:@"Database" forSegmentAtIndex:1];
        [metricControl setTitle:@"Storage" forSegmentAtIndex:2];
    }
    
    if ([[self.account objectForKey:@"type"] isEqualToString:@"phpsysinfo"])
    {
        [metricControl setTitle:@"CPU" forSegmentAtIndex:0];
        [metricControl setTitle:@"Memory" forSegmentAtIndex:1];
        [metricControl setTitle:@"Storage" forSegmentAtIndex:2];
    }
    
    NSString *metric = [self.account objectForKey:@"metric"];
    
    if (metric) {
        [metricControl setSelectedSegmentIndex:[self indexForSegmentWithTitle:metric control:metricControl]];
    }
    
    NSString *graph = [self.account objectForKey:@"graph"];
    
    if (graph) {
        [graphControl setSelectedSegmentIndex:[self indexForSegmentWithTitle:graph control:graphControl]];
    }
    
}

-(int)indexForSegmentWithTitle:(NSString*)title control:(UISegmentedControl*)control
{
    for (int i = 0; i < [control numberOfSegments]; i++) {
        if ([[control titleForSegmentAtIndex:i] isEqualToString:title]) {
            return i;
        }
    }
    NSLog(@"No segment with title %@",title);
    return 0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (INTERFACE_IS_PHONE) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    } else {
        return YES;
    }
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    if (refresh == YES)
    {  
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IndexObserver" object:@"Refresh" userInfo:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


-(IBAction)metricChanged:(id)sender
{
    NSMutableDictionary *acc = [NSMutableDictionary dictionaryWithDictionary:self.account];
    [acc setObject:[metricControl titleForSegmentAtIndex:[metricControl selectedSegmentIndex]] forKey:@"metric"];
    
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:[defaults objectForKey:@"accounts"]];
    NSUInteger index = [accounts indexOfObject:self.account];
    if (index != NSNotFound) {
        [accounts removeObjectAtIndex:index];
        [accounts insertObject:acc atIndex:index];
        [defaults setObject:accounts forKey:@"accounts"];
        [defaults synchronize];
        self.account = acc;
        refresh = YES;
    }else{
        NSLog(@"Can't find account %@",self.account);
    }    
}

-(IBAction)graphChanged:(id)sender
{    
    NSMutableDictionary *acc = [NSMutableDictionary dictionaryWithDictionary:self.account];
    [acc setObject:[graphControl titleForSegmentAtIndex:[graphControl selectedSegmentIndex]] forKey:@"graph"];
    
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:[defaults objectForKey:@"accounts"]];
    NSUInteger index = [accounts indexOfObject:self.account];
    if (index != NSNotFound) {
        [accounts removeObjectAtIndex:index];
        [accounts insertObject:acc atIndex:index];
        [defaults setObject:accounts forKey:@"accounts"];
        [defaults synchronize];
        self.account = acc;
        refresh = YES;        
    }else{
        NSLog(@"Can't find account %@",self.account);
    }
}

@end
