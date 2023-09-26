//
//  AppData.h
//  VAinfo
//
//  Created by Vlad Alexa on 3/30/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//


#import <SystemConfiguration/SCNetworkReachability.h>


@interface AppData : NSObject  {

}

+ (NSMutableDictionary*)getData;
+ (NSString*)testByName:(BOOL)byName;
+ (NSDictionary*)newgetAddress;
+ (NSString*)getFreeDiskSpace;
+ (NSString*)getAvailableMemory;
+ (NSString*)uptimeFromInterval:(double)time;
+ (NSString *)getMachineType;

@end
