#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "ReplyViewCellName.h"
#import "ReplyViewCellEmail.h"
#import "ReplyViewCellBody.h"

typedef enum {
    Ch2ThreadPostSuccess,
    Ch2ThreadPostWarning,
    Ch2ThreadPostError,
    Ch2ThreadPostCheck,
    Ch2ThreadPostCheckCookie,
    Ch2ThreadPostClientError,
} Ch2ThreadPostResult;

@interface ReplyViewController : UIViewController {
    IBOutlet UIBarButtonItem *closeButton_;
    IBOutlet UIBarButtonItem *sendButton_;
    IBOutlet UINavigationController *replyNavController_;
    IBOutlet UITableView *tableView_;

	UITextField *name_;
	UITextField *email_;
	UITextView *body_;
	
	NSString* sharedPon_;
	
	NSMutableDictionary* resultHTMLDict_;
	float	bodyHeight_;
	
	NSString	*server_;
	NSString	*boardPath_;
	NSString	*dat_;
	
	NSString	*result_body_;
	
	UIAlertView *cookieConfirm_;
	
	ReplyViewCellName* nameCell_;
	ReplyViewCellEmail* emailCell_;
	ReplyViewCellBody* bodyCell_;
	
}
@property (nonatomic, assign) NSString	*server;
@property (nonatomic, assign) NSString	*boardPath;
@property (nonatomic, assign) NSString	*dat;

- (NSString*) URLdecode;
- (NSString*) URLencode;
- (NSString*) URLdecodeNew;
- (NSString*) URLencodeNew;
- (NSString*) descriptionInRFC1123;
- (void) dealloc;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
//- (void) setServer:(NSString*)server boardPath:(NSString*)boardPath dat:(NSString*)dat;
- (IBAction)clear:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)send:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)textViewDidChange:(UITextView *)textView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) clearCookie;
- (void)viewWillAppear:(BOOL)animated;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void) clearCookie;
- (void) doReply;
/*
 - (void) alertSheetDidEnd: (NSAlert*) alert
 returnCode: (int) returnCode
 contextInfo: (void*) contextInfo;
 */
- (id) URLOfBoard;
- (int) postWithName: (NSString*) name mail: (NSString*) mail body: (NSString*) body;
- (id) parseCookie:(NSString*)str;
- (Ch2ThreadPostResult) extractReply2ch_X_String:(NSString*) string;
- (NSString*) extractReplyBodyString:(NSString*) string;
@end
