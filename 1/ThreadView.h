#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface ThreadView : UIView {
	int					currentPage_;
	UINavigationItem*	naviTitle_;
	id					cellArray_;
	id					table_;

	int					response_num_;
}
- (void) doBookmark;
- (void) setupButton;
- (void) setupNavigationBar;
- (void) onPushGotoLast;
- (void) onPushAdd;
- (void) onPushReload;
- (void) onPushForward;
- (void) onPushBack;
- (void) releaseCache;
- (BOOL) reload;
- (BOOL) open;
@end
