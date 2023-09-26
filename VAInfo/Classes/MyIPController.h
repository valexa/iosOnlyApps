//
//  MyIPController.h
//  VAinfo
//
//  Created by Vlad Alexa on 3/30/09.
//  Copyright 2009 __VladAlexa__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MyIPControllerDelegate;

@interface MyIPController : NSObject {
	id <MyIPControllerDelegate> delegate;
	NSMutableData *receivedData;
	NSURLConnection *theConnection;	
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *theConnection;

- (id) initWithURL:(NSString *)theURL delegate:(id<MyIPControllerDelegate>)theDelegate;

@end


@protocol MyIPControllerDelegate<NSObject>

@required
- (void) connectionDidFinish:(MyIPController *)theConnection;

@optional
- (void) connectionDidFail:(MyIPController *)theConnection;

@end