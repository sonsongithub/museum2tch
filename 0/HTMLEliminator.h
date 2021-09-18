
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIProgressHUD.h>
#import "invariables.h"

@interface HTMLEliminator : NSObject {
	NSDictionary*	specialTags_;
	NSDictionary*	specialChars_;
}
// override method
- (void) dealloc;
- (id) init;
// original method
- (void) convertHTMLTag:(NSMutableString*)str;
- (void) convertSpecialChar:(NSMutableString*)str;
- (void) eliminateHTMLTag:(NSMutableString*)str;
- (NSString*) eliminate:(NSString*)inputStr;
- (void) makeConvertEliminateDataTable;
@end
