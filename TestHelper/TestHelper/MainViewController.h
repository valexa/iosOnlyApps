//
//  MainViewController.h
//  TestHelper
//
//  Created by Vlad Alexa on 1/30/13.
//  Copyright (c) 2013 Vlad Alexa. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate>{
    
    
    IBOutlet UITextField *testName;
    IBOutlet UITextField *testTime;
    IBOutlet UITextField *testQuestions;
    IBOutlet UITextField *testGoal;

    IBOutlet UIButton *startButton;
    IBOutlet UIButton *listButton;
    
    NSUbiquitousKeyValueStore *defaults;

}

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

- (IBAction)togglePopover:(id)sender;

- (IBAction)startTest:(id)sender;


@end
