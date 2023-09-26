//
//  MainViewController.m
//  VAinfo
//
//  Created by Vlad Alexa on 07/7/08.
//  Copyright 2008 __VladAlexa__. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController

@synthesize list,table;

- (void)viewDidLoad {
    
    table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    self.tableView = table;
    [table reloadData];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

	self.title = NSLocalizedString(@"VAinfo", @"Info title");
    self.view.backgroundColor = [UIColor whiteColor];
	
	defaults = [NSUserDefaults standardUserDefaults];			
    
    [super viewDidLoad];
	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppDelegateEvent" object:@"refresh" userInfo:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)dealloc {
	[table release];
	[super dealloc];     
}

- (id)objectAtIndex:(NSUInteger)theIndex {	
	NSInteger n = 0;
	for (NSString *key in list) {	
		if (n == theIndex){
			return key;
		}
		n = n + 1;		
	}
	return nil;
}


// Subclasses override this method to define how the view they control will respond to device rotation 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark tableview delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 9;
    if (section == 1) return 6;
    if (section == 2) return 5;
    if (section == 3) return 7;
    if (section == 4) return 6;	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) return @"General";
    if (section == 1) return @"Network";	
    if (section == 2) return @"Location";
    if (section == 3) return @"Operating System";
    if (section == 4) return @"Processor";	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSArray *order = [NSArray arrayWithObjects:
					  [NSArray arrayWithObjects:					   
					   @"CPU",					   
					   @"Battery",
					   @"Uptime",					   
					   @"Free Space",
					   @"Free Memory",						  
					   @"Operating System",
					   @"Name/Type",
					   @"Model/Code",
					   @"Device ID",	
					   nil],					  					  
					  [NSArray arrayWithObjects:			  
					   @"Network",			  				  
					   @"IP (private)",
					   @"IP (public)",		
					   @"Carrier IP",					  
					   @"Hostname",	
					   @"Node",						   
					   nil],
					  [NSArray arrayWithObjects:
					   @"Latitude, Longitude",	
					   @"Altitude (precision)",
					   @"Place",
					   @"Speed",
					   @"Heading",					   
					   nil],
					  [NSArray arrayWithObjects:
					   @"Name",	
					   @"Kernel",		
					   @"Build",					   
					   @"Build Date",	
					   @"Max Childs/Files/Streams",
					   @"User Name",				   
					   @"Boot Date",				   
					   nil],
					  [NSArray arrayWithObjects:
					   @"Cores (active/total)",
					   @"Family",
					   @"Frequency",
					   @"Bus",					   
					   @"Cache (L1/L2)",
					   @"Load average",					   
					   nil],					  
					  nil];	

	static NSString *MyIdentifier = @"MyIdentifier";

	// Try to retrieve from the table view a now-unused cell with the given identifier
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier] autorelease];
	}
	// Set up the cell
	NSString *dataRowName = [[order objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];		//ordered
	NSString *valueRowName = [list objectForKey:dataRowName];	
	cell.textLabel.text = dataRowName;
	cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.text = valueRowName;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    
	return cell;	
}

/*
 To conform to Human Interface Guildelines, since selecting a row would have no effect (such as navigation), make sure that rows cannot be selected.
 */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UILabel *label = (UILabel *)[tableView cellForRowAtIndexPath:indexPath].accessoryView;
    if (label.text != nil) {
        NSString *value = label.text;
        UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
        [gpBoard setValue:value forPasteboardType:(NSString *)kUTTypeUTF8PlainText];
        //NSLog(@"copied %@",value);
    }
	return nil;
}

@end
