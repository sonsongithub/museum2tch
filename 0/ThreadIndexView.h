#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "invariables.h"

@interface ThreadIndexView : UIView {
	id					table_;
	id					urlArray_;
	id					cellArray_;
	id					baseUrl_;
	int					currentPage_;
	UINavigationItem*	naviTitle_;
	id					threads_;
}
// override
- (id)initWithFrame:(CGRect)frame withMainControllerId:(id)mainController;
// UINavigationbar's delegate
- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button;
// UITable's delegate
- (BOOL)table:(UITable *)aTable canSelectRow:(int)row;
- (int)numberOfRowsInTable:(UITable*)table;
- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(int)col;
- (void)tableRowSelected:(NSNotification*)notification;
// original method
- (void) reload;
- (void) forward;
- (void) back;
- (void) rebuildCellsWithThreadsData;
- (void) releaseCache;
- (BOOL) reload:(NSString*)url;
@end
