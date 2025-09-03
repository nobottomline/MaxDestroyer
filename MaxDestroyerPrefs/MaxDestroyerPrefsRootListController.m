#import "MaxDestroyerPrefsRootListController.h"

@implementation MaxDestroyerPrefsRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Добавляем кнопку "Apply" в навигационную панель
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] 
        initWithTitle:@"Apply" 
        style:UIBarButtonItemStylePlain 
        target:self 
        action:@selector(applySettings)];
    self.navigationItem.rightBarButtonItem = applyButton;
}

- (void)applySettings {
    // Показываем алерт о необходимости respring
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"Настройки применены" 
        message:@"Для применения изменений необходимо выполнить respring." 
        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction 
        actionWithTitle:@"OK" 
        style:UIAlertActionStyleDefault 
        handler:nil];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openGitHub {
    NSURL *url = [NSURL URLWithString:@"https://github.com/GreatLove"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)openTwitter {
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/GreatLove"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
