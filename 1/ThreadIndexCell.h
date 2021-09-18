
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <GraphicsServices/GraphicsServices.h>
#import "global.h"

@interface ThreadIndexCell : UIImageAndTextTableCell {
	float			height_;
	NSString*		escaped_title_;
}
- (void) dealloc;
- (float) height;
- (NSString*) title;
- (void) setDataWithDictionary:(NSDictionary*)dict;
- (id) setupBody:(NSDictionary*)dict;
- (id) setupInfo:(NSDictionary*)dict;
- (void) setHaveReadIcon:(NSDictionary*)dict;
@end
