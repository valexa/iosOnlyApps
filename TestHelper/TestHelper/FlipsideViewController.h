//
//  FlipsideViewController.h
//  TestHelper
//
//  Created by Vlad Alexa on 1/30/13.
//  Copyright (c) 2013 Vlad Alexa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSUbiquitousKeyValueStore *defaults;
}

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;


@end
