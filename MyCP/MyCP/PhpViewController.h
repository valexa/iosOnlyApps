//
//  PhpViewController.h
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import "FlipsideViewController.h"

#import "XmlParse.h"

@interface PhpViewController : UIViewController <XmlParseDelegate,UITabBarDelegate,UITableViewDataSource,UITableViewDelegate> {
    IBOutlet UINavigationBar *navBar;
    IBOutlet UITabBar *tabBar;    

    IBOutlet UILabel *labelCpuGHz;
    IBOutlet UILabel *labelCpu1;
    IBOutlet UILabel *labelCpu5;
    IBOutlet UILabel *labelCpu15;
    
    IBOutlet UIProgressView *progCpu1;
    IBOutlet UIProgressView *progCpu5;
    IBOutlet UIProgressView *progCpu15;

    IBOutlet UIProgressView *progMem;
    IBOutlet UIProgressView *progDisk;
    IBOutlet UIProgressView *progNet;
    
    IBOutlet UILabel *labelMemUsed;
    IBOutlet UILabel *labelMemTotal;
    IBOutlet UILabel *labelMemPercent;
    
    IBOutlet UILabel *labelDiskUsed;
    IBOutlet UILabel *labelDiskTotal;
    IBOutlet UILabel *labelDiskPercent;
    
    IBOutlet UILabel *labelNetOut;
    IBOutlet UILabel *labelNetIn;
    IBOutlet UILabel *labelNetErr;
    IBOutlet UILabel *labelNetDrop;
    IBOutlet UILabel *labelNetPercent;
    
    IBOutlet UIView *limitsView;
    IBOutlet UIView *infoView;
    
    IBOutlet UITableView *infoTable;
    IBOutlet UIActivityIndicatorView *infoSpinner;    
}

@property (strong, nonatomic) NSDictionary *account;
@property (strong, nonatomic) NSDictionary *xmldata;
@property (strong, nonatomic) NSMutableArray *info;

- (IBAction)showInfo:(id)sender;
- (IBAction)done:(id)sender;



@end
