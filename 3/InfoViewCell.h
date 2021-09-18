#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface InfoViewCell : UITableViewCell {
    IBOutlet UILabel		*attrLabel_;
    IBOutlet UILabel		*titleLabel_;
}
@property (nonatomic, assign) UILabel *attr;
@property (nonatomic, assign) UILabel *title;
@end
