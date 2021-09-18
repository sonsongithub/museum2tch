//
//  ReplyViewController.m
//  composeView
//
//  Created by sonson on 08/12/04.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReplyViewController.h"

@implementation ScrollableTextView
@synthesize parentScrollView;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(parentScrollView)
		[parentScrollView touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if(parentScrollView)
		[parentScrollView touchesCancelled:touches withEvent:event];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(parentScrollView)
		[parentScrollView touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(parentScrollView)
		[parentScrollView touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end

@interface RulerView : UIView
@end

@implementation RulerView 
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 1.0, 1.0f, 1.0f, 1.0f);
	CGContextFillRect(context,CGRectMake(0, 0, rect.size.width, rect.size.height));
	CGContextSetRGBFillColor(context, 0.5,0.5,0.5, 1.0f);
	CGContextFillRect(context,CGRectMake(0, 44, rect.size.width,1));
	CGContextFillRect(context,CGRectMake(0, 88, rect.size.width,1));
}
@end


#define FIELD_HEIGHT		44
#define HORIZONTAL_MARGIN	5

@implementation ReplyViewController

#pragma mark Original

- (void)pushCloseButton:(id)sender {
	DNSLogMethod
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (NSString*)readFromCache {
	if( [[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath_] ) {
		NSData *data = [NSData dataWithContentsOfFile:cacheFilePath_];
		return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	}
	return nil;
}

- (void)prepareCache {
	cacheFilePath_ = [[NSString alloc] initWithFormat:@"%@/reply.cache", DocumentFolderPath];
}

- (void)saveReplayText:(NSString*)input {
	NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
	[[NSFileManager defaultManager] createFileAtPath:cacheFilePath_ contents:data attributes:nil];
}

- (void)clearCache {
	[self saveReplayText:@""];
}

#pragma mark Override

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		RulerView* ruler = [[RulerView alloc] initWithFrame:CGRectMake( 0, 0, 320, 400)];
		
		UIColor *grayColor = [UIColor colorWithRed:120.0f/255.0f green:120/255.0f blue:120/255.0f alpha:1.0f];
		scrollView_ = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, 320, 200 )];
		scrollView_.backgroundColor = [UIColor whiteColor];
		[scrollView_ addSubview:ruler];
		UILabel *name_prompt = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,FIELD_HEIGHT)];
		name_prompt.text = NSLocalizedString( @"Name:", nil );
		name_prompt.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		//name_prompt.textColor = [UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:1.0f];
		name_prompt.textColor = grayColor;
		CGRect name_prompt_rect = [name_prompt textRectForBounds:CGRectMake( 0, 0, 320, FIELD_HEIGHT) limitedToNumberOfLines:1];
		name_prompt.frame = CGRectMake( HORIZONTAL_MARGIN, 1, name_prompt_rect.size.width,FIELD_HEIGHT-2 );
		name_ = [[UITextField alloc] initWithFrame:CGRectMake( name_prompt_rect.size.width + HORIZONTAL_MARGIN*2,1,320- name_prompt_rect.size.width-2*HORIZONTAL_MARGIN,FIELD_HEIGHT)];
		name_.text = NSLocalizedString( @"", nil );
		name_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[scrollView_ addSubview:name_prompt];
		[name_prompt release];
		[scrollView_ addSubview:name_];
		
		UILabel *email_prompt = [[UILabel alloc] initWithFrame:CGRectMake(0,FIELD_HEIGHT,0,FIELD_HEIGHT)];
		email_prompt.text = NSLocalizedString( @"E-mail:", nil );
		CGRect email_prompt_rect = [email_prompt textRectForBounds:CGRectMake( 0, 0, 320, FIELD_HEIGHT) limitedToNumberOfLines:1];
		email_prompt.frame = CGRectMake( HORIZONTAL_MARGIN, FIELD_HEIGHT + 2, email_prompt_rect.size.width, FIELD_HEIGHT-2 );
		//email_prompt.textColor = [UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:1.0f];
		email_prompt.textColor = grayColor;
		email_ = [[UITextField alloc] initWithFrame:CGRectMake(email_prompt_rect.size.width + HORIZONTAL_MARGIN*2,FIELD_HEIGHT+1,320-email_prompt_rect.size.width-2*HORIZONTAL_MARGIN,FIELD_HEIGHT)];
		email_.text = NSLocalizedString( @"sage", nil );
		email_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[scrollView_ addSubview:email_prompt];
		[email_prompt release];
		[scrollView_ addSubview:email_];
				
		body_ = [[ScrollableTextView alloc] initWithFrame:CGRectMake( 0, 93, 320, 480 )];
		body_.parentScrollView = scrollView_;
		body_.scrollEnabled = NO;
		body_.font = email_.font;
		[scrollView_ addSubview:body_];
		[self.view addSubview:scrollView_];
		body_.delegate = self;
		[scrollView_ setContentSize:CGSizeMake(320, 200)];
	
		scrollView_.scrollEnabled = YES;
		
		UIBarButtonItem*	closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString( @"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(pushCloseButton:)];
		self.navigationItem.leftBarButtonItem = closeButton;
		[closeButton release];
		[self prepareCache];
		body_.text = [self readFromCache];
    }
	
	DNSLogMethod
	[self dismissModalViewControllerAnimated:YES];
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[body_ becomeFirstResponder];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
	DNSLogMethod
	[scrollView_ setContentSize:CGSizeMake(320, 5 + 44 + 44 + textView.contentSize.height)];
//	[scrollView scrollRectToVisible:textView.frame animated:YES];
//	[textView sizeToFit];
	CGSize textSize = [textView.text sizeWithFont:textView.font constrainedToSize:textView.contentSize lineBreakMode:UILineBreakModeWordWrap];
	[textView scrollRectToVisible:CGRectMake( 0, 0, textSize.width, textSize.height) animated:YES];
	[self saveReplayText:textView.text];
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[cacheFilePath_ release];
	[name_ release];
	[email_ release];
	[scrollView_ release];
    [super dealloc];
}


@end
