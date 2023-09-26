//
//  IndexViewController.m
//  MyCP
//
//  Created by Vlad Alexa on 8/9/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import "IndexViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "GMGridView.h"

#import "IconCell.h"

#import "CpanelViewController.h"
#import "PhpViewController.h"

#import "PDKeychainBindings.h"

@interface IndexViewController () <GMGridViewDataSource, GMGridViewSortingDelegate,GMGridViewActionDelegate>
{
    __gm_weak GMGridView *_gmGridView;
    NSMutableArray *_currentData;
    NSInteger _lastDeleteItemIndexAsked;
}


@end


@implementation IndexViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _defaults = [NSUserDefaults standardUserDefaults];
        
        _currentData = [[NSMutableArray alloc] initWithArray:[_defaults objectForKey:@"accounts"]];
        [_currentData addObject:[NSDictionary dictionaryWithObject:@"+" forKey:@"domain"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theEvent:) name:@"IndexObserver" object:nil];
        
        [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(refreshUI) userInfo:nil repeats:NO];
        
    }
    return self;
}

-(void)theEvent:(NSNotification*)notif
{
	if ([[notif object] isKindOfClass:[NSString class]])
    {
		if ([[notif object] isEqualToString:@"Refresh"])
        {            
            [self refreshAccounts];
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshUI) userInfo:nil repeats:NO];
		}
    }
}

- (void)loadView
{
    [super loadView];
    
    NSInteger spacing = INTERFACE_IS_PHONE ? 10 : 15;
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    _gmGridView = gmGridView;
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.minimumPressDuration = 1.5;
    _gmGridView.itemSpacing = spacing;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _gmGridView.centerGrid = YES;
    _gmGridView.disableEditOnEmptySpaceTap = YES;
    _gmGridView.enableEditOnLongPress = YES;
    _gmGridView.actionDelegate = self;
    _gmGridView.sortingDelegate = self;
    _gmGridView.dataSource = self;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark GMGridViewDataSource


- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_currentData count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(210, 165);
        } else {
            return CGSizeMake(140, 110);
        }
    } else {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(487, 382);
        } else {
            return CGSizeMake(360, 283);
        }
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        
    NSDictionary *account = [_currentData objectAtIndex:index];
    
    //GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    GMGridViewCell *cell = [[IconCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) userInfo:account];
    
    //[[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES; //index % 2 == 0;
}


#pragma mark GMGridViewActionDelegate

- (void)GMGridViewDidTapOnPlus:(GMGridView *)gridView
{
    if (_refreshing != YES) {
        [_gmGridView setEditing:NO];
        [self addItem];
    }
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)index
{
    IconCell *sender = (IconCell*)[_gmGridView cellForItemAtIndex:index];
    
    NSDictionary *account = [_currentData objectAtIndex:index];
    
    if ([[account objectForKey:@"domain"] isEqualToString:@""])
    {
        //add
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addController:) userInfo:sender repeats:NO];
    }else{
        //view
        if ([[account objectForKey:@"type"] isEqualToString:@"cpanel"])
        {
            CpanelViewController *controller = [[CpanelViewController alloc] initWithNibName:@"CpanelViewController" bundle:nil];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            controller.account = account;
            controller.xmldata = sender.xmldata;
            [self presentViewController:controller animated:YES completion:nil];
        }else if ([[account objectForKey:@"type"] isEqualToString:@"phpsysinfo"])
        {
            PhpViewController *controller = [[PhpViewController alloc] initWithNibName:@"PhpViewController" bundle:nil];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            controller.account = account;
            controller.xmldata = sender.xmldata;
            [self presentViewController:controller animated:YES completion:nil];
        }else{
            NSLog(@"Unknown account type %@",[account objectForKey:@"type"]);
        }
        
    }
    
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    //NSLog(@"Tap on empty space");
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    NSDictionary *account = [_currentData objectAtIndex:index];
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@ ?",[account objectForKey:@"domain"]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    
    [alert show];
    
    _lastDeleteItemIndexAsked = index;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [_currentData removeObjectAtIndex:_lastDeleteItemIndexAsked];
        [_gmGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[_defaults objectForKey:@"accounts"]];
        [arr removeObjectAtIndex:_lastDeleteItemIndexAsked];
        [_defaults setObject:arr forKey:@"accounts"];
        [_defaults synchronize];
    }
}


#pragma mark GMGridViewSortingDelegate


- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.layer.opacity = 0.5;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.layer.opacity = 1.0;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSObject *object = [_currentData objectAtIndex:oldIndex];
    [_currentData removeObject:object];
    [_currentData insertObject:object atIndex:newIndex];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[_defaults objectForKey:@"accounts"]];
    [arr removeObject:object];
    [arr insertObject:object atIndex:newIndex];
    [_defaults setObject:arr forKey:@"accounts"];
    [_defaults synchronize];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [_currentData exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[_defaults objectForKey:@"accounts"]];
    [arr  exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    [_defaults setObject:arr forKey:@"accounts"];
    [_defaults synchronize];
}


#pragma mark add

- (void)addItem
{
    int newindex = [_currentData count] - 1;
    
    [_currentData insertObject:[NSDictionary dictionaryWithObject:@"" forKey:@"domain"] atIndex:newindex];
    [_gmGridView insertObjectAtIndex:newindex withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
    
    GMGridViewCell *sender = [_gmGridView cellForItemAtIndex:newindex];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addController:) userInfo:sender repeats:NO];
    
}

-(void)addController:(NSTimer*)timer
{
    UIView *sender = [timer userInfo];
    if (INTERFACE_IS_PHONE)
    {
        AddViewController *controller = [[AddViewController alloc] initWithNibName:@"AddViewController" bundle:nil];
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        controller.delegate = self;        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        if (!self.addPopoverController) {
            AddViewController *controller = [[AddViewController alloc] initWithNibName:@"AddViewController" bundle:nil];
            controller.delegate = self;
            self.addPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];            
            [self.addPopoverController setPopoverContentSize:CGSizeMake(320,330) animated:YES];          
        }
        if ([self.addPopoverController isPopoverVisible]) {
            [self.addPopoverController dismissPopoverAnimated:YES];
        } else {
            CGRect rect = CGRectMake(sender.frame.size.width/4,sender.frame.size.height/4,sender.frame.size.width/2,sender.frame.size.height/2);
            [self.addPopoverController presentPopoverFromRect:rect inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (void)addViewControllerDidFinish:(AddViewController *)controller
{
    if (INTERFACE_IS_PHONE) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.addPopoverController dismissPopoverAnimated:YES];
    }
    [self refreshAccounts];
    [self refreshUI];
}

#pragma mark XmlParseDelegate

- (void) parsingDidFinish:(XmlParse *)xmlParse
{
    NSString *type = [xmlParse.userInfo objectForKey:@"type"];
    NSString *name = [xmlParse.userInfo objectForKey:@"domain"];
    
    NSLog(@"Index parsed %@ %@",type,name);
    
    NSDictionary *xmldata = nil;
    
    if ([type isEqualToString:@"cpanel"]) {
        if ([xmlParse.array count] > 0)
        {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:1];
            for (NSDictionary *dict in xmlParse.array)
            {
                //stats
                NSString *name = [dict objectForKey:@"name"];
                if (name)
                {
                    [data setObject:dict forKey:name];
                }
            }
            xmldata = data;
        }else{
            NSLog(@"%@",xmlParse.array);
        }
    }
    
    if ([type isEqualToString:@"phpsysinfo"]) {
        if ([xmlParse.array count] == 1) {;
            xmldata = [xmlParse.array lastObject];
        }else{
            NSLog(@"%@",xmlParse.array);
        }
    }

    IconCell *accountTile = (IconCell*)[_gmGridView cellForItemAtIndex:[_currentData indexOfObject:xmlParse.userInfo]];
    [accountTile performSelectorOnMainThread:@selector(stopSpinning:) withObject:xmldata waitUntilDone:NO];
    
}

- (void) parsingDidFail:(XmlParse *)xmlParse
{
    NSLog(@"Parsing %@ %@ failed",[xmlParse.userInfo objectForKey:@"type"],[xmlParse.userInfo objectForKey:@"domain"]);
    IconCell *accountTile = (IconCell*)[_gmGridView cellForItemAtIndex:[_currentData indexOfObject:xmlParse.userInfo]];    
   [accountTile performSelectorOnMainThread:@selector(stopSpinning:) withObject:nil waitUntilDone:NO];
   [accountTile performSelectorOnMainThread:@selector(setLabel:) withObject:@"Parse error" waitUntilDone:NO];
}

#pragma mark refresh

- (void)refreshAccounts
{
    [self dismissModalViewControllerAnimated:NO];
    [_currentData setArray:[_defaults objectForKey:@"accounts"]];
    [_currentData addObject:[NSDictionary dictionaryWithObject:@"+" forKey:@"domain"]];
    [_gmGridView reloadData];
}

-(void)refreshUI
{   
    if (_refreshing != YES && [_gmGridView isEditing] != YES) {
        if (INTERFACE_IS_PAD) [_gmGridView reloadData]; //bugfix for missing plus cell in the cache on iPad (forces setSubviewsCacheAsInvalid, kinda wastefull TODO)
        int plusIndex = [_currentData count]-1;
        if (plusIndex > 0) {
            IconCell *plusTile = (IconCell*)[_gmGridView cellForItemAtIndex:plusIndex];
            [plusTile setHidden:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self refreshUIThreaded];
            });
        }
    }
}

-(void)refreshUIThreaded
{            
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];

    for (NSDictionary *account in _currentData) {
        IconCell *accountTile = (IconCell*)[_gmGridView cellForItemAtIndex:[_currentData indexOfObject:account]];
        [accountTile performSelectorOnMainThread:@selector(startSpinning) withObject:nil waitUntilDone:NO];
        
        NSString *type = [account objectForKey:@"type"];
        NSString *server = [account objectForKey:@"server"];
        NSString *domain = [account objectForKey:@"domain"];
        NSString *user = [account objectForKey:@"username"];
        NSString *url = [account objectForKey:@"url"];
        NSString *b64 = [bindings stringForKey:domain];
        if ([type isEqualToString:@"cpanel"])
        {
            NSError *err = nil;
            NSData *data = [CpanelViewController execCpanelCommand:@"StatsBar&cpanel_xmlapi_func=stat&display=diskusage%7Cbandwidthusage%7Cpostgresdiskusage%7Cmysqldiskusage" server:server domain:domain user:user b64:b64 error:&err];
            if (data) {
                [XmlParse parserWithData:data userInfo:account delegate:self];
            }else{
                NSLog(@"Failed to get cpanel data for %@ (%@)",domain,[err localizedDescription]);
                [accountTile performSelectorOnMainThread:@selector(stopSpinning:) withObject:nil waitUntilDone:NO];
                [accountTile performSelectorOnMainThread:@selector(setLabel:) withObject:[err localizedDescription] waitUntilDone:NO];
            }
            
        }else if ([type isEqualToString:@"phpsysinfo"])
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (data) {
                [XmlParse parserWithData:data userInfo:account delegate:self];
            }else{
                NSLog(@"Failed to get phpsysinfo data for %@ (%@)",domain,url);
                [accountTile performSelectorOnMainThread:@selector(stopSpinning:) withObject:nil waitUntilDone:NO];
                [accountTile performSelectorOnMainThread:@selector(setLabel:) withObject:@"Request failed." waitUntilDone:NO];                
            }
        }
        
        //set plus visible again
        if ([domain isEqualToString:@"+"]) {
            [accountTile performSelectorOnMainThread:@selector(setHidden:) withObject:nil waitUntilDone:NO];
        }

    }
    
    _refreshing = NO;
    
}

@end
