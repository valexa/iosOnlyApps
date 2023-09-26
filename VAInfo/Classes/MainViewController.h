//
//  MainViewController.h
//  VAinfo
//
//  Created by Vlad Alexa on 07/7/08.
//  Copyright 2008 __VladAlexa__. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

@interface MainViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource> {
	
	NSMutableDictionary *list;
	
	NSUserDefaults *defaults;	
	
	UITableView *table;

}

@property (nonatomic, retain) NSMutableDictionary *list;

@property (nonatomic, retain) UITableView *table;

- (id)objectAtIndex:(NSUInteger)theIndex;

@end

