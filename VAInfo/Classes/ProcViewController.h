//
//  ProcViewController.h
//  VAinfo
//
//  Created by Vlad Alexa on 9/14/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{

	NSDictionary *procs;
	UITableView *table;
	
}

+(NSArray*)allProcessesInfo;
+(BOOL) isProcessRunningByPID:(int) pidNum;
+(BOOL) isProcessRunningByName:(NSString *)name;
+(NSDictionary *)getProcessInfoByPID:(int) procPid;
+(NSString *)nameForProcessWithPID:(pid_t) pidNum;

@end
