#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Максимально простая функция для показа алерта
static void showAlert() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ТЕСТ"
        message:@"Твик работает!"
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
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    NSLog(@"[MaxDestroyer] SpringBoard запущен!");
    
    // Показываем алерт через 2 секунды
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[MaxDestroyer] Показываем алерт");
        showAlert();
    });
}

%end