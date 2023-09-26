//
//  DashedView.m
//  SpeakTime
//
//  Created by Vlad Alexa on 4/24/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import "DashedView.h"

#import <QuartzCore/QuartzCore.h>

@implementation DashedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{		
    float scale = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad) {
        scale = 1.5;
    }           
	float unit = self.bounds.size.width/24.0;
	float h = self.bounds.size.height;	
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path  = CGPathCreateMutable();
    int lat = -12;    
    for (int i = 0; i < 25; i++) {
        float step = i*unit;
        float halfunit = unit/2;
        float top;
        float bot;
        if (lat < 0) {
            top = 0-(lat*4);//top left increasing
            bot = h+(lat*4);
        }else {
            top = 0+(lat*4);//top right decreasing
            bot = h-(lat*4); 
        }                    
        if (i % 2 == 0) {            
            CGPathMoveToPoint(path, NULL,step-halfunit,bot);// jump to to bottom left         
            
            CGPathAddLineToPoint(path, NULL,step-halfunit,top); //top left              
            CGPathAddLineToPoint(path, NULL,step+halfunit,top); //top right        
            CGPathAddLineToPoint(path, NULL,step+halfunit,bot); //bottm right      
            CGPathAddLineToPoint(path, NULL,step-halfunit,bot); //bottom left	                        
        }        
        NSString *text = [NSString stringWithFormat:@"%i",lat];	
		if ([text isEqualToString:[NSString stringWithFormat:@"%i",self.tag]]) {
            CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor]); 
        }else {
            CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.0 alpha:1.0] CGColor]);             
        }
        int txtpad;
        if (lat > -1) txtpad = 2;        
        if (lat > 9) txtpad = 4;
        if (lat < 0) txtpad = 4;
        if (lat < -9) txtpad = 8;        
        [text drawInRect:CGRectMake(step-(txtpad*scale), top+(unit/5), unit, unit) withFont:[UIFont systemFontOfSize:8*scale]];         
        [text drawInRect:CGRectMake(step-(txtpad*scale), bot-unit, unit, unit) withFont:[UIFont systemFontOfSize:8*scale]];                 
        lat++;        
    }    
    CGPathCloseSubpath(path);
    
    
	const CGFloat BACKGROUND_OPACITY = 0.25;
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, path);
	CGContextFillPath(context);
    
	const CGFloat STROKE_OPACITY = 0.50;
	CGContextSetRGBStrokeColor(context, 0, 0, 0, STROKE_OPACITY);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	
	CGPathRelease(path);
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{ 
    UITouch *touch = [touches anyObject];
    if (touch) {
        CGPoint loc = [touch locationInView:self];
        float unit = self.bounds.size.width/24.0;                
        float tag = (loc.x/unit)-12.0;
        if (tag > 0) {
            [self setTag:tag+0.5];
        }else {
            [self setTag:tag-0.5];                       
        }
        [self setNeedsDisplay];
        [super touchesBegan:touches withEvent:event];           
    } 
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake ) {
        [self flipIt:self.layer direction:@"right"];
    }    
    //if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] ) [super motionEnded:motion withEvent:event];
}

- (BOOL)canBecomeFirstResponder{
    return YES; 
}

-(void) flipIt:(CALayer*)sender direction:(NSString*)direction{
	NSTimeInterval duration = 0.5;
	CAKeyframeAnimation *rotation = [CAKeyframeAnimation animation];
	if ([direction isEqualToString:@"left"]) {
		rotation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0f, 0.0f, 1.0f, 0.0f)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f)],nil];
	} else if ([direction isEqualToString:@"right"]) {
		rotation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0f, 0.0f, 1.0f, 0.0f)],nil];
	} else {
		//left and right
		rotation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0f, 0.0f, 1.0f, 0.0f)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI * 2, 0.0f, 1.0f, 0.0f)],nil];
		duration *= 2;
	}
	
	rotation.duration = duration;
	rotation.delegate = sender;	
	[sender addAnimation:rotation forKey:@"transform"];
	
}

-(void)rotateIt:(CALayer*)sender{
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.values = [NSArray arrayWithObjects:           // i.e., Rotation values for the 3 keyframes, in RADIANS
						[NSNumber numberWithFloat:0.0 * M_PI], 
						[NSNumber numberWithFloat:1.0 * M_PI], 
						[NSNumber numberWithFloat:2.0 * M_PI], nil]; 
	animation.keyTimes = [NSArray arrayWithObjects:     // Relative timing values for the 3 keyframes
						  [NSNumber numberWithFloat:0], 
						  [NSNumber numberWithFloat:.5], 
						  [NSNumber numberWithFloat:1.0], nil]; 
	animation.timingFunctions = [NSArray arrayWithObjects:
								 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],        // from keyframe 1 to keyframe 2
								 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil]; // from keyframe 2 to keyframe 3
	
	animation.removedOnCompletion = NO;	
	animation.fillMode = kCAFillModeForwards;	
	animation.duration = 2.5;
	animation.cumulative = YES;
	animation.repeatCount = 1;	
	[sender addAnimation:animation forKey:nil];
}

@end
