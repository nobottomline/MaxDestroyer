#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Объявляем классы
@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
- (void)launch;
@end

@interface SpringBoard : UIApplication
- (void)applicationDidFinishLaunching:(id)application;
@end

// Функция для показа алерта
static void showErrorAlert() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Не удалось открыть приложение"
            message:@"Произошла критическая ошибка при инициализации приложения. Код ошибки: 0x80004005. Попробуйте переустановить приложение или обратитесь в службу поддержки."
            preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        
        // Получаем главное окно
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
    
    // Проверяем целевой Bundle ID
    if ([bundleID isEqualToString:@"com.greatlove.maxdestroyer"]) {
        NSLog(@"[MaxDestroyer] БЛОКИРУЕМ запуск: %@", bundleID);
        showErrorAlert();
        return; // НЕ запускаем приложение
    }
    
    %orig; // Запускаем приложение как обычно
}

%end