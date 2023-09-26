
#import <UIKit/UIKit.h>


int main(int argc, char *argv[])
{
	
	if(getenv("NSZombieEnabled")) {
		NSLog(@"NSZombieEnabled enabled!!");
	}
	if(getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
		NSLog(@"NSAutoreleaseFreedObjectCheckEnabled enabled!!");
	}		
	if(getenv("NSTraceEvents")) {
		NSLog(@"NSTraceEvents enabled!!");
	}	
	if(getenv("MallocStackLogging")) {
		NSLog(@"MallocStackLogging enabled!!");
	}		
	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    [pool release];
    return retVal;
}
