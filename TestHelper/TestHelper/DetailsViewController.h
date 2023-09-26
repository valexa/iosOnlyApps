//
//  DetailsViewController.h
//  TestHelper
//
//  Created by Vlad Alexa on 2/6/13.
//  Copyright (c) 2013 Vlad Alexa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *verify;
    
    IBOutlet UIProgressView *estimatedProgress;
    IBOutlet UIProgressView *actualProgress;
    IBOutlet UIProgressView *minProgress;
    IBOutlet UIProgressView *timeProgress;

    IBOutlet UILabel *maxScore;
    IBOutlet UILabel *estimatedScore;
    IBOutlet UILabel *actualScore;
    IBOutlet UILabel *minScore;
    
    IBOutlet UILabel *maxSlack;
    IBOutlet UILabel *estimatedSlack;
    IBOutlet UILabel *actualSlack;
    IBOutlet UILabel *minSlack;
    
    IBOutlet UILabel *maxTime;
    IBOutlet UILabel *maxQPmin;
    IBOutlet UILabel *yourTime;
    IBOutlet UILabel *yourQPmin;
    
    NSDictionary *testDict;
    
    NSInteger index;
    
    NSUbiquitousKeyValueStore *defaults;
    
}

@end
