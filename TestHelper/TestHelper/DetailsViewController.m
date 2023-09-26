//
//  DetailsViewController.m
//  TestHelper
//
//  Created by Vlad Alexa on 2/6/13.
//  Copyright (c) 2013 Vlad Alexa. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    
    defaults  = [NSUbiquitousKeyValueStore defaultStore];
    
    index = [self.title intValue];
    
    testDict = [[defaults objectForKey:@"tests"] objectAtIndex:index];
    
    self.title = [testDict objectForKey:@"testName"];
    
    [verify setPlaceholder:[testDict objectForKey:@"assessed"]];
    [verify setText:[testDict objectForKey:@"verified"]];
    
    int questions = [[testDict objectForKey:@"questions"] intValue];
    int goal = [[testDict objectForKey:@"goal"] intValue];
    int assessed = [[testDict objectForKey:@"assessed"] intValue];
    int verified = [[testDict objectForKey:@"verified"] intValue];
    int ytime = [[testDict objectForKey:@"endTime"] timeIntervalSinceDate:[testDict objectForKey:@"startTime"]]/60;
    int time = [[testDict objectForKey:@"timeLimit"] intValue];
    if (ytime > time) ytime = time;
    
    if (assessed >= goal) {
        [estimatedProgress setProgressTintColor:[UIColor greenColor]];
    }else{
        [estimatedProgress setProgressTintColor:[UIColor redColor]];
    }
    
    if (verified >= goal) {
        [actualProgress setProgressTintColor:[UIColor greenColor]];
    }else{
        [actualProgress setProgressTintColor:[UIColor redColor]];
    }
    
    [maxScore setText:[testDict objectForKey:@"questions"]];
    [estimatedScore setText:[testDict objectForKey:@"assessed"]];
    [actualScore setText:[testDict objectForKey:@"verified"]];
    [minScore setText:[testDict objectForKey:@"goal"]];
    
    [maxSlack setText:[NSString stringWithFormat:@"%i slack",questions-goal]];
    [estimatedSlack setText:[NSString stringWithFormat:@"%i slack",(questions-goal) - (questions-assessed)]];
    if (verified > 0) [actualSlack setText:[NSString stringWithFormat:@"%i slack",(questions-goal) - (questions-verified)]];
    [minSlack setText:@"0 slack"];
    
    [maxTime setText:[testDict objectForKey:@"timeLimit"]];
    [maxQPmin setText:[NSString stringWithFormat:@"%.1f question/min",(float)questions/time]];
    [yourTime setText:[NSString stringWithFormat:@"%i",ytime]];
    if (ytime > 0) [yourQPmin setText:[NSString stringWithFormat:@"%.1f question/min",(float)questions/ytime]];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    [estimatedProgress setProgress:(float)assessed/questions];
    [actualProgress setProgress:(float)verified/questions];
    [minProgress setProgress:(float)goal/questions];
    [timeProgress setProgress:(float)ytime/time];
    
    [UIView commitAnimations];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    int questions = [[testDict objectForKey:@"questions"] intValue];
    int goal = [[testDict objectForKey:@"goal"] intValue];
    int verified = [[textField text] intValue];
    if (verified > questions) verified = questions;
    
    if (verified >= goal) {
        [actualProgress setProgressTintColor:[UIColor greenColor]];
    }else{
        [actualProgress setProgressTintColor:[UIColor redColor]];
    }

    [actualScore setText:[textField text]];
    [actualSlack setText:[NSString stringWithFormat:@"%i slack",(questions-goal) - (questions-verified)]];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [actualProgress setProgress:(float)verified/questions];
    [UIView commitAnimations];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[defaults objectForKey:@"tests"]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:testDict];
    [dict setObject:[textField text] forKey:@"verified"];
    [arr replaceObjectAtIndex:index withObject:dict];
    [defaults setArray:arr forKey:@"tests"];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if ([theTextField isFirstResponder]) {
        //take focus away from the text field so that the keyboard is dismissed.
        [theTextField resignFirstResponder];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    if ([verify isFirstResponder]) [verify resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
    
}

@end
