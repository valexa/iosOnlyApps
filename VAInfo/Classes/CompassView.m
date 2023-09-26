//
//  CompassView.m
//  VAinfo
//
//  Created by Vlad Alexa on 6/19/10.
//  Copyright 2010 NextDesign. All rights reserved.
//

#import "CompassView.h"

@implementation CompassView

@synthesize magnif;

static CGPoint midPoint(CGRect r){
    return CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];    
    if (self) {
        // Initialization code			
        
		orientation = [UIDevice currentDevice].orientation;         
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
		
		[self addObserver:self forKeyPath:@"magnif" options:NSKeyValueObservingOptionOld context:NULL];	
		
		self.magnif = 1.0;
		
		self.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);		
		
		scale = ([[UIScreen mainScreen] bounds].size.width+[[UIScreen mainScreen] bounds].size.height)/10;
		if (scale < 100) scale = 100;
		float halfscale = scale/2;
		float decscale = scale/10;		
		
        // Add the backgound layer
        backgroundLayer = [[CALayer layer] retain];
        backgroundLayer.bounds = CGRectMake(0, 0, (scale*2)+10, (scale*2)+10);
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGFloat components[4] = {0.0, 0.0, 0.0, 0.25};
        CGColorRef cardBackColor = CGColorCreate(space,components);
        backgroundLayer.backgroundColor = cardBackColor;
        CGColorSpaceRelease(space);		
        CGColorRelease(cardBackColor);
        backgroundLayer.opaque = NO;
        backgroundLayer.cornerRadius = scale;		
        backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds));		
        [self.layer addSublayer:backgroundLayer];	
				
		//add compass layer		
		compass  = [[CALayer layer] retain];
		
		//add course sublayer
		course  = [[CALayer layer] retain];	
		
		speed = [[CATextLayer alloc] init];
		speed.foregroundColor = [UIColor orangeColor].CGColor;
		speed.bounds = CGRectMake(0, 0, halfscale, halfscale/2);
		speed.position = CGPointMake(decscale,-scale-(decscale*3));
		//speed.font = CGFontCreateWithFontName(CFSTR("Courier"));
		speed.fontSize = halfscale/2;
		[course addSublayer:speed];
		[speed release];	
		
		CAShapeLayer *courseArrow = [self courseArrow:[UIColor orangeColor]];		
		courseArrow.position = CGPointMake(0,-halfscale-15);				
		[course addSublayer:courseArrow];		
		
        course.position = midPoint(compass.bounds);		
		course.hidden = YES;		
        [compass addSublayer:course];		
		
		letter = [[CATextLayer alloc] init];
		letter.foregroundColor = [UIColor blackColor].CGColor;
		letter.bounds = CGRectMake(0, 0, halfscale/2, halfscale/2);
		letter.position = CGPointMake(decscale/3,-scale-decscale);
		//letter.font = CGFontCreateWithFontName(CFSTR("Courier"));
		letter.fontSize = halfscale/2;
		letter.string = @"N*";
		[compass addSublayer:letter];
		[letter release];		

		CAShapeLayer *leftNorth = [self halfSpade:[UIColor redColor]];
		leftNorth.position = CGPointMake(-decscale,-halfscale);
		[compass addSublayer:leftNorth];				

		CAShapeLayer *rightNorth = [self halfSpade:[UIColor blackColor]];		
		rightNorth.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
		rightNorth.position = CGPointMake(decscale,-halfscale);		
		[compass addSublayer:rightNorth];		
		
		CAShapeLayer *leftSouth = [self halfSpade:[UIColor blackColor]];		
		leftSouth.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
		leftSouth.position = CGPointMake(-decscale,halfscale);		
		[compass addSublayer:leftSouth];
		
		CAShapeLayer *rightSouth = [self halfSpade:[UIColor whiteColor]];		
		rightSouth.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
		rightSouth.position = CGPointMake(decscale,halfscale);
		[compass addSublayer:rightSouth];		
		 
		CAShapeLayer *topWest = [self halfSpade:[UIColor grayColor]];		
		topWest.transform = CATransform3DMakeRotation(M_PI, 1, 1, 0);
		topWest.position = CGPointMake(-halfscale,-decscale);		
		[compass addSublayer:topWest];	
		
		CAShapeLayer *bottomWest = [self halfSpade:[UIColor whiteColor]];		
		bottomWest.transform = CATransform3DRotate(CATransform3DMakeRotation(M_PI, 1, 1, 0),M_PI, 0, 1, 0);
		bottomWest.position = CGPointMake(-halfscale,decscale);				
		[compass addSublayer:bottomWest];		
	
		CAShapeLayer *topEast = [self halfSpade:[UIColor whiteColor]];		
		topEast.transform = CATransform3DRotate(CATransform3DMakeRotation(M_PI, 1, 1, 0),M_PI, 1, 0, 0);
		topEast.position = CGPointMake(halfscale,-decscale);		
		[compass addSublayer:topEast];	
		
		CAShapeLayer *bottomEast = [self halfSpade:[UIColor grayColor]];		
		bottomEast.transform =  CATransform3DRotate(CATransform3DRotate(CATransform3DMakeRotation(M_PI, 1, 1, 0),M_PI, 0, 1, 0),M_PI, 1, 0, 0);
		bottomEast.position = CGPointMake(halfscale,decscale);				
		[compass addSublayer:bottomEast];	 
		
        compass.position = midPoint(backgroundLayer.bounds);		
		compass.hidden = YES;		
        [backgroundLayer addSublayer:compass];
				
        // Recognize a tap gesture to cycle through the animations
        UITapGestureRecognizer* recognizeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [self addGestureRecognizer:recognizeTap];
        [recognizeTap release];		
		
		//apply magnif
		backgroundLayer.transform = CATransform3DMakeScale(magnif,magnif,1);	
		
		//move to corner
		backgroundLayer.position = [self bottomCornerPoint];
		
		//show message if not data available		
		msg = [[CATextLayer alloc] init];
		msg.foregroundColor = [UIColor whiteColor].CGColor;
		msg.bounds = CGRectMake(0, 0, (scale*2)-8, (scale*2)-8);
        msg.position = CGPointMake(CGRectGetMidX(backgroundLayer.bounds),CGRectGetMidY(backgroundLayer.bounds)+scale-decscale);			
		msg.fontSize = halfscale/3;
		msg.string = @"No heading/compass data";		
		[backgroundLayer addSublayer:msg];			
		
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {	
		backgroundLayer.transform = CATransform3DScale(backgroundLayer.transform,magnif,magnif,1);	
}

-(void) syncHeading:(CLHeading*)heading{	
	//NSLog(@"got: %f true: %f (x%f y%f z%f)", heading.magneticHeading,heading.trueHeading , heading.x , heading.y , heading.z);	
	[CATransaction setDisableActions:YES];
	if ([compass isHidden] && heading > 0) {
		compass.hidden = NO;
		[msg removeFromSuperlayer];
	}		
	compass.transform = CATransform3DMakeRotation(-heading.trueHeading*M_PI/180,0,0,1.0);
	letter.string = @"N";		
}

-(void)syncCourse:(CLLocation *)loc{
	//NSLog(@"Course is %f with %f",loc.course,loc.speed);    
	[CATransaction setDisableActions:YES];
	if ([course isHidden] && (loc.course > 0 || loc.speed > 0)) {
		course.hidden = NO;	
		compass.hidden = NO;		
		[msg removeFromSuperlayer];		
	}
	if (loc.course > 0) {
		course.transform = CATransform3DMakeRotation(loc.course*M_PI/180,0,0,1.0);	
	}
	if (loc.speed > 0) {		
		speed.string = [NSString stringWithFormat:@"%1.0f",loc.speed*3.6];				
	}			
}

-(CAShapeLayer*) courseArrow:(UIColor*)color
{    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    shape.bounds = CGRectMake(0, 0, (scale/10)*5.5, scale+15);
	float w = shape.bounds.size.width;
	float h = shape.bounds.size.height;	
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL,w/2,0);	//top
    CGPathAddLineToPoint(path, NULL,0,h); //bottom left
    CGPathAddLineToPoint(path, NULL,w,h); //bottm right	
	    
    CGPathCloseSubpath(path);
    
    shape.fillColor = color.CGColor;
    shape.strokeColor = [UIColor redColor].CGColor;
	shape.lineWidth = 2.0;
    shape.path  = path;
    CGPathRelease(path);
    
    return [shape autorelease];
}

-(CAShapeLayer*)halfSpade:(UIColor*)color
{    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    shape.bounds = CGRectMake(0, 0, (scale/10)*2, scale);
	float w = shape.bounds.size.width;
	float h = shape.bounds.size.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
	
    CGPathMoveToPoint(path, NULL,0,w*4); //left
    CGPathAddLineToPoint(path, NULL,w,0); //top
    CGPathAddLineToPoint(path, NULL,w,h); //bottom
   
    CGPathCloseSubpath(path);
        
    shape.fillColor = color.CGColor;
    shape.strokeColor = [UIColor blackColor].CGColor;
	shape.lineWidth = 1.0;
    shape.path = path;
    CGPathRelease(path);
    
    return [shape autorelease];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {  
	[compass release];
	[course release];
    [backgroundLayer release];	
    [super dealloc];     
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if ([backgroundLayer hitTest:point] != nil) {
		return self;
	}
    return nil;	
}

- (void) DeviceOrientationDidChange:(NSNotification *)notification{	
	UIDeviceOrientation orient = [UIDevice currentDevice].orientation;	
	if (orient != UIDeviceOrientationFaceUp && orient != UIDeviceOrientationFaceDown && orient != UIDeviceOrientationUnknown)	{
		//NSLog(@"DeviceOrientationDidChange");	
		orientation = orient;
		if (!maximized) {
			backgroundLayer.position = [self bottomCornerPoint];
		}		
	}
}

- (void)tapRecognized:(UIGestureRecognizer *)gestureRecognizer {	
	[CATransaction setAnimationDuration:0.5];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];	
	if (maximized) {
		backgroundLayer.position = [self bottomCornerPoint];
		backgroundLayer.transform = CATransform3DMakeScale(magnif,magnif,1);	
		maximized = NO;
	}else {
		backgroundLayer.position = midPoint(self.bounds);
		backgroundLayer.transform = CATransform3DMakeScale(magnif*10,magnif*10.0,1);				
		maximized = YES;
	}
}
 
-(CGPoint)bottomCornerPoint{
	//only valid in cases when the statusbar is visible and no iad is shown
	if (orientation == UIDeviceOrientationLandscapeLeft)	{
		return CGPointMake((scale*magnif)+10,self.bounds.size.height-((scale*magnif)+10));
	}	
	if (orientation == UIDeviceOrientationLandscapeRight)	{
		return CGPointMake(self.bounds.size.width-(scale*magnif)-10,((scale*magnif)+10));
	}	
	if (orientation == UIDeviceOrientationPortrait)	{
		return CGPointMake(self.bounds.size.width-((scale*magnif)+10),self.bounds.size.height-((scale*magnif)+10));
	} 	
	if (orientation == UIDeviceOrientationPortraitUpsideDown)	{
		return CGPointMake((scale*magnif)+10,(scale*magnif)+10);
	} 	
	if (orientation == UIDeviceOrientationUnknown)	{
        NSLog(@"Unknown orientation");
	} 	    
	if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown)	{
        NSLog(@"Horizontal orientation");
	} 	
	return midPoint(self.bounds);
}

@end
