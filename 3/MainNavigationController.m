#import "MainNavigationController.h"
#import "Downloader.h"
#import "global.h"

@implementation MainNavigationController

@synthesize mainViewController = mainViewController_;

- (void) awakeFromNib {
	DNSLog( @"[MyNavigationController] awakeFromNib" );
}

- (void) dealloc {
	DNSLog( @"[MyNavigationController] dealloc" );
	[super dealloc];
}

@end
