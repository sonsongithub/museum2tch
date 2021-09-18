
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "ThreadView.h"

@interface FavouriteThreadView : ThreadView /*UIView*/ {
}
- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button;
- (void) setupButton;
@end
