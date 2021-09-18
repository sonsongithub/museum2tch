#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface BoardView : UIView {
	id cells_;
	id table_;
	UINavigationItem*	naviTitle_;
}
- (void) rebuildCells;
- (void) reload;
@end