#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface ThreadIndexView : UIView {
	id					table_;
	id					urlArray_;
	id					cellArray_;
	int					currentPage_;
	UINavigationItem*	naviTitle_;
	int					thread_num_;
}
- (BOOL) reloadCellArrays;
- (void) setupButton;
- (void) onPushReload;
- (void) onPushForward;
- (void) onPushBack;
- (void) releaseCache;
- (BOOL) open;
- (BOOL) reload;
@end
