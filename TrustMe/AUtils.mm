#import "AUtils.h"

unsigned long long cryptbase1 = 1684882565656475831;
unsigned long long cryptbase2 = 8113713737338462348;

unsigned long long encID(unsigned long long vendorID) {
    unsigned long long encrypted = (vendorID + cryptbase1) ^ (cryptbase2);
    return encrypted;
} 