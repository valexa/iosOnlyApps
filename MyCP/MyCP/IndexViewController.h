//
//  IndexViewController.h
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AddViewController.h"

#import "XmlParse.h"

@interface IndexViewController : UIViewController <AddViewControllerDelegate,XmlParseDelegate> {

    NSUserDefaults *_defaults;
    BOOL _refreshing;
}

@property (strong, nonatomic) UIPopoverController *addPopoverController;

- (void)addItem;
-(void)addController:(NSTimer*)timer;

- (void)addViewControllerDidFinish:(AddViewController *)controller;

-(void)refreshUI;
-(void)refreshAccounts;

@end
