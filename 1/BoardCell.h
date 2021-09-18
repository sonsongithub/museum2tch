
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <GraphicsServices/GraphicsServices.h>
#import "global.h"

@interface BoardCell : UIImageAndTextTableCell {
	UITextLabel* title_label_;
	float height_;
}
- (float) height;
- (NSString*) title;
- (void) setTitle:(NSString*)title withURL:(NSString*)url;
@end
