
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface FavouriteCell : UIImageAndTextTableCell {
	id			delegate_;
	float		height_;
	NSString*	escapedTitle_;
}
- (float) height;
- (NSString*) escapedTitle;
- (void) setTitle:(NSString*)title withEscapedTitle:(NSString*)escapedTitle;
- (id) initWithDelegate:(id)delegate;
- (void) removeControlWillHideRemoveConfirmation:(id)fp8;
@end
