//
//  DatHTMLManager.h
//  2tch
//
//  Created by sonson on 08/11/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DatHTMLManager : NSObject {

}
+ (NSString*) makeAnchorHTMLStringWithResNumberArray:(NSArray*)resNumberList resList:(NSMutableArray*)resList;
+ (NSString*)htmlNewModeFrom:(int)from to:(int)to path:(NSString*)path dat:(int)dat resList:(NSMutableArray*)resList;
+ (NSString*)makeDataFrom:(int)from to:(int)to path:(NSString*)path dat:(int)dat resList:(NSMutableArray*)resList isNewCommingTag:(BOOL)isNewCommingTag;
+ (NSString*)makeCacheFrom:(int)from to:(int)to path:(NSString*)path dat:(int)dat resList:(NSMutableArray*)resList;
+ (NSString*)htmlFrom:(int)from to:(int)to path:(NSString*)path dat:(int)dat resList:(NSMutableArray*)resList;
@end
