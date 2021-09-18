#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ThreadTitleViewCell : UITableViewCell {
    IBOutlet UILabel *labelNumber_;
    IBOutlet UILabel *labelResNumber_;
    IBOutlet UILabel *labelResPrompt_;
    IBOutlet UILabel *labelTitle_;
    IBOutlet UITextView *fieldTitle_;
    IBOutlet UIImageView *cacheImg_;
}
@property (nonatomic, assign) NSString *threadTitle;
@property (nonatomic, assign) NSString *res;
@property (nonatomic, assign) NSString *number;
@property (nonatomic, assign) BOOL hiddenCacheImage;
- (NSString*) threadTitle;
- (void) setThreadTitle:(NSString*)newValue;
- (NSString*) res;
- (void) setRes:(NSString*)newValue;
- (void) setResNumberFontSize;
- (void) dealloc;
@end
