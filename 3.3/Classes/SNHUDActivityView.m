#import "SNHUDActivityView.h"

@implementation SNHUDActivityView

#pragma mark Override

- (id) init {
	DNSLog( @"[SNHUDProgressView] - awakeFromNib" );
	UIImage *base =  [UIImage imageNamed:@"dialogue.png"];
	UIImage *newImage = [base stretchableImageWithLeftCapWidth:11.0 topCapHeight:11.0];
	self = [super initWithImage:newImage];
	if (self != nil) {
		// setup label
		label_ = [[UILabel alloc] initWithFrame:CGRectZero];
		label_.backgroundColor = [UIColor clearColor];
		UIFont *font = [UIFont boldSystemFontOfSize:24];
		label_.textColor = [UIColor whiteColor];
		label_.font = font;
		label_.textAlignment = UITextAlignmentCenter;
		label_.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		label_.lineBreakMode = UILineBreakModeCharacterWrap;
		label_.numberOfLines = 2;
		
		// setup activity view
		indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	}
	return self;
}

- (void) dealloc {
	[label_ release];
	[indicator_ release];
	[super dealloc];
}

#pragma mark Original

- (void) addCheck {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized( self ) {	
		UIImage *check_mark =  [UIImage imageNamed:@"WhiteCheck.png"];
		check_ = [[UIImageView alloc] initWithImage:check_mark];
		[indicator_ removeFromSuperview];
		
		[NSThread sleepForTimeInterval:0.25];
		CGRect animation_item_rect = check_.frame;
		animation_item_rect.origin.x = self.frame.size.width / 2 - animation_item_rect.size.width / 2 ;
		animation_item_rect.origin.y = 45 - animation_item_rect.size.height / 2 ;
		check_.frame = animation_item_rect;
		
		[self addSubview:check_];
		[check_ release];
	}
	[pool release];
	[NSThread exit];
}

- (void) setupWithMessage:(NSString*) msg {
	label_.text = msg;
	CGRect label_rect = [label_ textRectForBounds:CGRectMake( 0,0,220,60) limitedToNumberOfLines:2];
	
	// parent view's size depend on label size.
	CGRect self_rect = CGRectMake( 0, 0, label_rect.size.width + 20, 150 );
	
	CGRect animation_item_rect;
	
	[indicator_ removeFromSuperview];
	
	// sett up activity indicator
	animation_item_rect = indicator_.frame;
	animation_item_rect.origin.x = self_rect.size.width / 2 - animation_item_rect.size.width / 2 ;
	animation_item_rect.origin.y = 45 - animation_item_rect.size.height / 2 ;
	indicator_.frame = animation_item_rect;
	[self addSubview:indicator_];
	[indicator_ startAnimating];
	
	label_rect.origin.y = animation_item_rect.origin.y + animation_item_rect.size.height/2 + 26;
	label_rect.origin.x = self_rect.size.width / 2 - label_rect.size.width / 2 ;
	label_.frame = label_rect;
	
	self_rect.size.height = label_rect.origin.y +  + label_rect.size.height + 24;
	
	self.frame = self_rect;
	[self addSubview:label_];
}

- (BOOL) isShown {
	return (self.superview == nil);
}

- (BOOL) dismiss {
	int try_counter = 0;
	while( self.superview == nil ) {
		try_counter++;
		[NSThread sleepForTimeInterval:0.25];
		if( try_counter > 10 ) {
			DNSLog( @"closing time out" );
			return NO;
		}
	}
	[check_ removeFromSuperview];
	[self removeFromSuperview];
	return YES;
}

- (void) arrange:(CGRect)rect {
	CGRect superview_rect = rect;
	CGRect self_rect = self.frame;
	self_rect.origin.x = superview_rect.size.width /2 - self.frame.size.width /2;
	self_rect.origin.y = superview_rect.size.height /2 - self.frame.size.height /2;
	self.frame = self_rect;
}

@end
