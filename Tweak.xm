#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Более надежный способ чтения настроек
static NSDictionary *getPreferences() {
    NSString *path = @"/var/mobile/Library/Preferences/com.greatlove.maximdestroyer.plist";
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    return settings;
}

// Функция для показа алерта
static void showErrorAlert(NSString *bundleID) {
    NSDictionary *settings = getPreferences();
    NSString *alertTitle = settings[@"alertTitle"] ?: @"Не удалось открыть приложение";
    NSString *alertMessage = settings[@"alertMessage"] ?: @"Произошла критическая ошибка при инициализации приложения. Код ошибки: 0x80004005. Попробуйте переустановить приложение или обратитесь в службу поддержки.";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
        message:alertMessage
        preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        if (@available(iOS 13.0, *)) {
            NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
            for (UIScene *scene in connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    keyWindow = windowScene.windows.firstObject;
                    break;
                }
            }
        } else {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            keyWindow = [UIApplication sharedApplication].keyWindow;
            #pragma clang diagnostic pop
        }
        
        if (keyWindow && keyWindow.rootViewController) {
            [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

// Объявляем классы SpringBoard
@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
- (void)launch;
@end

@interface SpringBoard : UIApplication
- (void)applicationDidFinishLaunching:(id)application;
- (void)_launchApplication:(id)application withOptions:(id)options;
- (void)launchApplication:(id)application;
- (void)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    NSLog(@"[MaxDestroyer] SpringBoard запущен, твик активирован");
}

// Метод 1: _launchApplication:withOptions:
- (void)_launchApplication:(id)application withOptions:(id)options {
    NSString *bundleID = [application bundleIdentifier];
    NSLog(@"[MaxDestroyer] Метод 1: _launchApplication:withOptions: для %@", bundleID);
    
    NSDictionary *settings = getPreferences();
    BOOL tweakEnabled = settings[@"enabled"] ? [settings[@"enabled"] boolValue] : YES;
    NSString *targetBundleID = settings[@"targetBundleID"] ?: @"com.greatlove.maxdestroyer";
    
    if (tweakEnabled && [bundleID isEqualToString:targetBundleID]) {
        NSLog(@"[MaxDestroyer] БЛОКИРУЕМ через метод 1: %@", bundleID);
        showErrorAlert(bundleID);
        return; // НЕ запускаем
    }
    
    %orig;
}

// Метод 2: launchApplication:
- (void)launchApplication:(id)application {
    NSString *bundleID = [application bundleIdentifier];
    NSLog(@"[MaxDestroyer] Метод 2: launchApplication: для %@", bundleID);
    
    NSDictionary *settings = getPreferences();
    BOOL tweakEnabled = settings[@"enabled"] ? [settings[@"enabled"] boolValue] : YES;
    NSString *targetBundleID = settings[@"targetBundleID"] ?: @"com.greatlove.maxdestroyer";
    
    if (tweakEnabled && [bundleID isEqualToString:targetBundleID]) {
        NSLog(@"[MaxDestroyer] БЛОКИРУЕМ через метод 2: %@", bundleID);
        showErrorAlert(bundleID);
        return; // НЕ запускаем
    }
    
    %orig;
}

// Метод 3: launchApplicationWithIdentifier:suspended:
- (void)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended {
    NSLog(@"[MaxDestroyer] Метод 3: launchApplicationWithIdentifier: %@", identifier);
    
    NSDictionary *settings = getPreferences();
    BOOL tweakEnabled = settings[@"enabled"] ? [settings[@"enabled"] boolValue] : YES;
    NSString *targetBundleID = settings[@"targetBundleID"] ?: @"com.greatlove.maxdestroyer";
    
    if (tweakEnabled && [identifier isEqualToString:targetBundleID]) {
        NSLog(@"[MaxDestroyer] БЛОКИРУЕМ через метод 3: %@", identifier);
        showErrorAlert(identifier);
        return; // НЕ запускаем
    }
    
    %orig;
}

%end

%hook SBApplication

- (void)launch {
    NSString *bundleID = [self bundleIdentifier];
    NSLog(@"[MaxDestroyer] Метод 4: SBApplication launch для %@", bundleID);
    
    NSDictionary *settings = getPreferences();
    BOOL tweakEnabled = settings[@"enabled"] ? [settings[@"enabled"] boolValue] : YES;
    NSString *targetBundleID = settings[@"targetBundleID"] ?: @"com.greatlove.maxdestroyer";
    
    if (tweakEnabled && [bundleID isEqualToString:targetBundleID]) {
        NSLog(@"[MaxDestroyer] БЛОКИРУЕМ через метод 4: %@", bundleID);
        showErrorAlert(bundleID);
        return; // НЕ запускаем
    }
    
    %orig;
}

%end