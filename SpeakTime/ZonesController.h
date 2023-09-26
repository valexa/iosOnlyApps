//
//  ZonesController.h
//  SpeakTime
//
//  Created by Vlad Alexa on 4/24/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DashedView;

@interface ZonesController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate>{
    NSUserDefaults *defaults;
    NSTimeZone *zone;
    NSString *zoneName;
    IBOutlet UILabel *gmtLabel;
    IBOutlet UILabel *abrevLabel;
    IBOutlet UILabel *nameLabel;    
    IBOutlet DashedView *dashedView;
    IBOutlet UIButton *doneButton;    
    NSMutableDictionary *timezonesDB;
    NSMutableArray *timezoneAlternatives;
    
    UIPopoverController *parentPopOver;      
	
}

@property (nonatomic, assign) UIPopoverController *parentPopOver;

-(IBAction)dismissSelf:(id)sender;
-(IBAction)done:(id)sender;

@property (retain) NSTimeZone *zone;
@property (retain) NSString *zoneName;

@end
