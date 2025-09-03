#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Более надежный способ чтения настроек
static NSDictionary *getPreferences() {
    NSString *path = @"/var/mobile/Library/Preferences/com.greatlove.maxdestroyer.plist";
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    return settings;
}

%hook SpringBoard

// Правильный метод для перехвата запуска приложения
- (void)_launchApplication:(id)application withOptions:(id)options {
    %orig;
    
    // Получаем Bundle ID запускаемого приложения
    NSString *bundleID = [application bundleIdentifier];
    NSLog(@"[MaxDestroyer] Запускается приложение: %@", bundleID);
    
    // 1. Получаем настройки
    NSDictionary *settings = getPreferences();
    
    // 2. Проверяем, включен ли твик (по умолчанию - YES)
    BOOL tweakEnabled = settings[@"enabled"] ? [settings[@"enabled"] boolValue] : YES;
    if (!tweakEnabled) {
        NSLog(@"[MaxDestroyer] Твик отключен, пропускаем");
        return;
    }
    
    // 3. Получаем целевой Bundle ID из настроек (по умолчанию com.greatlove.maxdestroyer)
    NSString *targetBundleID = settings[@"targetBundleID"] ?: @"com.greatlove.maxdestroyer";
    
    if ([bundleID isEqualToString:targetBundleID]) {
        NSLog(@"[MaxDestroyer] Перехвачен запуск целевого приложения: %@", bundleID);
        
        // Даем приложению немного времени начать запуск
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // Показываем алерт
            NSString *alertTitle = settings[@"alertTitle"] ?: @"Не удалось открыть приложение";
            NSString *alertMessage = settings[@"alertMessage"] ?: @"Произошла критическая ошибка при инициализации приложения. Код ошибки: 0x80004005. Попробуйте переустановить приложение или обратитесь в службу поддержки.";
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                message:alertMessage
                preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // "Убиваем" приложение
                [[UIApplication sharedApplication] performSelector:@selector(suspend)];
                [NSThread sleepForTimeInterval:2.0];
                exit(0);
            }];

            [alert addAction:ok];
            
            // Показываем на главном экране
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
}

%end