#import "HistoryViewController.h"
#import "BaseBookmarkViewController.h"
#import "_tchAppDelegate.h"
#import "global.h"

@implementation HistoryViewController
- (IBAction)deleteAction:(id)sender {
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"HistoryViewDeletePrompt", @"")
															 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"HistoryViewDeleteButton0", @""), NSLocalizedString(@"HistoryViewDeleteButton1", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.destructiveButtonIndex = 0;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	_tchAppDelegate* app =(_tchAppDelegate*) [[UIApplication sharedApplication] delegate];
	return app.isAutorotateEnabled;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0) {
		DNSLog(@"ok");
	}
	else {
		DNSLog(@"cancel");
	}
}

- (void) viewDidLoad {
	DNSLog( @"[HistoryViewController] viewDidLoad" );
	self.title = NSLocalizedString(@"HistoryViewTitle", @"");
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
								   initWithTitle:NSLocalizedString(@"HistoryViewClose", @"")
								   style:UIBarButtonItemStyleBordered
								   target:self
								   action:@selector(closeAction:)] autorelease];
	self.navigationItem.rightBarButtonItem = addButton;
	deleteButton_.title = NSLocalizedString(@"HistoryViewDelete", @"");
}

- (IBAction) closeAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDismissBookmarkViewMsg object:self];
}

@end
