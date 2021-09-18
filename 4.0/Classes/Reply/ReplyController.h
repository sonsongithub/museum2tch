//
//  ReplyController.h
//  2tch
//
//  Created by sonson on 08/08/30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Ch2ThreadPostSuccess,
    Ch2ThreadPostWarning,
    Ch2ThreadPostError,
    Ch2ThreadPostCheck,
    Ch2ThreadPostCheckCookie,
    Ch2ThreadPostClientError,
} Ch2ThreadPostResult;

@class ReplyViewController;

@interface ReplyController : NSObject <UIAlertViewDelegate> {
	UIAlertView				*cookieConfirm_;
	UIAlertView				*failedConfirm_;
	UIAlertView				*successConfirm_;
	
	NSString				*server_;
	NSString				*boardPath_;
	NSString				*dat_;
	
	NSString				*result_body_;
	
	NSString				*name_;
	NSString				*email_;
	NSString				*body_;
	
	ReplyViewController		*delegate_;
}
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *boardPath;
@property (nonatomic, retain) NSString *dat;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, assign) ReplyViewController *delegate;

#pragma mark Class method
+ (ReplyController*) defaultController;
#pragma mark Original method
- (void) send;
- (id) URLOfBoard;
- (NSMutableString*) defaultCGIParameterStringWithName:(NSString*)name mail:(NSString*)mail body:(NSString*)body;
- (NSMutableURLRequest*) defaultRequest;
- (NSMutableString*) cookieStringToSend;
- (int) postWithName:(NSString*)name mail:(NSString*)mail body:(NSString*)body;
- (Ch2ThreadPostResult) extractReply2ch_X_String:(NSString*) string;
- (NSString*) extractReplyBodyString:(NSString*) string;
- (void) afterCookieConfirmAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
