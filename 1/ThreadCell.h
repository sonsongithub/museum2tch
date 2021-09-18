
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <GraphicsServices/GraphicsServices.h>
#import "global.h"

@interface ThreadCell : UIImageAndTextTableCell {
	float			height_;
}
- (float) height;
- (void) setDataWithDictionary:(NSDictionary*)dict;
- (float) setupBody:(NSDictionary*)dict;
- (float) setupInfo:(NSDictionary*)dict;
@end
