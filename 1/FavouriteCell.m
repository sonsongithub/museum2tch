
#import "FavouriteCell.h"
#import "FavouriteView.h"
#import "global.h"

@implementation FavouriteCell

- (void) dealloc {
	[escapedTitle_ release];
	[super dealloc];
}

- (float) height {
	return height_;
}

- (NSString*) escapedTitle {
	return escapedTitle_;
}

- (void) setTitle:(NSString*)title withEscapedTitle:(NSString*)escapedTitle {
	// make body label
	float body_size = [UIApp threadIndexSize];
	UITextLabel*body_label = [[[UITextLabel alloc] initWithFrame:CGRectMake( 5, 27, 310, 60)] autorelease];
	[body_label setWrapsText:YES];
	
	// set Font
	GSFontRef bodyFont = GSFontCreateWithName( FIXEDPITCH_FONT_NAME, kGSFontTraitBold, body_size );
	[body_label setFont:bodyFont];
	CFRelease(bodyFont);
	
	// save unescape title
	escapedTitle_ = [[NSString stringWithString:escapedTitle] retain];
	
	float left_margin = 10.0f;
	float width_label = 265.0f;
	float default_height_margin = 6.0f;
	
	// set
	[body_label setText:divideStringWithWidthAndFontSize( title, width_label, [UIApp threadIndexSize])];
	[body_label sizeToFit];
	
	// set background color
	float transparentomponents[4] = {1, 1, 1, 0};
	[body_label setBackgroundColor: CGColorCreate( CGColorSpaceCreateDeviceRGB(), transparentomponents)];
	[self addSubview:body_label];
	
	CGRect rect_body = [body_label bounds];
	
	float height_margin = rect_body.size.height + default_height_margin * 2 < 60 ? ( 60 - rect_body.size.height ) * 0.5 : default_height_margin;
	rect_body.origin.x = left_margin;
	rect_body.origin.y = height_margin;
	[body_label setFrame:rect_body];
	height_ = rect_body.size.height + 2 * height_margin;
}

- (id) initWithDelegate:(id)delegate {
	self = [super init];
	delegate_ = delegate;
	return self;
}

- (void) removeControlWillHideRemoveConfirmation:(id)fp8 {
	[ self _showDeleteOrInsertion:NO
		  withDisclosure:NO
		  animated:YES
		  isDelete:YES
		  andRemoveConfirmation:YES
	];
}

- (void) _willBeDeleted {
	DNSLog( @"wilBeDeleted" );
	[(FavouriteView*)delegate_ delete:self];
}

@end
