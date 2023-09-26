//
//  TestViewController.h
//  TestHelper
//
//  Created by Vlad Alexa on 2/5/13.
//  Copyright (c) 2013 Vlad Alexa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController {

    IBOutlet UIProgressView *timeProgress;
    IBOutlet UIProgressView *scoreProgress;
    
    IBOutlet UILabel *questionsLeft;
    IBOutlet UILabel *questionsSlack;
    IBOutlet UILabel *corectNeeded;
    IBOutlet UILabel *correctAssesed;
    
    IBOutlet UILabel *timeLeft;
    IBOutlet UILabel *timePerQuestion;
    IBOutlet UILabel *timeAtQuestionNeeded;
    IBOutlet UILabel *timeAtQuestionAssesed;
    IBOutlet UILabel *timeAdvantage;
    
    IBOutlet UIButton *correctButton;
    IBOutlet UIButton *notsureButton;
    IBOutlet UIButton *endButton;
    
    CFTimeInterval startTime;
    
    NSUbiquitousKeyValueStore *defaults;
    
}

@property (strong, nonatomic) NSDictionary *testDict;

- (IBAction)endTest:(id)sender;

- (IBAction)correct:(id)sender;

- (IBAction)notsure:(id)sender;

@end
