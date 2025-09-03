#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

// Объявляем класс для работы с настройками
@interface PSPreferences : NSObject
+ (id)sharedInstance;
- (id)valuesForPreferencesWithIdentifier:(NSString *)identifier;
@end

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
- (void)launch;
@end

@interface SBApplicationController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)bundleIdentifier;
@end

@interface SpringBoard : UIApplication
- (void)applicationDidFinishLaunching:(id)application;
@end



%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    NSLog(@"[MaxDestroyer] SpringBoard запущен, твик активирован");
}

%end

%hook SBApplication

- (void)launch {
    NSString *bundleID = [self bundleIdentifier];
    
    NSLog(@"[MaxDestroyer] Попытка запуска приложения: %@", bundleID);
    
    // 1. Получаем настройки
    NSDictionary *settings = [[objc_getClass("PSPreferences") sharedInstance] valuesForPreferencesWithIdentifier:@"com.greatlove.maxdestroyer"];
    
    // 2. Проверяем, включен ли твик
    BOOL tweakEnabled = [settings[@"enabled"] ?: @YES boolValue];
    if (!tweakEnabled) {
        NSLog(@"[MaxDestroyer] Твик отключен, пропускаем перехват");
        %orig;
        return;
    }
    
    // 3. Получаем Bundle ID из настроек или используем значение по умолчанию
    NSString *targetBundleID = settings[@"targetBundleID"] ?: @"com.greatlove.maxdestroyer";
    
    if ([bundleID isEqualToString:targetBundleID]) {
        NSLog(@"[MaxDestroyer] Перехвачен запуск целевого приложения: %@", bundleID);
        
        // Показываем алерт
        NSString *alertTitle = settings[@"alertTitle"] ?: @"Не удалось открыть приложение";
        NSString *alertMessage = settings[@"alertMessage"] ?: @"Произошла критическая ошибка при инициализации приложения. Код ошибки: 0x80004005. Попробуйте переустановить приложение или обратитесь в службу поддержки.";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
            message:alertMessage
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            exit(0);
        }];

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
        
        // НЕ вызываем оригинальный метод launch
        return;
    }
    
    // Для всех остальных приложений вызываем оригинальный метод
    %orig;
}

%end
