//
//  AddViewController.h
//  MyCP
//
//  Created by Vlad Alexa on 8/15/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddViewController;

@protocol AddViewControllerDelegate
- (void)addViewControllerDidFinish:(AddViewController *)controller;
@end

@interface AddViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UISegmentedControl *type;
    IBOutlet UITextField *urlField;
    IBOutlet UITextField *domainField;
    IBOutlet UITextField *serverField;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIButton *addButton;
}

@property (weak, nonatomic) id <AddViewControllerDelegate> delegate;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)typeChange:(id)sender;

@end
