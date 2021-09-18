#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "invariables.h"

@interface ThreadView : UIView {
	id					textView_;
	id					thread_data_;
	int					currentPage_;
	UINavigationItem*	naviTitle_;
	id					cellArray_;
	id					table_;
}
// override
- (void) dealloc;
- (id)initWithFrame:(CGRect)frame;
// UINavigationbar's delegate
- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button;
// UITable's delegate
- (BOOL)table:(UITable *)aTable canSelectRow:(int)row;
- (int)numberOfRowsInTable:(UITable*)table;
- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(int)col;
- (float) table:(UITable *)table heightForRow:(int)row;
- (void)tableRowSelected:(NSNotification*)notification;
// original method
- (void) reload;
- (void) forward;
- (void) back;
- (void) releaseCache;
- (void) redrawText;
- (BOOL) reload:(NSString*)url;

@end
