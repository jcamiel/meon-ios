//
//  CustomUISwitch.m
//
//  Created by Duane Homick
//  Homick Enterprises - www.homick.com
//

#import "CustomUISwitch.h"

#define SWITCH_DISPLAY_WIDTH		100.0
#define SWITCH_WIDTH				144.0
#define SWITCH_HEIGHT				33.0

#define RECT_FOR_OFF		CGRectMake(-43.0, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)
#define RECT_FOR_ON			CGRectMake(0.0, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)
#define RECT_FOR_HALFWAY	CGRectMake(0, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)

@interface CustomUISwitch ()
@property (nonatomic, strong, readwrite) UIImageView* backgroundImage;
@property (nonatomic, strong, readwrite) UIImageView* switchImage;
- (void)setupUserInterface;
- (void)toggle;
- (void)animateSwitch:(BOOL)toOn;


@end


@implementation CustomUISwitch {
    BOOL _on;
    NSInteger _hitCount;
}
@synthesize backgroundImage = _backgroundImage;
@synthesize switchImage = _switchImage;
@synthesize delegate = _delegate;

/**
 * Destructor
 */

/** 
 * Constructor
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	if (self){
		_on = YES;
		_hitCount = 0;
		
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = YES;
		self.autoresizesSubviews = NO;
		self.autoresizingMask = 0;
		self.opaque = YES;
		
		[self setupUserInterface];
	}
	return self;
}


- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, SWITCH_DISPLAY_WIDTH, SWITCH_HEIGHT)];
	
    if (self){
		_on = YES;
		_hitCount = 0;

		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = YES;
		self.autoresizesSubviews = NO;
		self.autoresizingMask = 0;
		self.opaque = YES;
		
		[self setupUserInterface];
    }
    return self;
}


/**
 * Setup the user interface
 */
- (void)setupUserInterface
{
	// Background image
	UIImageView* bg = [[UIImageView alloc] initWithFrame:RECT_FOR_ON];
	bg.image = [UIImage imageNamed:@"Common/switch_on.png"];
	bg.backgroundColor = [UIColor clearColor];
	bg.contentMode = UIViewContentModeLeft;
	self.backgroundImage = bg;
	
	// Switch image
	UIImageView* foreground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, SWITCH_WIDTH, SWITCH_HEIGHT)];
	foreground.image = [UIImage imageNamed:@"Common/switch.png"];
	foreground.contentMode = UIViewContentModeLeft;
	self.switchImage = foreground;

	// Check for user input
	[self addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	[self addSubview:self.backgroundImage];
	[self.backgroundImage addSubview:self.switchImage];
}

/**
 * Drawing Code
 */
- (void)drawRect:(CGRect)rect 
{
	// nothing
}

/**
 * Configure it into a certain state
 */
- (void)setOn:(BOOL)on animated:(BOOL)animated
{
	if (on)
	{
		self.switchImage.frame = RECT_FOR_ON;
		self.backgroundImage.image = [UIImage imageNamed:@"Common/switch_on.png"];
	}
	else
	{
		self.switchImage.frame = RECT_FOR_OFF;
		self.backgroundImage.image = [UIImage imageNamed:@"Common/switch_off.png"];
	}
	_on = on;
}

/**
 * Check if on
 */
- (BOOL)isOn
{
	return _on;
}

/**
 * Capture user input
 */
- (void)buttonPressed:(id)target
{
	// We use a hit count to properly queue up multiple hits on the button while we are animating.
	if (_hitCount == 0)
	{
		_hitCount++;
		[self toggle];
	}
	else
	{
		_hitCount++;
		// Do not animate, this will happen when other animation finishes
	}
}

/**
 * Toggle ison
 */
- (void)toggle
{
	_on = !_on;
	[self animateSwitch:_on];
}

/**
 * Animate the switch by sliding halfway and then changing the background image and then sliding the rest of the way.
 */
- (void)animateSwitch:(BOOL)toOn
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];

	self.switchImage.frame = RECT_FOR_HALFWAY;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationHasFinished:finished:context:)];

	if (toOn)
	{
		self.switchImage.frame = RECT_FOR_ON;
		self.backgroundImage.image = [UIImage imageNamed:@"Common/switch_on.png"];
	}
	else
	{
		self.switchImage.frame = RECT_FOR_OFF;
		self.backgroundImage.image = [UIImage imageNamed:@"Common/switch_off.png"];
	}
	[UIView commitAnimations];
	
	[UIView commitAnimations];
}

/**
 * Remove the view no longer visible
 */
- (void)animationHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	if (_delegate)
	{
		[_delegate valueChangedInView:self];
	}
	
	// We use a hit count to properly queue up multiple hits on the button while we are animating.
	if (_hitCount > 1)
	{
		_hitCount--;
		[self toggle];
	}
	else
	{
		_hitCount--;
	}
}

@end