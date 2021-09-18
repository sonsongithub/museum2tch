#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SNHUDActivityView : UIImageView {
	UILabel					*label_;
	UIActivityIndicatorView *indicator_;
	UIImageView				*check_;
}
#pragma mark Override
- (id) init;
- (void) dealloc;
#pragma mark Original
- (void) addCheck;
- (void) setupWithMessage:(NSString*) msg;
- (BOOL) dismiss;
- (void) arrange:(CGRect)rect;
@end
