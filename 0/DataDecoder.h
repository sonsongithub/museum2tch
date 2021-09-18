#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIProgressHUD.h>
#import "invariables.h"

#define		JAPANESE_CHAR_CODE	27

@interface DataDecoder : NSObject {
	unsigned int*			codes_;
	NSMutableArray*			codeNames_;
}

// override
- (void) dealloc;
- (id) init;
// original method
- (NSString*)decodeNSData:(NSData*)data;
- (void) readyForDecoding;
#ifdef _DEBUG
- (void) readyForDecodingTypeString;
#endif
@end
