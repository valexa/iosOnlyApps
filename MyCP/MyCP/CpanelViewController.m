//
//  CpanelViewController.m
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import "CpanelViewController.h"

#import "PDKeychainBindings.h"

@interface CpanelViewController ()

@end

@implementation CpanelViewController

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
            [self downloadLimits];
        });
    }else{
        [self loadData:self.xmldata];        
    }
    
    self.logs = [[NSMutableArray alloc] init];
    self.info = [[NSMutableArray alloc] init];
    
    
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
        
    NSDictionary *diskusage = [data objectForKey:@"diskusage"];
    if (diskusage) {
        labelDiskUsed.text = [NSString stringWithFormat:@"USED %@",[XmlParse humanizeSize:[diskusage objectForKey:@"_count"] inUnit:[diskusage objectForKey:@"units"]]];
        labelDiskTotal.text = [NSString stringWithFormat:@"OF %@",[XmlParse humanizeSize:[diskusage objectForKey:@"_max"] inUnit:[diskusage objectForKey:@"units"]]];
        labelDiskPercent.text = [NSString stringWithFormat:@"%@%% used",[diskusage objectForKey:@"percent"]];
        progDisk.progress = [[diskusage objectForKey:@"percent"] intValue]/100.0;
    }
    
    NSDictionary *bandwidthusage = [data objectForKey:@"bandwidthusage"];
    if (bandwidthusage) {
        labelBandUsed.text = [NSString stringWithFormat:@"USED %@",[XmlParse humanizeSize:[bandwidthusage objectForKey:@"_count"] inUnit:[bandwidthusage objectForKey:@"units"]]];
        labelBandTotal.text = [NSString stringWithFormat:@"OF %@",[XmlParse humanizeSize:[bandwidthusage objectForKey:@"_max"] inUnit:[bandwidthusage objectForKey:@"units"]]];
        labelBandPercent.text = [NSString stringWithFormat:@"%@%% used",[bandwidthusage objectForKey:@"percent"]];
        progBand.progress = [[bandwidthusage objectForKey:@"percent"] intValue]/100.0;
    }
    
    NSDictionary *mysqldiskusage = [data objectForKey:@"mysqldiskusage"];
    if (mysqldiskusage) {
        labelDbUsed.text = [NSString stringWithFormat:@"USED %@",[XmlParse humanizeSize:[mysqldiskusage objectForKey:@"count"] inUnit:[mysqldiskusage objectForKey:@"units"]]];
        labelDbTotal.text = [NSString stringWithFormat:@"OF %@",[XmlParse humanizeSize:[mysqldiskusage objectForKey:@"max"] inUnit:[mysqldiskusage objectForKey:@"units"]]];
        labelDbPercent.text = [NSString stringWithFormat:@"%@%% used",[mysqldiskusage objectForKey:@"percent"]];
        progDb.progress = [[mysqldiskusage objectForKey:@"percent"] intValue]/100.0;
    }
    
}

#pragma mark actions

- (IBAction)showSettings:(id)sender
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

#pragma mark downloads

-(void)downloadLogs
{
    if ([self.logs count] > 0) return;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];    
    
    [logsSpinner performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];  
    
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    NSString *server = [self.account objectForKey:@"server"];
    NSString *domain = [self.account objectForKey:@"domain"];
    NSString *user = [self.account objectForKey:@"username"];
    NSString *b64 = [bindings stringForKey:domain];
    
    NSData *log = [CpanelViewController execCpanelCommand:@"Stats&cpanel_xmlapi_func=listrawlogs" server:server domain:domain user:user b64:b64 error:nil];
    if (log) {
        [XmlParse parserWithData:log userInfo:self.account delegate:self];
    }else{
        NSLog(@"Failed to get cpanel logs");
    }

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)downloadLimits
{
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    
    NSString *server = [self.account objectForKey:@"server"];
    NSString *domain = [self.account objectForKey:@"domain"];
    NSString *user = [self.account objectForKey:@"username"];
    NSString *b64 = [bindings stringForKey:domain];
    
    NSError *err;
    NSData *usage = [CpanelViewController execCpanelCommand:@"StatsBar&cpanel_xmlapi_func=stat&display=diskusage%7Cbandwidthusage%7Cpostgresdiskusage%7Cmysqldiskusage" server:server domain:domain user:user b64:b64 error:&err];
    if (usage) {
        [XmlParse parserWithData:usage userInfo:self.account delegate:self];        
    }else{
        NSLog(@"Failed to get cpanel data %@",[err localizedDescription]);
        navBar.topItem.title = @"website unreachable";        
    }
}

-(void)downloadGraphs
{
    
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    NSString *b64 = [bindings stringForKey:[self.account objectForKey:@"domain"]];
    NSString *user = [self.account objectForKey:@"username"];
    if (dayGraph == nil) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];        
        NSData *imgdata = [CpanelViewController getCpanelFile:[NSString stringWithFormat:@"tmp/%@/bw-%@-today.png",user,user] server:[self.account objectForKey:@"server"] b64:b64];
        dayGraph = [[UIImage alloc] initWithData:imgdata];
        [dayGraphView setImage:dayGraph];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];         
    }
    if (weekGraph == nil) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];         
        NSData *imgdata = [CpanelViewController getCpanelFile:[NSString stringWithFormat:@"tmp/%@/bw-%@-7days.png",user,user] server:[self.account objectForKey:@"server"] b64:b64];
        weekGraph = [[UIImage alloc] initWithData:imgdata];
        [weekGraphView setImage:weekGraph];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    if (monthGraph == nil) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];         
        NSData *imgdata = [CpanelViewController getCpanelFile:[NSString stringWithFormat:@"tmp/%@/bw-%@-year.png",user,user] server:[self.account objectForKey:@"server"] b64:b64];
        monthGraph = [[UIImage alloc] initWithData:imgdata];
        [monthGraphView setImage:monthGraph];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
       
}

-(void)downloadInfo
{
    
    if ([self.info count] > 0) return;
    
    [infoSpinner performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *pageURl = [NSString stringWithFormat:@"http://api.ipinfodb.com/v2/ip_query.php?key=7aab000be328d5a62ef2f794f98ae8bdefd7c290734ae912802c407c12468c05&timezone=false&ip=%@",navBar.topItem.title];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:pageURl]];
    if ([data length] > 50)
    {
        NSDictionary *dict = [XmlParse simpleParserWithData:data];
        [self.info removeAllObjects];
        for (NSString *key in dict)
        {
            [self.info addObject:[NSArray arrayWithObjects:key,[dict objectForKey:key], nil]];
        }
        [infoTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [infoSpinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        NSLog(@"Downloaded geoip");        
    }else{
        NSLog(@"Retrying geoip");
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dowloadInfo) userInfo:nil repeats:NO];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark XmlParseDelegate

- (void) parsingDidFinish:(XmlParse *)xmlParse
{
    if ([xmlParse.array count] > 0)
    {
        NSLog(@"Parsed %@",[xmlParse.userInfo objectForKey:@"domain"]);
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:1];
        BOOL stats = YES;
        for (NSDictionary *dict in xmlParse.array)
        {
            //stats
            NSString *name = [dict objectForKey:@"name"];
            if (name)
            {
                [data setObject:dict forKey:name];
                stats = YES;
            }
            //logs
            NSString *domain = [dict objectForKey:@"domain"];
            if (domain)
            {
                stats = NO;
            }
        }
        if (stats)
        {
            self.xmldata = data;
            [self loadData:self.xmldata];
        }else{
            [self.logs setArray:xmlParse.array];
            [logsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [logsSpinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        }
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
    if ([item.title isEqualToString:@"Limits"]) {
        [logsView removeFromSuperview];
        [graphsView removeFromSuperview];
        [infoView removeFromSuperview];        
        [limitsView setFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height-44-49)];
        [self.view addSubview:limitsView];
    }
    
    if ([item.title isEqualToString:@"Logs"]) {
        if (INTERFACE_IS_PAD) logsTable.rowHeight = 75;
        [limitsView removeFromSuperview];
        [graphsView removeFromSuperview];
        [infoView removeFromSuperview];        
        [logsView setFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height-44-49)];
        [self.view addSubview:logsView];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self downloadLogs];
        });
    }
    
    if ([item.title isEqualToString:@"Graphs"]) {
        [logsView removeFromSuperview];
        [limitsView removeFromSuperview];
        [infoView removeFromSuperview];
        [graphsView setFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height-44-49)];
        if (INTERFACE_IS_PHONE) {
            [(UIScrollView*)graphsView setContentSize:CGSizeMake(410-45, self.view.frame.size.height-44-49)];
        }else{
            [(UIScrollView*)graphsView setContentSize:CGSizeMake(self.view.frame.size.width+45, self.view.frame.size.height-44-49)];
        }
        [self.view addSubview:graphsView];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self downloadGraphs];
        });
    }
    
    if ([item.title isEqualToString:@"Info"]) {
        if (INTERFACE_IS_PAD) {
            infoTable.rowHeight = 60;
        }else{
            infoTable.rowHeight = 30;
        }
        [limitsView removeFromSuperview];
        [graphsView removeFromSuperview];
        [logsView removeFromSuperview];        
        [infoView setFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height-44-49)];
        [self.view addSubview:infoView];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self downloadInfo];
        });
    }
    
}

#pragma mark UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == logsTable) return [self.logs count];
    if (tableView == infoTable) return [self.info count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
    
    int fontHeight = 18;
    if (INTERFACE_IS_PHONE) fontHeight = 14;
    
    if (tableView == logsTable)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        NSDictionary *log = [self.logs objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [log objectForKey:@"domain"];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:fontHeight];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.shadowColor = [UIColor darkGrayColor];
        cell.textLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Size: %@ Updated: %@",[XmlParse humanizeSize:[[log objectForKey:@"size"] longLongValue]],[log objectForKey:@"humanupdatetime"]];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:fontHeight-2];
    }
    
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

+(NSData*)execCpanelCommand:(NSString*)command server:(NSString*)server domain:(NSString*)domain user:(NSString*)user b64:(NSString*)b64 error:(NSError**)theError
{
    if(theError == NULL){
        NSError __autoreleasing *localError = nil;        
        theError = &localError;
    }
    
	NSURL *authUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:2083/xml-api/cpanel?cpanel_xmlapi_version=2&domain=%@&user=%@&cpanel_xmlapi_module=%@",server,domain,user,command]];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:authUrl];
	[req setHTTPMethod:@"GET"];
    [req setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
    [req setValue:[NSString stringWithFormat:@"Basic %@",b64] forHTTPHeaderField:@"Authorization"];
	
	NSHTTPURLResponse *response;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:theError];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if (data != nil) {
        return data;
	} else {
		if (*theError) NSLog(@"ERROR: %@ %@",server,[*theError localizedDescription]);
	}
    return nil;
}

+(NSData*)getCpanelFile:(NSString*)file server:(NSString*)server b64:(NSString*)b64
{
	NSURL *authUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:2083/%@",server,file]];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:authUrl];
	[req setHTTPMethod:@"GET"];
    [req setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
    [req setValue:[NSString stringWithFormat:@"Basic %@",b64] forHTTPHeaderField:@"Authorization"];
	
	NSHTTPURLResponse *response;
	NSError *error;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if (data != nil) {
        return data;
	} else {
		if (error) NSLog(@"Failed to connect to %@ %@",server,[error localizedDescription]);
	}
    return nil;
}


+ (NSString *)base64EncodeData:(NSData*)dataToConvert
{
	static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    if ([dataToConvert length] == 0) return @"";
    
    char *characters = malloc((([dataToConvert length] + 2) / 3) * 4);
    if (characters == NULL) return nil;
    
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [dataToConvert length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [dataToConvert length])
            buffer[bufferLength++] = ((char *)[dataToConvert bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSUTF8StringEncoding freeWhenDone:YES];
}


@end
