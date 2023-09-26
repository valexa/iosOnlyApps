//
//  CompassView.h
//  VAinfo
//
//  Created by Vlad Alexa on 6/19/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@interface CompassView : UIView {
    CALayer* backgroundLayer;
	CALayer *compass;
	CALayer *course;
	CATextLayer* speed;
	CATextLayer* letter;
	CATextLayer *msg;
	float scale;
	float magnif;
	BOOL maximized;
	UIDeviceOrientation orientation;
}

@property (nonatomic, assign) float magnif;

-(CAShapeLayer*) courseArrow:(UIColor*)color;
-(CAShapeLayer*)halfSpade:(UIColor*)color;
-(void) syncHeading:(CLHeading*)heading;
-(void)syncCourse:(CLLocation *)loc;
- (void)tapRecognized:(UIGestureRecognizer *)gestureRecognizer;
-(CGPoint)bottomCornerPoint;
@end
