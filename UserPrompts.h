//
//  UserPrompts.h
//  VTrace
//
//  Created by Vlad Alexa on 6/26/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <Foundation/Foundation.h>

//import PaymentsObserver , change theID

@protocol UserPromptsDelegate;

@interface UserPrompts : NSObject {
	NSUserDefaults *defaults;
	int appID;
}

@property (nonatomic, assign) id<UserPromptsDelegate> delegate;
@property (nonatomic, assign) int appID;

- (id) initWithAppID:(int)theID delegate:(id<UserPromptsDelegate>)theDelegate;

-(void)incrementRunCount;

- (void)askForReview:(int)count;
- (void)askForPurchase:(int)count;

@end


@protocol UserPromptsDelegate<NSObject>

@required
- (void) adsButtonPressed;

@end