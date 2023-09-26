    //
//  ProcViewController.m
//  VAinfo
//
//  Created by Vlad Alexa on 9/14/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "ProcViewController.h"

#import "SendViewController.h"

#import <sys/sysctl.h>
#import <pwd.h>
#import <sys/proc.h>

@implementation ProcViewController

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization

    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    		
	//add button
	UIBarButtonItem* sendBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendButtonPressed) ];
	self.navigationItem.rightBarButtonItem = sendBarButtonItem;
	[sendBarButtonItem release];	
	
	//get data	
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"ProcessPIDNumber" ascending:YES selector:@selector(compare:)];
	NSArray *procsArray = [[ProcViewController allProcessesInfo] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSMutableArray *root = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *mobile = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *others = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *item in procsArray)
    {
        NSString *proc = [item objectForKey:@"ProcessOwner"];
        if ([proc isEqualToString:@"root"])
        {
            [root addObject:item];
        }
        else if ([proc isEqualToString:@"mobile"])
        {
            [mobile addObject:item];
        }
        else
        {
            [others addObject:item];
        }
    }
    procs = [[NSDictionary dictionaryWithObjectsAndKeys:root, @"System tasks", mobile, @"User tasks", others, @"Other tasks", nil] retain];
	[descriptor release];

	//setup UI
	self.title = NSLocalizedString(@"Tasks", @"Info title");
    self.view.backgroundColor = [UIColor whiteColor];			
	
	table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	table.delegate = self;
	table.dataSource = self;		
	[self.view addSubview:table];	
	
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    
	float width = [[UIScreen mainScreen] applicationFrame].size.width;
	float height = [[UIScreen mainScreen] applicationFrame].size.height;
	if (self.interfaceOrientation == UIDeviceOrientationPortrait || self.interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)	{
		table.frame = CGRectMake(0,0,width,height-self.navigationController.navigationBar.bounds.size.height);	
	} else {
		table.frame = CGRectMake(0,0,height,width-self.navigationController.navigationBar.bounds.size.height);					
	}	
	[table reloadData];
    
    [super viewWillAppear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	table.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.bounds.size.height);	
	[table reloadData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //IOS 6+ to override iphone default UIInterfaceOrientationMaskAllButUpsideDown
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {  
	[procs release];
	[table release];	
    [super dealloc];      
}

-(void)sendButtonPressed{	
	NSMutableDictionary *list = [NSMutableDictionary dictionaryWithCapacity:1];
    
    for (NSString *key in procs) {
        for (NSDictionary *item in [procs objectForKey:key])
        {
            [list setObject:item forKey:[item objectForKey:@"ProcessPIDNumber"]];
        }
    }
    
	SendViewController *controller = [[SendViewController alloc] initWithNibName:@"SendView" bundle:nil];
	controller.list = list;		
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	controller.modalPresentationStyle = UIModalPresentationFormSheet;
	[self.navigationController presentViewController:controller animated:YES completion:^{
        
    }];
	[controller release];	
} 

#pragma mark UITableViewDelegate

/*
 To conform to Human Interface Guildelines, since selecting a row would have no effect (such as navigation), make sure that rows cannot be selected.
 */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) return [NSString stringWithFormat:@"System tasks (%lu)",(unsigned long)[[procs objectForKey:@"System tasks"] count]];
    if (section == 1) return [NSString stringWithFormat:@"User tasks (%lu)",(unsigned long)[[procs objectForKey:@"User tasks"] count]];
    if (section == 2) return [NSString stringWithFormat:@"Other tasks (%lu)",(unsigned long)[[procs objectForKey:@"Other tasks"] count]];
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [[procs objectForKey:@"System tasks"] count];
    if (section == 1) return [[procs objectForKey:@"User tasks"] count];
    if (section == 2) return [[procs objectForKey:@"Other tasks"] count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];

    NSInteger section = indexPath.section;
    NSString *sectionTitle = @"";
    if (section == 0) sectionTitle = @"System tasks";
    if (section == 1) sectionTitle = @"User tasks";
    if (section == 2) sectionTitle = @"Other tasks";
    
	NSDictionary *dict = [[procs objectForKey:sectionTitle] objectAtIndex:indexPath.row];
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"%@ NOT A DICT",dict);
        return cell;
    }
	
	NSString *priority = @"";
	if ([[dict objectForKey:@"ProcessSystemPriority"] intValue] == 17){
		//priority = @"Low priority";
	}else if ([[dict objectForKey:@"ProcessSystemPriority"] intValue] == 24) {
		priority = @"High priority";
	}else if ([[dict objectForKey:@"ProcessSystemPriority"] intValue] == 25) {
		priority = @"Highest priority";		
	}else {
		priority = @"Unknown priority";				
	}
	
	NSString *startedBy = @"";
	int parentPID = [[dict objectForKey:@"ProcessParentPID"] intValue];
	if (parentPID > 1) {
		for (NSDictionary *key in procs) {
            for (NSDictionary *item in [procs objectForKey:key])
            {
                if ([[item objectForKey:@"ProcessPIDNumber"] intValue] == parentPID){
                    startedBy = [item objectForKey:@"ProcessName"];
                }
            }
		}
	}
	
	NSString *status = @"";	
	if (![[dict objectForKey:@"ProcessStatus"] isEqualToString:@"Currently runnable "]){
		status = [dict objectForKey:@"ProcessStatus"];
	}	
	
	NSString *theTime;  
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yy-MM-dd HH:mm"];  
	theTime = [formatter stringFromDate:[dict objectForKey:@"ProcessStartTime"]];
	[formatter release];	
	
	//title
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 220, 30)];	
	titleLabel.textAlignment = NSTextAlignmentLeft;
	titleLabel.font = [UIFont systemFontOfSize:14];
	titleLabel.text = [dict objectForKey:@"ProcessName"];
	[cell.contentView addSubview:titleLabel];	
	[titleLabel release];
	//middle
	if (self.view.bounds.size.width > 450) {
		NSString *middleStr = [NSString stringWithFormat:@"%@ %@ %@",startedBy,priority,status];
		float middle;
		if (self.view.bounds.size.width < 500) {
			middle = 230.0;
		}else{
			middle = (self.view.bounds.size.width-300)/2;				
		}		
		UILabel *hnLabel = [[UILabel alloc] initWithFrame:CGRectMake(middle, 13, self.view.bounds.size.width/2.6, 17)];	
		hnLabel.textColor = [UIColor colorWithRed:0.92 green:0.49 blue:0.34 alpha:1.0];		
		hnLabel.textAlignment = NSTextAlignmentCenter;
		hnLabel.font = [UIFont systemFontOfSize:12];
		hnLabel.text = middleStr;
		[cell.contentView addSubview:hnLabel];	
		[hnLabel release];		
	}		
	//accessory top
	UILabel *afLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-110, 4, 100, 16.5)];		
	afLabel.textAlignment = NSTextAlignmentRight;
	afLabel.font = [UIFont systemFontOfSize:14];
	afLabel.text = [[dict objectForKey:@"ProcessPIDNumber"] stringValue];
	[cell.contentView addSubview:afLabel];	
	[afLabel release];
	//accesory footer
	UILabel *accLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-260, 29, 250, 13)];	
	accLabel.textColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.5 alpha:0.7];
	accLabel.textAlignment = NSTextAlignmentRight;
	accLabel.font = [UIFont systemFontOfSize:10];
	accLabel.text = [NSString stringWithFormat:@"started %@ by %@",theTime,[dict objectForKey:@"ProcessOwner"]];
	[cell.contentView addSubview:accLabel];
	[accLabel release];
		
	//NSLog(@"%@",[NSString stringWithFormat:@"%i",[[cell.contentView subviews] count]]);
	return cell;		
}	

#pragma mark tools

+(NSArray*)allProcessesInfo{
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:1];
    struct kinfo_proc *kp;
    int mib[4], nentries, i;
    size_t bufSize = 0;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_ALL;
    mib[3] = 0;
	
    if ( sysctl(mib, 4, NULL, &bufSize, NULL, 0) < 0 ) {
        return [returnArray autorelease];
    }
    
    kp = (struct kinfo_proc *)malloc( bufSize );
    if ( kp == NULL ) {
		return [returnArray autorelease];
    }
    if ( sysctl(mib, 4, kp, &bufSize, NULL, 0) < 0 ) {
		free( kp );
		return [returnArray autorelease];
    }
	
    nentries = bufSize / sizeof(struct kinfo_proc);
	
    if ( nentries == 0 ) {
		free( kp );
		return [returnArray autorelease];
    }
    
	for ( i = (nentries - 1); --i >= 0; ) {
		[returnArray addObject:[ProcViewController getProcessInfoByPID:(&kp[i])->kp_proc.p_pid]];
    }
    
    free( kp );
    
    return [returnArray autorelease];
}

+(BOOL) isProcessRunningByPID:(int) pidNum{
    struct kinfo_proc *kp;
    int mib[4], nentries;
    size_t bufSize = 0;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = pidNum;
	
    if ( sysctl(mib, 4, NULL, &bufSize, NULL, 0) < 0 ) {
        return NO;
    }
    
    kp = (struct kinfo_proc *)malloc( bufSize );
    if ( kp == NULL ) {
		return NO;
    }
    if ( sysctl(mib, 4, kp, &bufSize, NULL, 0) < 0 ) {
		free( kp );
		return NO;
    }
	
    nentries = bufSize / sizeof(struct kinfo_proc);
	
    if ( nentries == 0 ) {
		free( kp );
		return NO;
    }
    
    free( kp );
    
    return YES;
}

+(BOOL) isProcessRunningByName:(NSString *)name{
    char getProcName[255] = {0};
    struct kinfo_proc *kp;
    int mib[4], nentries, i;
    size_t bufSize = 0;
    
    strcpy( getProcName, [name UTF8String] );
	
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_ALL;
    mib[3] = 0;
	
    if ( sysctl(mib, 4, NULL, &bufSize, NULL, 0) < 0 ) {
        return NO;
    }
    
    kp = (struct kinfo_proc *)malloc( bufSize );
    if ( kp == NULL ) {
		return NO;
    }
    if ( sysctl(mib, 4, kp, &bufSize, NULL, 0) < 0 ) {
		free( kp );
		return NO;
    }
	
    nentries = bufSize / sizeof(struct kinfo_proc);
	
    if ( nentries == 0 ) {
		free( kp );
		return NO;
    }
    
	for ( i = nentries; --i >= 0; ) {
		NSAutoreleasePool *forPool = [[NSAutoreleasePool alloc] init];
		NSString *realName = [ProcViewController nameForProcessWithPID:(&kp[i])->kp_proc.p_pid];
		
		char *proc = ((&kp[i])->kp_proc.p_comm);
		
		if ( [realName isEqualToString:name] ) {
			free( kp );
			return YES;
		} else if ( !strcmp(proc, getProcName) ) {
			free( kp );
			return YES;
		}
		[forPool release];
    }
    
    free( kp );
    
    return NO;
}

+(NSDictionary *)getProcessInfoByPID:(int) procPid{
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] initWithCapacity:11];
    struct kinfo_proc *kp;
    int mib[4], nentries;
    size_t bufSize = 0;
	
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = procPid;
    
    if ( sysctl(mib, 4, NULL, &bufSize, NULL, 0) < 0 ) {
        return [returnDict autorelease];
    }
    
    kp= (struct kinfo_proc *)malloc( bufSize );
    if ( kp == NULL ) {
		return [returnDict autorelease];
    }
    if ( sysctl(mib, 4, kp, &bufSize, NULL, 0) < 0 ) {
		free( kp );
		return [returnDict autorelease];
    }
	
    nentries = bufSize / sizeof(struct kinfo_proc);
	
    if ( nentries == 0 ) {
		free( kp );
		return [returnDict autorelease];
    }
	
    {
		int procFlag = (int)(kp->kp_proc.p_flag);
        char procStat = (char)(kp->kp_proc.p_stat);
        pid_t procPid = (pid_t)(kp->kp_proc.p_pid);
        u_char procPriority = (u_char)(kp->kp_proc.p_priority);
        char procNice = (kp->kp_proc.p_nice);
		NSString *procName = [ProcViewController nameForProcessWithPID:kp->kp_proc.p_pid];
        pid_t procParentPid = (pid_t)(kp->kp_eproc.e_ppid);
        time_t procStartTime = (kp->kp_proc.p_starttime.tv_sec);
		uid_t userId = (kp->kp_eproc.e_ucred.cr_uid);
        
        /*
        //kernel hardclock updates p_cpu and p_cpticks independently, mac osx kernel does not update these at all anymore
        //per thread cpu only be obtained by root via mach/thread_info, struct thread_basic_info, member cpu_usage
        u_int timeOfTicks =(u_int)(kp->kp_proc.p_estcpu);	 // Time averaged value of p_cpticks.
        int numberOfTicks =	kp->kp_proc.p_cpticks;	 // Ticks of cpu time.
        fixpt_t	cpuProc =   kp->kp_proc.p_pctcpu;	 // %cpu for this process during p_swtime
        u_int	cpuTime =   kp->kp_proc.p_swtime;	 // Time swapped in or out.       
        */
        
		NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:procStartTime];
		struct passwd *pw;
		NSMutableString *procStats = [[NSMutableString alloc] initWithCapacity:10];
		NSMutableArray *procFlags = [[NSMutableArray alloc] initWithCapacity:3];
		
		pw = getpwuid( userId );
				
		if ( (procStat & SIDL) == SIDL )
			[procStats appendString:@"Process being created by fork "];
		if ( (procStat & SRUN) == SRUN )
			[procStats appendString:@"Currently runnable "];
		if ( (procStat & SSLEEP) == SSLEEP )
			[procStats appendString:@"Sleeping on an address "];
		if ( (procStat & SSTOP) == SSTOP )
			[procStats appendString:@"Process debugging or suspension "];
		if ( (procStat & SZOMB) == SZOMB )
			[procStats appendString:@"Awaiting collection by parent "];
	    
		if ( ([procStats length] == 0) && (procStat > 0) ) {
			[procStats appendString:@"Unknown state"];
		} else if ( [procStats length] == 0 ) {
			[procStats appendString:@"None available"];
		}
		
		if ( procFlag == 0 )
			goto ENDFLAGS;
		if ( (procFlag & P_ADVLOCK) == P_ADVLOCK )
			[procFlags addObject:@"Process may hold POSIX advisory lock"];
		if ( (procFlag & P_CONTROLT) == P_CONTROLT )
			[procFlags addObject:@"Process has a controlling terminal"];
		if ( (procFlag & P_NOCLDSTOP) == P_NOCLDSTOP )
			[procFlags addObject:@"No SIGCHLD when child(ren) stop"];
		if ( (procFlag & P_PPWAIT) == P_PPWAIT )
			[procFlags addObject:@"Parent waiting for child(ren) exec/exit"];
		if ( (procFlag & P_PROFIL) == P_PROFIL )
			[procFlags addObject:@"Process has started profiling"];
		if ( (procFlag & P_SELECT) == P_SELECT )
			[procFlags addObject:@"Selecting; wakeup/waiting danger"];
		if ( (procFlag & P_CONTINUED) == P_CONTINUED )
			[procFlags addObject:@"Process was stopped and continued"];
		if ( (procFlag & P_SUGID) == P_SUGID )
			[procFlags addObject:@"Process has set group id privileges"];
		if ( (procFlag & P_SYSTEM) == P_SYSTEM )
			[procFlags addObject:@"System process: no signals, stats, or swap"];
		if ( (procFlag & P_TIMEOUT) == P_TIMEOUT )
			[procFlags addObject:@"Process is timing out during sleep"];
		if ( (procFlag & P_TRACED) == P_TRACED )
			[procFlags addObject:@"Debugged process being traced"];
		if ( (procFlag & P_WEXIT) == P_WEXIT )
			[procFlags addObject:@"Process working on exit"];
		if ( (procFlag & P_EXEC) == P_EXEC )
			[procFlags addObject:@"Process called exec"];
		if ( (procFlag & P_OWEUPC) == P_OWEUPC )
			[procFlags addObject:@"Owe process an addupc() call at next ast."];
		if ( (procFlag & P_AFFINITY) == P_AFFINITY )
			[procFlags addObject:@"P_AFFINITY"];
		if ( (procFlag & P_TRANSLATED) == P_TRANSLATED )
			[procFlags addObject:@"P_TRANSLATED or P_CLASSIC"];
		if ( (procFlag & P_REBOOT) == P_REBOOT )
			[procFlags addObject:@"Process called reboot()"];
		if ( (procFlag & P_RESV6) == P_RESV6 )
			[procFlags addObject:@"Process is TBE"];
		if ( (procFlag & P_NOSHLIB) == P_NOSHLIB )
			[procFlags addObject:@"Process is not using shared libs"];
		if ( (procFlag & P_FORCEQUOTA) == P_FORCEQUOTA )
			[procFlags addObject:@"Forced quota for root"];
		if ( (procFlag & P_NOCLDWAIT) == P_NOCLDWAIT )
			[procFlags addObject:@"No zombies when child processes exit"];
		if ( (procFlag & P_NOREMOTEHANG) == P_NOREMOTEHANG )
			[procFlags addObject:@"No hang on remote filesystem operations"];
		
	ENDFLAGS:	
		if ( ([procFlags count] == 0) && procFlag > 0 ) {
			[procFlags addObject:@"Unknown flag"];
		} else if ( [procFlags count] == 0 ) {
			[procFlags addObject:@"No flags"];
		}
		
		if ( procName == nil ) {
			procName = [NSString stringWithUTF8String:(kp->kp_proc.p_comm)];
		}

		[returnDict setObject:procName forKey:@"ProcessName"];
		[returnDict setObject:[NSNumber numberWithInt:procPid] forKey:@"ProcessPIDNumber"];        
		[returnDict setObject:theDate forKey:@"ProcessStartTime"];
		[returnDict setObject:procFlags forKey:@"ProcessFlags"];
		[returnDict setObject:procStats forKey:@"ProcessStatus"];
		[returnDict setObject:[NSNumber numberWithInt:procPriority] forKey:@"ProcessSystemPriority"];
		[returnDict setObject:[NSNumber numberWithInt:procNice] forKey:@"ProcessNiceValue"];
		[returnDict setObject:[NSNumber numberWithInt:procParentPid] forKey:@"ProcessParentPID"];
		[returnDict setObject:[NSString stringWithUTF8String:(pw != NULL) ? pw->pw_name : "UNKNOWN USER"] forKey:@"ProcessOwner"];
		[returnDict setObject:[NSNumber numberWithUnsignedLong:procFlag] forKey:@"ProcessFlagValue"];
		[returnDict setObject:[NSNumber numberWithUnsignedLong:procStat] forKey:@"ProcessStatusValue"];
		
		[procFlags release];
		[procStats release];
    }
    
    free( kp );
    
    return [returnDict autorelease];
}

+(NSArray *)getProcessInfoByName:(NSString *)name{
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:1];
    char getProcName[255] = {0};
    struct kinfo_proc *kp;
    int mib[4], nentries, i;
    size_t bufSize = 0;
    
    strcpy( getProcName, [name UTF8String] );
	
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_ALL;
    mib[3] = 0;
	
    if ( sysctl(mib, 4, NULL, &bufSize, NULL, 0) < 0 ) {
        return [returnArray autorelease];
    }
    
    kp= (struct kinfo_proc *)malloc( bufSize );
    if ( kp == NULL ) {
		return [returnArray autorelease];
    }
    if ( sysctl(mib, 4, kp, &bufSize, NULL, 0) < 0 ) {
		free( kp );
		return [returnArray autorelease];
    }
	
    nentries = bufSize / sizeof(struct kinfo_proc);
	
    if ( nentries == 0 ) {
		free( kp );
		return [returnArray autorelease];
    }
    
	for ( i = nentries; --i >= 0; ) {
		NSAutoreleasePool *forPool = [[NSAutoreleasePool alloc] init];
		NSString *realProcName = [ProcViewController nameForProcessWithPID:(&kp[i])->kp_proc.p_pid];
		char *proc = ((&kp[i])->kp_proc.p_comm);
		if ( realProcName != nil ) {
			NSRange containsRange = [realProcName rangeOfString:name options:NSCaseInsensitiveSearch];
			
			if ( containsRange.location != NSNotFound ) {
				[returnArray addObject:[ProcViewController getProcessInfoByPID:(&kp[i])->kp_proc.p_pid]];
			}
		} else if ( strcasestr(proc, getProcName) != NULL ) {
			[returnArray addObject:[ProcViewController getProcessInfoByPID:(&kp[i])->kp_proc.p_pid]];
		}
		[forPool release];
    }
    
    free( kp );
    
    return [returnArray autorelease];
}

/* This returns the full process name, rather than the 16 char limit
 the p_comm field of the proc struct is limited to.
 
 Note that this only works if the process is running under the same
 user you are, or you are running this code as root.  If not, then
 the p_comm field is used (this function returns nil).
 */
+(NSString *)nameForProcessWithPID:(pid_t) pidNum{
    NSString *returnString = nil;
    int mib[4], maxarg = 0, numArgs = 0;
    size_t size = 0;
    char *args = NULL, *namePtr = NULL, *stringPtr = NULL;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_ARGMAX;
    
    size = sizeof(maxarg);
    if ( sysctl(mib, 2, &maxarg, &size, NULL, 0) == -1 ) {
		return nil;
    }
    
    args = (char *)malloc( maxarg );
    if ( args == NULL ) {
		return nil;
    }
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROCARGS2;
    mib[2] = pidNum;
    
    size = (size_t)maxarg;
    if ( sysctl(mib, 3, args, &size, NULL, 0) == -1 ) {
		free( args );
		return nil;
    }
    
    memcpy( &numArgs, args, sizeof(numArgs) );
    stringPtr = args + sizeof(numArgs);
    
    if ( (namePtr = strrchr(stringPtr, '/')) != NULL ) {
		*namePtr++;
		returnString = [[NSString alloc] initWithUTF8String:namePtr];
    } else {
		returnString = [[NSString alloc] initWithUTF8String:stringPtr];
    }
    
    return [returnString autorelease];
}

@end
