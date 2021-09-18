//
//  PopupMenuController.m
//  paging
//
//  Created by sonson on 08/09/03.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#define CELL_WIDTH		120
#define CELL_HEIGHT		36
#define CELL_HEIGHT_TIP	48

#import "PopupMenuController.h"
#import "ThreadViewController.h"
#import <QuartzCore/QuartzCore.h>

UIImage* normalBackImage = nil;
UIImage* selectedBackImage = nil;

UIImage* normalHeadBackImage = nil;
UIImage* selectedHeadBackImage = nil;

UIImage* normalTailBackImage = nil;
UIImage* selectedTailBackImage = nil;

@implementation PopupMenuCell
@synthesize delegate = delegate_;
@synthesize number = number_;
@synthesize label = label_;

+ (UIImage*) normalImage {
	if( normalBackImage == nil ) {
		UIImage *img =  [UIImage imageNamed:@"middleNormalPopup.png"];
		normalBackImage = [img stretchableImageWithLeftCapWidth:10 topCapHeight:2];
		[normalBackImage retain];	}
	return normalBackImage;
}

+ (UIImage*) selectedImage {
	if( selectedBackImage == nil ) {
		UIImage *img =  [UIImage imageNamed:@"middleSelectedPopup.png"];
		selectedBackImage = [img stretchableImageWithLeftCapWidth:10 topCapHeight:2];
		[selectedBackImage retain];
	}
	return selectedBackImage;
}

+ (UIImage*) normalHeadImage {
	if( normalHeadBackImage == nil ) {
		UIImage *img =  [UIImage imageNamed:@"headNormalPopup.png"];
		normalHeadBackImage = [img stretchableImageWithLeftCapWidth:15 topCapHeight:19];
		[normalHeadBackImage retain];
	}
	return normalHeadBackImage;
}

+ (UIImage*) selectedHeadImage {
	if( selectedHeadBackImage == nil ) {
		UIImage *img =  [UIImage imageNamed:@"headSelectedPopup.png"];
		selectedHeadBackImage = [img stretchableImageWithLeftCapWidth:15 topCapHeight:19];
		[selectedHeadBackImage retain];
	}
	return selectedHeadBackImage;
}

+ (UIImage*) normalTailImage {
	if( normalTailBackImage == nil ) {
		UIImage *img =  [UIImage imageNamed:@"tailNormalPopup.png"];
		normalTailBackImage = [img stretchableImageWithLeftCapWidth:15 topCapHeight:19];
		[normalTailBackImage retain];
	}
	return normalTailBackImage;
}

+ (UIImage*) selectedTailImage {
	if( selectedTailBackImage == nil ) {
		UIImage *img =  [UIImage imageNamed:@"tailSelectedPopup.png"];
		selectedTailBackImage = [img stretchableImageWithLeftCapWidth:15 topCapHeight:19];
		[selectedTailBackImage retain];
	}
	return selectedTailBackImage;
}

- (id) initWithFrame:(CGRect)rect mode:(int)mode {
	UIImage* normalImg = nil;
	UIImage* selectedImg = nil;
	
	if( mode == 0 ) {
		normalImg = [PopupMenuCell normalHeadImage];
		selectedImg = [PopupMenuCell selectedHeadImage];
	}
	else if( mode == 1 ) {
		normalImg = [PopupMenuCell normalImage];
		selectedImg = [PopupMenuCell selectedImage];
	}
	else if( mode == 2 ) {
		normalImg = [PopupMenuCell normalTailImage];
		selectedImg = [PopupMenuCell selectedTailImage];
	}
	
	self = [super initWithFrame:rect];
	self.backgroundColor = [UIColor clearColor];
	background_ = [[UIImageView alloc] initWithImage:normalImg];
	backgroundSelected_ = [[UIImageView alloc] initWithImage:selectedImg];
	CGRect backImage = rect;
	backImage.origin = CGPointMake(0,0);
	background_.frame = backImage;
	backgroundSelected_.frame = backImage;
	background_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	backgroundSelected_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[self addSubview:backgroundSelected_];
	[self addSubview:background_];
	
	CGRect labelRect = rect;
	if( mode == 0 ) {
		labelRect.origin = CGPointMake( 0, 5);
	}
	else if( mode == 1 ) {
		labelRect.origin = CGPointMake( 0, 0);
	}
	else if( mode == 2 ) {
		labelRect.origin = CGPointMake( 0, -5);
	}
	label_ = [[UILabel alloc] initWithFrame:labelRect];
	label_.backgroundColor = [UIColor clearColor];
	label_.textAlignment = UITextAlignmentCenter;
	label_.font = [UIFont boldSystemFontOfSize:16.0f];
	
	label_.textColor = [UIColor whiteColor];
	label_.shadowColor = [UIColor blackColor];
	[self addSubview:label_];
	[label_ release];
	
	background_.hidden = NO;
	backgroundSelected_.hidden = YES;
	
	
	return self;
}

- (void) setSelected:(BOOL)selected {
	if( selected ) {
		background_.hidden = YES;
		backgroundSelected_.hidden = NO;
	}
	else {
		background_.hidden = NO;
		backgroundSelected_.hidden = YES;
	}
}

- (void) dealloc {
	[background_ release];
	[backgroundSelected_ release];
	[super dealloc];
}

@end

@implementation PopupMenuController

@synthesize numberOfRes = res_;
@synthesize numberOfCell = numberOfCell_;
@synthesize label = label_;
@synthesize cells = cells_;
@synthesize mainView = mainView_;
@synthesize delegate = delegate_;
@synthesize segmentControl = segmentControl_;

#define RES_PER_PAGE 200

+ (PopupMenuController*) defaultControllerOfRes:(int)res new200:(BOOL)new200 {
	PopupMenuController* obj = [[PopupMenuController alloc] initWithNibName:nil bundle:nil];
	PopupMenuCell *cell = nil;
	obj.view.backgroundColor = [UIColor clearColor];
	obj.view.frame = CGRectMake( 0, 0, 95, 44);
	obj.numberOfCell = res / 200 + 1;
	
	if( res == 1001 )
		obj.numberOfCell--;
	
	NSArray* segments = [[NSArray alloc] initWithObjects:@"", nil];
	obj.segmentControl = [[UISegmentedControl alloc] initWithItems:segments];
	obj.segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segments release];
	
	obj.segmentControl.userInteractionEnabled = NO;
	obj.segmentControl.frame = CGRectMake( -7 , 7, 107, 30 );
	[obj.view addSubview:obj.segmentControl];
	[obj.segmentControl release];
	
	obj.label = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, obj.view.frame.size.width, 42)];
	obj.label.backgroundColor = [UIColor clearColor];
	obj.label.textAlignment = UITextAlignmentCenter;
	obj.label.font = [UIFont boldSystemFontOfSize:12.0f];
	obj.label.textColor = [UIColor whiteColor];
	obj.label.shadowColor = [UIColor blackColor];
	[obj.view addSubview:obj.label];
	[obj.label release];
	
	obj.numberOfRes = res;

	obj.mainView = [[UIView alloc] initWithFrame:CGRectMake( ( obj.view.frame.size.width - CELL_WIDTH ) / 2, 0, CELL_WIDTH+1, CELL_HEIGHT * obj.numberOfCell + CELL_HEIGHT_TIP * 2 )];	
	obj.mainView.backgroundColor = [UIColor clearColor];
	obj.cells = [[NSMutableArray array] retain];
	
	float height = 0;
	
	int i=0;
	cell = [[PopupMenuCell alloc] initWithFrame:CGRectMake( 0, height, CELL_WIDTH, CELL_HEIGHT_TIP) mode:0];
	height += CELL_HEIGHT_TIP;
	cell.number = [obj.cells count];
	
	if( new200 )
		cell.label.text = NSLocalizedString( @"NewComming200", nil );
	else
		cell.label.text = NSLocalizedString( @"NewComming", nil );
	
	[obj.cells addObject:cell];
	[cell release];
	
	cell = [[PopupMenuCell alloc] initWithFrame:CGRectMake( 0, height, CELL_WIDTH, CELL_HEIGHT) mode:1];
	height += CELL_HEIGHT;
	cell.number = [obj.cells count];
	cell.label.text = NSLocalizedString( @"All", nil );
	[obj.cells addObject:cell];
	[cell release];
	
	for( i=0; i < obj.numberOfCell; i++ ) {
		PopupMenuCell* cell = nil;
		if( i == obj.numberOfCell -1 )
			cell = [[PopupMenuCell alloc] initWithFrame:CGRectMake( 0, height, CELL_WIDTH, CELL_HEIGHT_TIP) mode:2];
		else
			cell = [[PopupMenuCell alloc] initWithFrame:CGRectMake( 0, height, CELL_WIDTH, CELL_HEIGHT) mode:1];
		cell.number = [obj.cells count];
		
		height += CELL_HEIGHT;
		
		if( i != obj.numberOfCell-1)
			cell.label.text = [NSString stringWithFormat:@"%d - %d", i*200 +1, (i+1)*200];
		else
			cell.label.text = [NSString stringWithFormat:@"%d - %d", i*200 +1, res];
		[obj.cells addObject:cell];
		[cell release];
	}
	
	cell = [obj.cells objectAtIndex:0];
	obj.label.text = [NSString stringWithFormat:@"%@ / %d", cell.label.text, res];
	
	return obj;
}

- (void) setMainTitleWithCellNumber:(int) num {
	PopupMenuCell* cell = [cells_ objectAtIndex:num];
	label_.text = [NSString stringWithFormat:@"%@ / %d", cell.label.text, res_];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.view addSubview:self.mainView];
	segmentControl_.selectedSegmentIndex = 0;

	CGRect defaultRect = self.mainView.frame;
	defaultRect.origin.y = -defaultRect.size.height + 10;
	self.mainView.frame = defaultRect;
	
	for( id obj in self.cells ) {
		[self.mainView addSubview:obj];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	UIView* view = [self.mainView hitTest:[touch locationInView:self.mainView] withEvent:nil];
	
	int index_y = [cells_ indexOfObject:view];
	
	if( index_y != selected_ ) {
		if( selected_ >= 0 && selected_ < [cells_ count] )
			[[cells_ objectAtIndex:selected_] setSelected:NO];
		if( index_y >= 0 && index_y < [cells_ count] )
			[[cells_ objectAtIndex:index_y] setSelected:YES];
		selected_ = index_y;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[mainView_ removeFromSuperview];
	segmentControl_.selectedSegmentIndex = UISegmentedControlNoSegment;
	if( selected_ != NSNotFound ) {
		NSLog( @"clicked - %d", selected_ );
		[(ThreadViewController*)delegate_ changeDisplayMode:selected_];
	}
	else
		NSLog( @"no selected" );
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[mainView_ release];
	[cells_ release];
    [super dealloc];
}

@end
