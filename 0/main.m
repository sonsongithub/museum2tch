#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "invariables.h"
#import "MyApp.h"

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int ret = UIApplicationMain(argc, argv, [MyApp class]);
	[pool release];
	return ret;
}
