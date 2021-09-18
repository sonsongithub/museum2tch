#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface CategoryView : UIView {
	id cells_;
	id table_;
}
- (void) rebuildCells;
@end
