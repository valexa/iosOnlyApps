//
//  PhpViewController.m
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import "PhpViewController.h"

#import "IconCell.h"

@interface PhpViewController ()

@end

@implementation PhpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
       
    navBar.topItem.title = [self.account objectForKey:@"domain"];
    
    [limitsView setFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height-44-49)];
    [self.view addSubview:limitsView];
    [tabBar setSelectedItem:[[tabBar items] objectAtIndex:0]];
    
    if (self.xmldata == nil && ![navBar.topItem.title isEqualToString:@"website unreachable"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadData];
        });
    }else{
        [self loadData:self.xmldata];
    }
    
    self.info = [[NSMutableArray alloc] init];
                
}

-(void)loadData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];        
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.account objectForKey:@"url"]]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (data) {
        [XmlParse parserWithData:data userInfo:self.account delegate:self];
    }else{
        for (UIView *view in self.view.subviews) {
            if ([view isMemberOfClass:[UIProgressView class]] || [view isMemberOfClass:[UILabel class]]) {
                [view setHidden:YES];
            }
        }
        navBar.topItem.title = @"website unreachable";
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void)loadData:(NSDictionary*)data
{
    labelCpuGHz.text = [NSString stringWithFormat:@"%.2fGHz",[[data objectForKey:@"CpuSpeed"] intValue]/1000.0];
    
    NSArray *load = [[data objectForKey:@"LoadAvg"] componentsSeparatedByString:@" "];
    if ([load count] == 3) {
        labelCpu1.text = [load objectAtIndex:0];
        labelCpu5.text = [load objectAtIndex:1];
        labelCpu15.text = [load objectAtIndex:2];
        [progCpu1 setProgress:[labelCpu1.text floatValue]];
        [progCpu5 setProgress:[labelCpu5.text floatValue]];
        [progCpu15 setProgress:[labelCpu15.text floatValue]];
    }else{
        NSLog(@"Error procesing LoadAvg");
    }
    
    long long MemoryUsed = [[data objectForKey:@"MemoryUsed"] longLongValue];
    long long MemoryTotal = [[data objectForKey:@"MemoryTotal"] longLongValue];
    labelMemUsed.text = [NSString stringWithFormat:@"USED %@",[XmlParse humanizeSize:MemoryUsed]];
    labelMemTotal.text = [NSString stringWithFormat:@"TOTAL %@",[XmlParse humanizeSize:MemoryTotal]];
    labelMemPercent.text = [NSString stringWithFormat:@"%.0f%% used",(float)MemoryUsed/(float)MemoryTotal*100];
    progMem.progress = (float)MemoryUsed/(float)MemoryTotal;

    long long StorageUsed = [[data objectForKey:@"StorageUsed"] longLongValue];
    long long StorageTotal = [[data objectForKey:@"StorageTotal"] longLongValue];
    labelDiskUsed.text = [NSString stringWithFormat:@"USED %@",[XmlParse humanizeSize:StorageUsed]];
    labelDiskTotal.text = [NSString stringWithFormat:@"TOTAL %@",[XmlParse humanizeSize:StorageTotal]];
    labelDiskPercent.text = [NSString stringWithFormat:@"%.0f%% used",(float)StorageUsed/(float)StorageTotal*100];
    progDisk.progress = (float)StorageUsed/(float)StorageTotal;
    
    long long NetworkDrops = [[data objectForKey:@"NetworkDrops"] longLongValue];
    long long NetworkErr = [[data objectForKey:@"NetworkErr"] longLongValue];
    long long NetworkIn = [[data objectForKey:@"NetworkIn"] longLongValue];
    long long NetworkOut = [[data objectForKey:@"NetworkOut"] longLongValue];
    labelNetDrop.text = [NSString stringWithFormat:@"DROP %@",[XmlParse humanizeSize:NetworkDrops]];
    labelNetErr.text = [NSString stringWithFormat:@"ERR %@",[XmlParse humanizeSize:NetworkErr]];
    labelNetOut.text = [NSString stringWithFormat:@"IN %@",[XmlParse humanizeSize:NetworkIn]];
    labelNetIn.text = [NSString stringWithFormat:@"OUT %@",[XmlParse humanizeSize:NetworkOut]];
    labelNetPercent.text = [NSString stringWithFormat:@"%.0f%% lost",(float)(NetworkDrops+NetworkErr)/(float)(NetworkIn+NetworkOut)*100];
    progNet.progress = (float)(NetworkDrops+NetworkErr)/(float)(NetworkIn+NetworkOut);
}

-(void)loadInfo
{
    if ([self.xmldata count] < 1) return;
    
    [self.info removeAllObjects];
    
    [self.info addObject:[NSArray arrayWithObjects:@"Operating System",[self.xmldata objectForKey:@"Distro"], nil]];
    [self.info addObject:[NSArray arrayWithObjects:@"Kernel",[self.xmldata objectForKey:@"Kernel"], nil]];
    [self.info addObject:[NSArray arrayWithObjects:@"Hostname",[self.xmldata objectForKey:@"Hostname"], nil]];
    [self.info addObject:[NSArray arrayWithObjects:@"IP",[self.xmldata objectForKey:@"IPAddr"], nil]];
    [self.info addObject:[NSArray arrayWithObjects:@"Uptime",[self uptimeFromInterval:[[self.xmldata objectForKey:@"Uptime"] doubleValue]], nil]];
    [self.info addObject:[NSArray arrayWithObjects:@"Users",[self.xmldata objectForKey:@"Users"], nil]];
    [self.info addObject:[NSArray arrayWithObjects:@"Machine clock offset",[self humanizeTime:[[self.xmldata objectForKey:@"timestamp"] intValue]-[[self.xmldata objectForKey:@"parsetimestamp"] intValue]], nil]];
    [self.info addObject:[NSArray arrayWithObjects:@"phpSysInfo version",[self.xmldata objectForKey:@"version"], nil]];
    
    [infoTable reloadData];
}

#pragma mark - Actions

- (IBAction)showInfo:(id)sender
{   
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	controller.modalPresentationStyle = UIModalPresentationFormSheet;    
    controller.account = self.account;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark XmlParseDelegate

- (void) parsingDidFinish:(XmlParse *)xmlParse
{
    NSString *name = [xmlParse.userInfo objectForKey:@"domain"];
    
    if ([xmlParse.array count] == 1) {
        NSLog(@"Parsed %@",name);
        self.xmldata = [xmlParse.array lastObject];        
        [self loadData:self.xmldata];
    }else{
        NSLog(@"%@",xmlParse.array);
    }
}

- (void) parsingDidFail:(XmlParse *)xmlParse
{
    NSLog(@"Parsing %@ %@ failed",[xmlParse.userInfo objectForKey:@"type"],[xmlParse.userInfo objectForKey:@"domain"]);
}

#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item.title isEqualToString:@"Load"]) {
        [infoView removeFromSuperview];
        [limitsView setFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height-44-49)];
        [self.view addSubview:limitsView];
    }
        
    if ([item.title isEqualToString:@"Info"]) {
        if (INTERFACE_IS_PAD) {
            infoTable.rowHeight = 60;
        }else{
            infoTable.rowHeight = 30;
        }
        [limitsView removeFromSuperview];
        [infoView setFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height-44-49)];
        [self.view addSubview:infoView];
        [self loadInfo];
    }
    
}

#pragma mark UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == infoTable) return [self.info count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
    
    int fontHeight = 18;
    if (INTERFACE_IS_PHONE) fontHeight = 14;
    
    if (tableView == infoTable)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        NSArray *info = [self.info objectAtIndex:indexPath.row];
        
        if ([info count] == 2) {
            cell.textLabel.text = [info objectAtIndex:0];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:fontHeight];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.shadowColor = [UIColor darkGrayColor];
            cell.textLabel.shadowOffset = CGSizeMake(0.5, 0.5);
            
            cell.detailTextLabel.text = [info objectAtIndex:1];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:fontHeight-2];
        }

    }
	
    
	return cell;
}


#pragma mark tools

-(NSString*)timeFromTimestamp:(int)ts
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:nil];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts];
    return [dateFormatter stringFromDate:date];
}

-(NSString*)humanizeTime:(int)time
{
	int d = 0;
	int h = 0;
	int m = 0;
	NSString *ret = @"";
	
	if (time < 0) {
        time = time *-1;
	}
    
	if (time == 0) {
        return @"0";
	}
    
	if (time >= 86400) {
		d = floor(time / 60 / 60 / 24);
		ret = [ret stringByAppendingFormat:@"%d day", d];
		if (d >= 2) ret = [ret stringByAppendingString:@"s"];
		ret = [ret stringByAppendingString:@", "];
	}
	if (time >= 3600 ) {
		h = floor((time-(d*86400)) / 60 / 60);
		ret = [ret stringByAppendingFormat:@"%d hour",h];
		if (h >= 2) ret = [ret stringByAppendingString:@"s"];
		ret = [ret stringByAppendingString:@", "];
	}
	if (time >= 60) {
		m = floor((time-(d*86400)-(h*3600)) / 60);
		ret = [ret stringByAppendingFormat:@"%d minute",m];
		if (m >= 2) ret = [ret stringByAppendingString:@"s"];
	}
	if (time >= 1) {
		m = floor((time-(d*86400)-(h*3600)));
		ret = [ret stringByAppendingFormat:@"%d second",m];
		if (m >= 2) ret = [ret stringByAppendingString:@"s"];
	}
	return ret;
}

-(NSString*)uptimeFromInterval:(double)time
{
	int d = 0;
	int h = 0;
	int m = 0;
	NSString *ret = @"";
	
	if (time < 60) {
		return @"less than a minute ago";
	}
	if (time >= 86400) {
		d = floor(time / 60 / 60 / 24);
		ret = [ret stringByAppendingFormat:@"%d day", d];
		if (d >= 2) ret = [ret stringByAppendingString:@"s"];
		ret = [ret stringByAppendingString:@", "];
	}
	if (time >= 3600 ) {
		h = floor((time-(d*86400)) / 60 / 60);
		ret = [ret stringByAppendingFormat:@"%d hour",h];
		if (h >= 2) ret = [ret stringByAppendingString:@"s"];
		ret = [ret stringByAppendingString:@", "];
	}
	if (time >= 60) {
		m = floor((time-(d*86400)-(h*3600)) / 60);
		ret = [ret stringByAppendingFormat:@"%d minute",m];
		if (m >= 2) ret = [ret stringByAppendingString:@"s"];
	}
	return ret;
}


@end
