
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <GraphicsServices/GraphicsServices.h>
#import "invariables.h"

@interface ThreadCell : UIImageAndTextTableCell {
	float height_;
}
- (NSString*) divideStringAtAWidth:(NSString*)str;
- (float) height;
- (void) setDataWithDictionary:(NSDictionary*)dict;
@end
