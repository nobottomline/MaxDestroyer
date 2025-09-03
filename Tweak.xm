#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Более надежный способ чтения настроек
static NSDictionary *getPreferences() {
    NSString *path = @"/var/mobile/Library/Preferences/com.greatlove.maxdestroyer.plist";
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    return settings;
}

// Объявляем классы SpringBoard
@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
- (void)launch;
@end

@interface SpringBoard : UIApplication
- (void)applicationDidFinishLaunching:(id)application;
- (void)_launchApplication:(id)application withOptions:(id)options;
@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    NSLog(@"[MaxDestroyer] SpringBoard запущен, твик активирован");
}

// Перехватываем запуск приложения на уровне SpringBoard
- (void)_launchApplication:(id)application withOptions:(id)options {
    NSString *bundleID = [application bundleIdentifier];
    NSLog(@"[MaxDestroyer] SpringBoard пытается запустить приложение: %@", bundleID);
    
    // 1. Получаем настройки
    NSDictionary *settings = getPreferences();
    
    // 2. Проверяем, включен ли твик (по умолчанию - YES)
    BOOL tweakEnabled = settings[@"enabled"] ? [settings[@"enabled"] boolValue] : YES;
    if (!tweakEnabled) {
        NSLog(@"[MaxDestroyer] Твик отключен, пропускаем перехват");
        %orig;
        return;
    }
    
    // 3. Получаем целевой Bundle ID из настроек (по умолчанию com.greatlove.maxdestroyer)
    NSString *targetBundleID = settings[@"targetBundleID"] ?: @"com.greatlove.maxdestroyer";
    
    if ([bundleID isEqualToString:targetBundleID]) {
        NSLog(@"[MaxDestroyer] БЛОКИРУЕМ запуск целевого приложения: %@", bundleID);
        
        // Показываем алерт и НЕ запускаем приложение
        NSString *alertTitle = settings[@"alertTitle"] ?: @"Не удалось открыть приложение";
        NSString *alertMessage = settings[@"alertMessage"] ?: @"Произошла критическая ошибка при инициализации приложения. Код ошибки: 0x80004005. Попробуйте переустановить приложение или обратитесь в службу поддержки.";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
            message:alertMessage
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // Просто закрываем алерт
        }];

        [alert addAction:ok];
        
        // Показываем алерт на главном экране
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
        
        // ВАЖНО: НЕ ВЫЗЫВАЕМ %orig - приложение НЕ ЗАПУСКАЕТСЯ!
        return;
    }
    
    // Для всех остальных приложений - запускаем как обычно
    %orig;
}

%end