#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SpringBoardServices/SpringBoardServices.h>

// Ключи для настроек
#define PREFERENCES_PATH @"/var/mobile/Library/Preferences/com.greatlove.maxdestroyer.plist"
#define ENABLED_KEY @"enabled"
#define ALERT_TITLE_KEY @"alertTitle"
#define ALERT_MESSAGE_KEY @"alertMessage"
#define TARGET_BUNDLE_ID_KEY @"targetBundleID"

// Значения по умолчанию
#define DEFAULT_TARGET_BUNDLE_ID @"com.greatlove.maxdestroyer"
#define DEFAULT_ALERT_TITLE @"Не удалось открыть приложение"
#define DEFAULT_ALERT_MESSAGE @"Произошла критическая ошибка при инициализации приложения. Код ошибки: 0x80004005. Попробуйте переустановить приложение или обратитесь в службу поддержки."

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

// Функция для получения настроек
NSDictionary* getPreferences() {
    static NSDictionary *prefs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        prefs = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
        if (!prefs) {
            prefs = @{
                ENABLED_KEY: @YES,
                ALERT_TITLE_KEY: DEFAULT_ALERT_TITLE,
                ALERT_MESSAGE_KEY: DEFAULT_ALERT_MESSAGE,
                TARGET_BUNDLE_ID_KEY: DEFAULT_TARGET_BUNDLE_ID
            };
        }
    });
    return prefs;
}

// Функция для показа алерта
void showErrorAlert() {
    NSDictionary *prefs = getPreferences();
    
    NSString *alertTitle = prefs[ALERT_TITLE_KEY] ?: DEFAULT_ALERT_TITLE;
    NSString *alertMessage = prefs[ALERT_MESSAGE_KEY] ?: DEFAULT_ALERT_MESSAGE;
    
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:alertTitle
        message:alertMessage
        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction 
        actionWithTitle:@"OK" 
        style:UIAlertActionStyleDefault 
        handler:^(UIAlertAction *action) {
            NSLog(@"[MaxDestroyer] Пользователь нажал OK, приложение будет завершено");
            // Принудительно завершаем приложение
            exit(0);
        }];
    
    [alert addAction:okAction];
    
    // Получаем корневой контроллер для показа алерта
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
        NSLog(@"[MaxDestroyer] Алерт показан пользователю");
    } else {
        NSLog(@"[MaxDestroyer] Ошибка: не удалось найти корневой контроллер для показа алерта");
    }
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
    
    // Получаем настройки
    NSDictionary *prefs = getPreferences();
    
    // Проверяем, включен ли твик
    BOOL isEnabled = [prefs[ENABLED_KEY] boolValue];
    if (!isEnabled) {
        NSLog(@"[MaxDestroyer] Твик отключен, пропускаем перехват");
        %orig;
        return;
    }
    
    // Получаем целевой Bundle ID из настроек
    NSString *targetBundleID = prefs[TARGET_BUNDLE_ID_KEY] ?: DEFAULT_TARGET_BUNDLE_ID;
    
    // Проверяем, является ли это целевым приложением
    if ([bundleID isEqualToString:targetBundleID]) {
        NSLog(@"[MaxDestroyer] Перехвачен запуск целевого приложения: %@", bundleID);
        
        // Показываем алерт на главном потоке
        dispatch_async(dispatch_get_main_queue(), ^{
            showErrorAlert();
        });
        
        // НЕ вызываем оригинальный метод launch
        return;
    }
    
    // Для всех остальных приложений вызываем оригинальный метод
    %orig;
}

%end
