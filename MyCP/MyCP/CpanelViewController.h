//
//  CpanelViewController.h
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import "FlipsideViewController.h"

#import "XmlParse.h"

@interface CpanelViewController : UIViewController <XmlParseDelegate,UITabBarDelegate,UITableViewDataSource> {
    IBOutlet UINavigationBar *navBar;
    IBOutlet UITabBar *tabBar;
       
    IBOutlet UIProgressView *progDb;
    IBOutlet UIProgressView *progDisk;
    IBOutlet UIProgressView *progBand;
    
    IBOutlet UILabel *labelDbUsed;
    IBOutlet UILabel *labelDbTotal;
    IBOutlet UILabel *labelDbPercent;
    
    IBOutlet UILabel *labelDiskUsed;
    IBOutlet UILabel *labelDiskTotal;
    IBOutlet UILabel *labelDiskPercent;
    
    IBOutlet UILabel *labelBandUsed;
    IBOutlet UILabel *labelBandTotal;
    IBOutlet UILabel *labelBandPercent;
    
    IBOutlet UIView *limitsView;
    IBOutlet UIView *logsView;
    IBOutlet UIView *graphsView;
    IBOutlet UIView *infoView;
    
    UIImage *dayGraph;
    UIImage *weekGraph;
    UIImage *monthGraph;
    
    IBOutlet UIImageView *dayGraphView;
    IBOutlet UIImageView *weekGraphView;
    IBOutlet UIImageView *monthGraphView;
    
    IBOutlet UITableView *logsTable;
    IBOutlet UIActivityIndicatorView *logsSpinner;
    
    IBOutlet UITableView *infoTable;
    IBOutlet UIActivityIndicatorView *infoSpinner;
    
}

@property (strong, nonatomic) NSDictionary *account;
@property (strong, nonatomic) NSDictionary *xmldata;
@property (strong, nonatomic) NSMutableArray *logs;
@property (strong, nonatomic) NSMutableArray *info;

- (IBAction)showSettings:(id)sender;
- (IBAction)done:(id)sender;

+(NSData*)execCpanelCommand:(NSString*)command server:(NSString*)server domain:(NSString*)domain user:(NSString*)user b64:(NSString*)b64 error:(NSError**)theError;
+ (NSString *)base64EncodeData:(NSData*)dataToConvert;


@end
