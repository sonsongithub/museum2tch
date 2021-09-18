#import "BaseBookmarkViewController.h"
#import "_tchAppDelegate.h"
#import "global.h"

NSString *kDismissBookmarkViewMsg = @"dismissBookmark";

@implementation BaseBookmarkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		DNSLog(@"[BaseBookmarkViewController] initWithNibName");
		[[NSNotificationCenter defaultCenter] addObserver:self 
				   selector:@selector(dismissBookmark:)
					   name:kDismissBookmarkViewMsg
					 object:nil];
	}
	return self;
}

- (void) awakeFromNib {
	DNSLog(@"[BaseBookmarkViewController] awakeFromNib");
}

- (void) viewDidLoad {
	DNSLog(@"[BaseBookmarkViewController] viewDidLoad");
	self.view = [bookmarkNavController_ view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	return app.isAutorotateEnabled;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

#pragma mark original method

- (void) dismissBookmark:(NSNotification *)notification {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
