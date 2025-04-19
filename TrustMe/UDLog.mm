#import "UDLog.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import <sys/utsname.h>
#import <mach/mach.h>
#import <dlfcn.h>

@implementation UDLog

// Klucze (zmień na własne, długie i skomplikowane)
static NSString *const kSecretKey = @"YOUR_VERY_LONG_SECRET_KEY_HERE_MAKE_IT_RANDOM_AND_LONG_2024";
static NSString *const kEncryptionKey = @"ANOTHER_VERY_LONG_KEY_FOR_ENCRYPTION_MAKE_IT_DIFFERENT_2024";
static NSString *const kInitVector = @"RandomIV16BytesHr";
// Unikalny identyfikator aplikacji - zmień na własny, skomplikowany ciąg
static NSString *const kAppIdentifier = @"NF_7X91H_2024_UNIQUE_APP_IDENTIFIER_8472";

+ (NSString *)collectUserInfo:(NSString *)userID {
    NSMutableString *infoText = [NSMutableString string];
    
    @try {
        // Nagłówek
        [infoText appendFormat:@"APP_ID:%@\n\n", kAppIdentifier];
        
        // =========== SEKCJA 1: PODSTAWOWE INFORMACJE ===========
        [infoText appendString:@"========================================\n"];
        [infoText appendString:@"           PODSTAWOWE INFORMACJE        \n"];
        [infoText appendString:@"========================================\n\n"];
        
        // Dodajemy podstawowe informacje z pełną weryfikacją
        NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *currentDate = [[NSDate date] description];
        NSString *ipAddress = [self getPublicIPAddress];
        
        if (!userID) userID = @"Nieznane";
        if (!uuid) uuid = @"Nieznane";
        if (!currentDate) currentDate = @"Nieznane";
        if (!ipAddress) ipAddress = @"Nieznane";
        
        [infoText appendFormat:@"ID Użytkownika: %@\n", userID];
        [infoText appendFormat:@"UUID Urządzenia: %@\n", uuid];
        [infoText appendFormat:@"Data wygenerowania: %@\n", currentDate];
        [infoText appendFormat:@"Adres IP: %@\n\n", ipAddress];
        
        // =========== SEKCJA 2: INFORMACJE O URZĄDZENIU ===========
        [infoText appendString:@"========================================\n"];
        [infoText appendString:@"         INFORMACJE O URZĄDZENIU       \n"];
        [infoText appendString:@"========================================\n\n"];
        
        UIDevice *device = [UIDevice currentDevice];
        struct utsname systemInfo;
        uname(&systemInfo);
        
        [infoText appendFormat:@"Nazwa urządzenia: %@\n", device.name];
        [infoText appendFormat:@"Model: %@\n", device.model];
        [infoText appendFormat:@"Lokalny model: %@\n", @(systemInfo.machine)];
        [infoText appendFormat:@"System: %@ %@\n", device.systemName, device.systemVersion];
        [infoText appendFormat:@"Bateria: %.0f%%\n", device.batteryLevel * 100];
        [infoText appendFormat:@"Stan baterii: %@\n\n", [self batteryStateString:device.batteryState]];
        
        // =========== SEKCJA 3: INFORMACJE O SYSTEMIE ===========
        [infoText appendString:@"========================================\n"];
        [infoText appendString:@"         INFORMACJE O SYSTEMIE         \n"];
        [infoText appendString:@"========================================\n\n"];
        
        NSLocale *locale = [NSLocale currentLocale];
        NSString *languageCode = [[NSLocale preferredLanguages] firstObject];
        
        [infoText appendFormat:@"Język: %@ (%@)\n", 
            [locale localizedStringForLanguageCode:languageCode], 
            languageCode];
        [infoText appendFormat:@"Region: %@ (%@)\n", 
            [locale localizedStringForCountryCode:[locale objectForKey:NSLocaleCountryCode]], 
            [locale objectForKey:NSLocaleCountryCode]];
        [infoText appendFormat:@"Strefa czasowa: %@\n", [[NSTimeZone localTimeZone] name]];
        [infoText appendFormat:@"Format 24h: %@\n", [locale objectForKey:NSLocaleUsesMetricSystem] ? @"Tak" : @"Nie"];
        [infoText appendFormat:@"Wolna pamięć: %.2f GB\n", [self freeMemory]];
        [infoText appendFormat:@"Całkowita pamięć: %.2f GB\n\n", [self totalMemory]];
        
        // =========== SEKCJA 4: TWEAKI ===========
        [infoText appendString:@"========================================\n"];
        [infoText appendString:@"              TWEAKI                   \n"];
        [infoText appendString:@"========================================\n\n"];
        
        [infoText appendString:[self getJailbreakInfo]];
        [infoText appendString:@"\n"];
        
        // =========== SEKCJA 5: SIEĆ ===========
        [infoText appendString:@"========================================\n"];
        [infoText appendString:@"            INFORMACJE O SIECI         \n"];
        [infoText appendString:@"========================================\n\n"];
        
        [infoText appendFormat:@"Typ połączenia: %@\n", [self networkType]];
        [infoText appendFormat:@"WiFi SSID: %@\n", [self getWiFiSSID]];
        [infoText appendFormat:@"Carrier: %@\n\n", [self carrierName]];
        
        // Dodaj logowanie przed szyfrowaniem
        NSLog(@"Log przed szyfrowaniem:\n%@", infoText);
        
        // Konwersja tekstu na dane
        NSData *textData = [infoText dataUsingEncoding:NSUTF8StringEncoding];
        if (!textData) {
            NSLog(@"Error converting text to data");
            return nil;
        }
        
        // Szyfrowanie
        NSData *encryptedData = [self encryptData:textData];
        if (!encryptedData) {
            NSLog(@"Error encrypting data");
            return nil;
        }
        
        // Konwersja na base64
        NSString *base64String = [encryptedData base64EncodedStringWithOptions:0];
        if (!base64String) {
            NSLog(@"Error encoding to base64");
            return nil;
        }
        
        return base64String;
        
    } @catch (NSException *exception) {
        NSLog(@"Error in collectUserInfo: %@", exception);
        return nil;
    }
}

+ (NSData *)encryptString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self encryptData:data];
}

+ (NSData *)encryptData:(NSData *)data {
    // Stałe klucze
    NSData *keyData = [[kEncryptionKey dataUsingEncoding:NSUTF8StringEncoding] subdataWithRange:NSMakeRange(0, 32)];
    NSData *ivData = [[kInitVector dataUsingEncoding:NSUTF8StringEncoding] subdataWithRange:NSMakeRange(0, 16)];
    
    // Przygotowanie bufora wyjściowego
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                        kCCAlgorithmAES128,
                                        kCCOptionPKCS7Padding,
                                        keyData.bytes,
                                        keyData.length,
                                        ivData.bytes,
                                        data.bytes,
                                        data.length,
                                        buffer,
                                        bufferSize,
                                        &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *result = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return result;
    }
    
    free(buffer);
    return nil;
}

+ (NSString *)decryptData:(NSData *)encryptedData {
    // Przygotowanie klucza i IV
    NSData *keyData = [kEncryptionKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [kInitVector dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t outLength;
    NSMutableData *decryptedData = [NSMutableData dataWithLength:encryptedData.length + kCCBlockSizeAES128];
    
    CCCryptorStatus result = CCCrypt(kCCDecrypt, // operacja
                                   kCCAlgorithmAES128, // algorytm
                                   kCCOptionPKCS7Padding, // opcje
                                   keyData.bytes, // klucz
                                   kCCKeySizeAES256, // długość klucza
                                   ivData.bytes, // wektor inicjalizacyjny
                                   encryptedData.bytes, // dane wejściowe
                                   encryptedData.length, // długość danych
                                   decryptedData.mutableBytes, // bufor wyjściowy
                                   decryptedData.length, // rozmiar bufora
                                   &outLength); // faktyczna długość wyjścia
    
    if (result == kCCSuccess) {
        [decryptedData setLength:outLength];
        return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (BOOL)verifyData:(NSString *)base64Data {
    @try {
        // Dekodowanie base64
        NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:base64Data options:0];
        if (!encryptedData) return NO;
        
        // Odszyfrowanie danych
        NSString *decryptedString = [self decryptData:encryptedData];
        if (!decryptedString) return NO;
        
        // Sprawdzenie identyfikatora aplikacji
        NSArray *lines = [decryptedString componentsSeparatedByString:@"\n"];
        if (lines.count == 0) return NO;
        
        NSString *firstLine = lines[0];
        if (![firstLine hasPrefix:@"APP_ID:"]) return NO;
        
        NSString *appId = [firstLine substringFromIndex:7]; // długość "APP_ID:"
        if (![appId isEqualToString:kAppIdentifier]) return NO;
        
        return YES;
        
    } @catch (NSException *exception) {
        return NO;
    }
}

+ (NSString *)generateSignatureForText:(NSString *)text {
    const char *cKey = [kSecretKey cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [text cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", cHMAC[i]];
    }
    return hash;
}

+ (NSString *)getPublicIPAddress {
    NSError *error = nil;
    NSString *ipAddress = @"unknown";
    
    @try {
        // Próba pobrania IP z api.ipify.org
        NSURL *ipURL = [NSURL URLWithString:@"https://api.ipify.org"];
        NSURLRequest *request = [NSURLRequest requestWithURL:ipURL 
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:10.0];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request 
                                            returningResponse:nil 
                                                      error:&error];
        
        if (!error && data) {
            NSString *ipResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (ipResponse.length > 0) {
                ipAddress = ipResponse;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Error getting IP: %@", exception);
    }
    
    return [ipAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)getDeviceInfo {
    UIDevice *device = [UIDevice currentDevice];
    NSMutableString *deviceInfo = [NSMutableString string];
    
    [deviceInfo appendFormat:@"%@ %@ (%@ %@)", 
        device.name,
        device.model,
        device.systemName,
        device.systemVersion];
    
    return deviceInfo;
}

+ (NSString *)decodeUserInfo:(NSString *)base64Data {
    @try {
        // Dekodowanie base64
        NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:base64Data options:0];
        if (!encryptedData) return @"Invalid base64 data";
        
        // Odszyfrowanie danych
        NSString *decryptedString = [self decryptData:encryptedData];
        if (!decryptedString) return @"Decryption failed";
        
        return decryptedString;
        
    } @catch (NSException *exception) {
        return [NSString stringWithFormat:@"Error decoding: %@", exception];
    }
}

+ (NSString *)batteryStateString:(UIDeviceBatteryState)state {
    switch (state) {
        case UIDeviceBatteryStateUnplugged: return @"Niepodłączone";
        case UIDeviceBatteryStateCharging: return @"Ładowanie";
        case UIDeviceBatteryStateFull: return @"Naładowane";
        default: return @"Nieznany";
    }
}

+ (float)freeMemory {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void)host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    
    return ((vm_stat.free_count + vm_stat.inactive_count) * pagesize) / (1024.0 * 1024.0 * 1024.0);
}

+ (float)totalMemory {
    return [NSProcessInfo processInfo].physicalMemory / (1024.0 * 1024.0 * 1024.0);
}

+ (NSString *)getInstalledAppsInfo {
    NSMutableString *appsInfo = [NSMutableString string];
    NSArray *apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications" error:nil];
    
    [appsInfo appendString:@"Zainstalowane aplikacje:\n"];
    for (NSString *app in apps) {
        if ([app hasSuffix:@".app"]) {
            [appsInfo appendFormat:@"- %@\n", [app stringByReplacingOccurrencesOfString:@".app" withString:@""]];
        }
    }
    
    return appsInfo;
}

+ (NSString *)getJailbreakInfo {
    NSMutableString *jbInfo = [NSMutableString string];
    
    // Sprawdzanie typowych ścieżek jailbreak
    NSArray *paths = @[
        @"/Applications/Cydia.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/etc/apt",
        @"/private/var/lib/apt/"
    ];
    
    BOOL isJailbroken = NO;
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            isJailbroken = YES;
            [jbInfo appendFormat:@"Znaleziono: %@\n", path];
        }
    }
    
    // Sprawdzanie zainstalowanych tweaków
    NSString *tweaksPath = @"/Library/MobileSubstrate/DynamicLibraries";
    NSArray *tweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tweaksPath error:nil];
    
    if (tweaks.count > 0) {
        [jbInfo appendString:@"\nZainstalowane tweaki:\n"];
        for (NSString *tweak in tweaks) {
            if ([tweak hasSuffix:@".dylib"]) {
                [jbInfo appendFormat:@"- %@\n", [tweak stringByReplacingOccurrencesOfString:@".dylib" withString:@""]];
            }
        }
    }
    
    if (!isJailbroken && tweaks.count == 0) {
        [jbInfo appendString:@"Nie wykryto jailbreak\n"];
    }
    
    return jbInfo;
}

+ (NSString *)networkType {
    // Implementacja zależna od dostępnych frameworków
    return @"Nieznany";
}

+ (NSString *)getWiFiSSID {
    // Implementacja zależna od dostępnych frameworków
    return @"Niedostępne";
}

+ (NSString *)carrierName {
    // Implementacja zależna od dostępnych frameworków
    return @"Niedostępne";
}

// Dodajmy też metodę do debugowania
+ (void)logEncryptionDetails {
    NSLog(@"Encryption Key: %@", kEncryptionKey);
    NSLog(@"Init Vector: %@", kInitVector);
    NSLog(@"Key length: %lu", (unsigned long)[kEncryptionKey lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"IV length: %lu", (unsigned long)[kInitVector lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
}

// Dodaj metodę do logowania danych przed szyfrowaniem
+ (void)logDataDetails:(NSData *)data withMessage:(NSString *)message {
    NSLog(@"%@", message);
    NSLog(@"Data length: %lu", (unsigned long)data.length);
    NSLog(@"First 32 bytes: %@", [data subdataWithRange:NSMakeRange(0, MIN(32, data.length))]);
}

@end 