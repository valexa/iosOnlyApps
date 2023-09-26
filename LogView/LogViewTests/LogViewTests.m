//
//  LogViewTests.m
//  LogViewTests
//
//  Created by Vlad Alexa on 1/16/13.
//  Copyright (c) 2013 Vlad Alexa. All rights reserved.
//

#import "LogViewTests.h"

@implementation LogViewTests

- (void)setUp
{
    [super setUp];
    
    appDelegate  = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testWindow
{
    STAssertNotNil(appDelegate, @"Application delegate is nil");
    STAssertNotNil(appDelegate.window, @"Application window is nil");
}

@end
