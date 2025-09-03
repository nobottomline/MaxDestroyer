#import <UIKit/UIKit.h>

@interface PSListController : UITableViewController
- (NSArray *)specifiers;
- (void)reloadSpecifiers;
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface MaxDestroyerPrefsRootListController : PSListController {
	NSArray *_specifiers;
}

@end
