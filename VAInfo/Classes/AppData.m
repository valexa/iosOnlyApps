//
//  AppData.m
//  VAinfo
//
//  Created by Vlad Alexa on 3/30/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//

#import "AppData.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#include <sys/sysctl.h>  
#include <mach/mach.h>

#include <sys/param.h>
#include <sys/mount.h>

#import <sys/utsname.h>
#include <unistd.h>
#include <mach-o/arch.h>

/*
 Name                            Type          Changeable
 kern.ostype                     string        no
 kern.osrelease                  string        no
 kern.osrevision                 integer       no
 kern.version                    string        no
 kern.maxvnodes                  integer       yes
 kern.maxproc                    integer       yes
 kern.maxfiles                   integer       yes
 kern.argmax                     integer       no
 kern.securelevel                integer       raise only
 kern.hostname                   string        yes
 kern.hostid                     integer       yes
 kern.clockrate                  struct        no
 kern.posix1version              integer       no
 kern.ngroups                    integer       no
 kern.job_control                integer       no
 kern.saved_ids                  integer       no
 kern.link_max                   integer       no
 kern.max_canon                  integer       no 
 kern.max_input                  integer       no
 kern.name_max                   integer       no
 kern.path_max                   integer       no
 kern.pipe_buf                   integer       no
 kern.chown_restricted           integer       no
 kern.no_trunc                   integer       no
 kern.vdisable                   integer       no
 kern.boottime                   struct        no
 vm.loadavg                      struct        no
 vm.swapusage                    struct        no
 machdep.console_device          dev_t         no
 net.inet.ip.forwarding          integer       yes
 net.inet.ip.redirect            integer       yes
 net.inet.ip.ttl                 integer       yes
 net.inet.icmp.maskrepl          integer       yes
 net.inet.udp.checksum           integer       yes
 hw.machine                      string        no
 hw.model                        string        no
 hw.ncpu                         integer       no
 hw.byteorder                    integer       no
 hw.physmem                      integer       no
 hw.usermem                      integer       no
 hw.memsize                      integer       no
 hw.pagesize                     integer       no
 user.cs_path                    string        no
 user.bc_base_max                integer       no
 user.bc_dim_max                 integer       no
 user.bc_scale_max               integer       no
 user.bc_string_max              integer       no
 user.coll_weights_max           integer       no
 user.expr_nest_max              integer       no
 user.line_max                   integer       no
 user.re_dup_max                 integer       no
 user.posix2_version             integer       no
 user.posix2_c_bind              integer       no
 user.posix2_c_dev               integer       no
 user.posix2_char_term           integer       no
 user.posix2_fort_dev            integer       no
 user.posix2_fort_run            integer       no
 user.posix2_localedef           integer       no
 user.posix2_sw_dev              integer       no
 user.posix2_upe                 integer       no 
*/ 

time_t boottime_big()
{
	int mib[2] = { CTL_KERN, KERN_BOOTTIME };
	struct timeval boottime;
	size_t size = sizeof(boottime);
	
	if (sysctl(mib, 2, &boottime, &size, NULL, 0) == -1) {
		perror("KERN_BOOTTIME");
		return -1;
	}
	//printf("system boot time (seconds since epoch): %d",boottime.tv_sec);
	return boottime.tv_sec;
}

time_t boottime()
{
	struct timeval boottime;
	unsigned long length = sizeof(boottime);
	if (sysctlbyname("kern.boottime", &boottime, &length,NULL, 0) == -1){
		perror("sysctl(kern.boottime)");
		return -1;
	}		
	return boottime.tv_sec;	
}

struct clockinfo cpu_clockinfo(){	
	size_t len;
	struct clockinfo clock;	
	len = sizeof(struct clockinfo);
	if (sysctlbyname("kern.clockrate", &clock, &len, NULL, 0) == -1){
		perror("sysctl(kern.clockrate)");
	}
	return clock;	
}

uint64_t int64sysctl(const char *what){  
	uint64_t ret;
	unsigned long length = sizeof(ret);
	if (sysctlbyname(what, &ret, &length,NULL, 0) == -1){
		 NSLog(@"int64sysctl err on %s",what);
		return 0;
	}		
	return ret;	
}

int intsysctl(const char *what){
	int ret;
	unsigned long length = sizeof(ret);
	if (sysctlbyname(what, &ret, &length,NULL, 0) == -1){
		 NSLog(@"intsysctl err on %s",what);
		return 0;
	}		
	return ret;	
}

struct xsw_usage swap_usage(){
	size_t len;
	struct xsw_usage ret;
	len = sizeof(struct xsw_usage);	
	if (sysctlbyname("vm.swapusage", &ret, &len,NULL, 0) == -1){
		perror("sysctl(vm.swapusage)");
	}		
	return ret;	
}

struct loadavg load_avg(){
	size_t len;
	struct loadavg ret;
	len = sizeof(struct loadavg);	
	if (sysctlbyname("vm.loadavg", &ret, &len,NULL, 0) == -1){
		perror("sysctl(vm.loadavg)");
	}		
	return ret;	
}

@implementation AppData


+ (NSMutableDictionary*)getData{
	
	//struct xsw_usage swap = swap_usage();
	//NSLog(@"Swap free %iMB used %iMB total %iMB",swap.xsu_avail*swap.xsu_pagesize,swap.xsu_used*swap.xsu_pagesize,swap.xsu_total*swap.xsu_pagesize);		
	
	//struct clockinfo clock = cpu_clockinfo();
	//NSLog(@"[Clock info] freq: %i, tick: %i, skew: %i, stat freq: %i, prof freq: %i",clock.hz,clock.tick,clock.tickadj,clock.stathz,clock.profhz);
	
	//get cpu stats
    struct loadavg load = load_avg();	
    NSString *cpuLoadAvg = [NSString stringWithFormat:@"%1.2f %1.2f %1.2f",load.ldavg[0]/(float)load.fscale,load.ldavg[1]/(float)load.fscale,load.ldavg[2]/(float)load.fscale];		  
	NSString *cpuLoad = [NSString stringWithFormat:@"%1.1f%%",load.ldavg[1]/(float)load.fscale*100];
    
	float freq = int64sysctl("hw.cpufrequency")/1000000000.0;
	NSString *cpuFrequency = @"N/A";	
	if (freq > 0) cpuFrequency = [NSString stringWithFormat:@"%1.1f GHz",freq];
    
    uint64_t bus = int64sysctl("hw.busfrequency")/1000000;
	NSString *busFrequency = @"N/A";
    if (bus > 0) busFrequency = [NSString stringWithFormat:@"%lli MHz",bus];
    
	NSString *l1cache = [NSString stringWithFormat:@"%i k",(int)int64sysctl("hw.l1icachesize")/1000];
	NSString *l2cache = [NSString stringWithFormat:@"%i k",(int)int64sysctl("hw.l2cachesize")/1000];			
	NSString *cacheSize = [NSString stringWithFormat:@"%@/%@",l1cache,l2cache];		
		
	//get boot time
	NSDate *bootdate = [NSDate dateWithTimeIntervalSince1970:boottime()];
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	NSString *uptime_string = [AppData uptimeFromInterval:now-boottime()];
    
	//get cpu family
    int cpu_fam = intsysctl("hw.cpufamily");
	NSString *cpuFam = @"N/A"; 
	if (cpu_fam ==  CPUFAMILY_ARM_9) cpuFam = @"ARM 9";
	if (cpu_fam ==  CPUFAMILY_ARM_11) cpuFam = @"ARM 11";
	if (cpu_fam ==  CPUFAMILY_ARM_12) cpuFam = @"ARM 12";
	if (cpu_fam ==  CPUFAMILY_ARM_13) cpuFam = @"ARM 13";
	if (cpu_fam ==  CPUFAMILY_ARM_14) cpuFam = @"ARM 14";
	if (cpu_fam ==  CPUFAMILY_ARM_XSCALE) cpuFam = @"ARM XSCALE";
    if (cpu_fam ==  CPUFAMILY_ARM_SWIFT) cpuFam = @"ARM SWIFT";
	if (cpu_fam ==  CPUFAMILY_INTEL_WESTMERE) cpuFam = @"Intel Westmere";
	if (cpu_fam ==  CPUFAMILY_INTEL_SANDYBRIDGE) cpuFam = @"Intel SandyBridge";
    if (cpu_fam ==  CPUFAMILY_INTEL_IVYBRIDGE) cpuFam = @"Intel IvyBridge";
    
    //get cpu subtype
    cpu_subtype_t cpu_sub = intsysctl("hw.cpusubtype");
	NSString *cpuSub = @"";
    if (cpu_sub ==  CPU_SUBTYPE_ARM_V7) cpuSub = @"(Cortex A8)";    
    if (cpu_sub ==  CPU_SUBTYPE_ARM_V7F) cpuSub = @"(Cortex A9)";
    if (cpu_sub ==  CPU_SUBTYPE_ARM_V7S) cpuSub = @"(Swift)";
    if (cpu_sub ==  CPU_SUBTYPE_ARM_V7K) cpuSub = @"(Kirkwood40)";
	
	//get sysname
	struct utsname u;
	uname(&u);	
	NSString *darwin = [NSString stringWithFormat:@"%s (%s)",u.sysname,u.release];
	NSString *system_detail = [NSString stringWithFormat:@"%s",u.version];		
	NSArray *firstSplit = [system_detail componentsSeparatedByString:@";"];
	NSString *kernel = @"N/A";
	NSString *build = @"N/A";
	NSString *buildDate = @"N/A";	
	if ([firstSplit count] == 2) {
		NSString *versionAndDate = [firstSplit objectAtIndex:0];
		NSArray *secondSplit = [versionAndDate componentsSeparatedByString:@":"];	
		if ([secondSplit count] == 4) {
			buildDate = [NSString stringWithFormat:@"%@:%@:%@",[secondSplit objectAtIndex:1],[secondSplit objectAtIndex:2],[secondSplit objectAtIndex:3]];			
		}		
		NSString *kernelAndPlatform = [firstSplit objectAtIndex:1];	
		NSArray *thirdSplit = [kernelAndPlatform componentsSeparatedByString:@"/"];	
		if ([thirdSplit count] == 2) {			
			kernel = [[thirdSplit objectAtIndex:0] substringFromIndex:6];
			build = [thirdSplit objectAtIndex:1];			
		}
	}else {
		NSLog(@"Error splitting sysdetail");
	}
	
	NSString *networkNode = [NSString stringWithFormat:@"%s",u.nodename];	
	
	char *login = getlogin();
	//int gid = getgid();
	//int uid = getuid();
	NSString *userGU = [NSString stringWithFormat:@"%s",login];	
	
	long sc_proco = sysconf(_SC_NPROCESSORS_ONLN); //The number of processors currently online.
	long sc_procc = sysconf(_SC_NPROCESSORS_CONF); //The number of processors configured.	
	NSString *cpuCores = [NSString stringWithFormat:@"%ld/%ld",sc_proco,sc_procc];
	
	long sc_child = sysconf(_SC_CHILD_MAX); //The maximum number of simultaneous processes per user id.
	long sc_of = sysconf(_SC_OPEN_MAX); //The maximum number of open files per user id.		
	long sc_os = sysconf(_SC_STREAM_MAX); //The minimum maximum number of streams that a process may have open at any one time.	
	NSString *maxCFS = [NSString stringWithFormat:@"%ld/%ld/%ld",sc_child,sc_of,sc_os];		
	
	//long sc_mapped = sysconf(_SC_MAPPED_FILES);
	//long sc_pagesize = sysconf(_SC_PAGESIZE);	
	//NSLog(@"%@",[NSString stringWithFormat:@"mapped:%d psize:%d",sc_mapped,sc_pagesize]);	
	
	//const NXArchInfo *archInfo = NXGetAllArchInfos();		
	//NSString *cpu = [NSString stringWithFormat:@"%s/%s (%i %i)",archInfo->name,archInfo->description,archInfo->cputype,archInfo->cpusubtype];
	//NSLog(@"%@",cpu);	
	
	//int PID = getpid();		
	//NSString *pid = [NSString stringWithFormat:@"%d",PID];
	//NSLog(@"PID is %@",pid);	
	
	//get battery data
	[UIDevice currentDevice].batteryMonitoringEnabled = YES;
	NSString *state = @""; 	
	if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) state = @"charging";	
	float batt = [UIDevice currentDevice].batteryLevel;
	NSString *battPerc = [NSString stringWithFormat:@"%1.0f%% %@",batt*100,state];
			
	//get network data	
	NSString *network = [self testByName:false];
	
	//CFShow([self getAddress]);
	//CFShow([[NSHost currentHost] addresses]);

	NSString *ipadd;	
	NSDictionary *myhost =[self newgetAddress];
	if ([myhost objectForKey:@"en0"]){
		ipadd = [myhost objectForKey:@"en0"];
	}else{
		ipadd = @"N/A";		
	}
	NSString *cipadd;	
	if ([myhost objectForKey:@"pdp_ip0"]){
		cipadd = [myhost objectForKey:@"pdp_ip0"];
	}else{
		cipadd = @"N/A";		
	}	
	
	//get AppleLocale
	//NSString *locale = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLocale"];
	//get locale data
	//NSString *curLoc = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];		
	
	/*
	 //show defaults
	 NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/.GlobalPreferences.plist"];  
	 NSDictionary *dataRow = [NSDictionary dictionaryWithContentsOfFile:path];  
	 CFShow(dataRow); 
	 */
	
	NSMutableDictionary *dataRows = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
							  uptime_string,@"Uptime",
							  battPerc,@"Battery",
 							  [self getFreeDiskSpace],@"Free Space",
    						  [self getAvailableMemory],@"Free Memory",									 
							  [[UIDevice currentDevice].identifierForVendor UUIDString],@"Device ID",
							  [NSString stringWithFormat:@"%@/%@", [UIDevice currentDevice].name,[UIDevice currentDevice].model],@"Name/Type",
							  [NSString stringWithFormat:@"%s/%@", u.machine,[AppData getMachineType]],@"Model/Code",                                     
							  [NSString stringWithFormat:@"%@ (%@)", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion],@"Operating System",						  						  
							  cpuLoad,@"CPU",									 
							  darwin,@"Name",
							  network,@"Network",		
							  ipadd,@"IP (private)",	
							  cipadd,@"Carrier IP",	
							  kernel,@"Kernel",
							  build,@"Build",
 							  buildDate,@"Build Date",									 
							  [NSString stringWithFormat:@"%@.local",networkNode],@"Node",
							  userGU,@"User Name",
							  maxCFS,@"Max Childs/Files/Streams",
							  [bootdate description],@"Boot Date",
							  cpuCores,@"Cores (active/total)",									 
							  [NSString stringWithFormat:@"%@ %@",cpuFam,cpuSub],@"Family",
							  cpuFrequency,@"Frequency",
							  busFrequency,@"Bus",									 
							  cacheSize,@"Cache (L1/L2)",
							  cpuLoadAvg,@"Load average",									 
							  nil];
	
	 //CFShow(dataRows); 
	
	/*	
	 //print dictionary
	 id mykey;
	 NSEnumerator *enumerator = [dataRows keyEnumerator];
	 while ((mykey = [enumerator nextObject])) {
	 NSLog(@"%@ : %@", mykey, [dataRows objectForKey:mykey]);
	 }
	*/
	
	return dataRows;	

}


+ (NSString*)testByName:(BOOL)byName
{
    SCNetworkReachabilityFlags  flags;
    SCNetworkReachabilityRef    reachabilityRef;
    BOOL                        gotFlags;
	NSMutableString *str;
	
	if (byName) {
        reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [@"www.apple.com" UTF8String]);
    } else {
        struct sockaddr_in  addr;
		memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port   = htons(80);
        addr.sin_addr.s_addr = inet_addr("17.149.160.49");
        reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr *) &addr);
    }
    gotFlags        = SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
    CFRelease(reachabilityRef);
	
    if (gotFlags) {
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {			
            str = [NSMutableString stringWithFormat:@"Non Wi-Fi"];			
        } else if (flags & kSCNetworkReachabilityFlagsReachable) {
            str = [NSMutableString stringWithFormat:@"Wi-Fi"];
        } else {
            str = [NSMutableString stringWithFormat:@"None"];
			NSLog(@"Connection Flags %#x", flags);	
			return str;
        }
		if (flags & kSCNetworkReachabilityFlagsIsDirect) {
			CFShow(str);
			[str appendString:@" (direct)"];
		}else{
			[str appendString:@" (gateway)"];
		}		
    } else {
        str = [NSMutableString stringWithFormat:@"N/A"];
    }
	return str;
}

+ (NSDictionary*)newgetAddress{	
	
#if ! defined(IFT_ETHER)
#define IFT_ETHER 0x6/* Ethernet CSMACD */
#endif
	
	NSMutableDictionary *ifaddrs = [[[NSMutableDictionary alloc] init] autorelease];	
	BOOL                  success;
	struct ifaddrs           * addrs;
	const struct ifaddrs     * cursor;
	
	success = getifaddrs(&addrs) == 0;
	if (success) {
		cursor = addrs;
		while (cursor != NULL) {
			if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
			{
				NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                [ifaddrs setObject:addr forKey:name];				
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	return ifaddrs;
}

+ (NSString*)getFreeDiskSpace
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0){
		struct statfs tStats;
		NSString *sizeType = @"N/A";		
		statfs([[paths lastObject] cString], &tStats);	
		
		float availableSpace = (float)(tStats.f_bavail * tStats.f_bsize);
		float totalSpace = (float)(tStats.f_blocks * tStats.f_bsize);
		int percent = availableSpace/totalSpace*100;	
		
		if (availableSpace  >= 1073741824)
		{
			availableSpace = availableSpace / 1073741824; sizeType = @"GB";
		}
		if (availableSpace >= 1048576)
		{
			availableSpace = availableSpace / 1048576; sizeType = @"MB";
		}
		if (availableSpace >= 1024)
		{
			availableSpace = availableSpace / 1024; sizeType = @"KB";
		}
		
		return [NSString stringWithFormat:@"%.1f %@ (%i%%) of %.1f GB",availableSpace,sizeType,percent,totalSpace/1073741824];		
	}
	return @"N/A";
}

+ (NSString*)getAvailableMemory
{
	float total = int64sysctl("hw.memsize")/1048576.0;
	float used = int64sysctl("hw.usermem")/1048576.0;
    float avail = total - used;
	
	int percent = avail / total * 100;
    
    return [NSString stringWithFormat:@"%.1f MB (%i%%) of %.1f MB",avail,percent,total];
}

+(NSString*)uptimeFromInterval:(double)time{
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

+ (NSString *)getMachineType{
    NSString * modelString  = nil;
    int        modelInfo[2] = { CTL_HW, HW_MODEL };
    size_t     modelSize;
    
    if (sysctl(modelInfo,2,NULL,&modelSize, NULL, 0) == 0) {
        void * modelData = malloc(modelSize);
        
        if (modelData) {
            if (sysctl(modelInfo,2,modelData,&modelSize,NULL, 0) == 0) {
                modelString = [NSString stringWithUTF8String:modelData];
            }            
            free(modelData);
        }
    }
    NSCharacterSet *charset = [[NSCharacterSet letterCharacterSet] invertedSet];
    return [modelString stringByTrimmingCharactersInSet:charset];
}

@end


