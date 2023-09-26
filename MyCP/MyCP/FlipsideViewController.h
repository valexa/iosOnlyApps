//
//  FlipsideViewController.h
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlipsideViewController : UIViewController {
    IBOutlet UINavigationBar *navBar;
    IBOutlet UISegmentedControl *metricControl;
    IBOutlet UISegmentedControl *graphControl;
    NSUserDefaults *defaults;
    BOOL refresh;
}

@property (strong, nonatomic) NSDictionary *account;

- (IBAction)done:(id)sender;

-(IBAction)metricChanged:(id)sender;
-(IBAction)graphChanged:(id)sender;

@end
