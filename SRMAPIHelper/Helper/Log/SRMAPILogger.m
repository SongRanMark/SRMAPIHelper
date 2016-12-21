//
//  SRMAPILogger.m
//  SRMAPIHelper
//
//  Created by marksong on 12/12/16.
//  Copyright © 2016 S.R. All rights reserved.
//

#import "SRMAPILogger.h"
#import "SRMBaseAPIManager.h"
#import <sys/timeb.h>

#define mLogTime ({\
    struct timeb currentTime;\
    ftime(&currentTime);\
    char secondLevelStr[20];\
    strftime(secondLevelStr, 20, "%F %H:%M:%S", localtime(&currentTime.time));\
    char millisecondLevelStr[24];\
    sprintf(millisecondLevelStr, "%s.%03d", secondLevelStr, currentTime.millitm);\
    millisecondLevelStr;\
})

@interface SRMAPILogger ()

@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation SRMAPILogger

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SRMAPILogger *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (void)logRequest:(NSURLRequest *)request {
    if (!self.enabled) {
        return;
    }
    
    NSMutableString *logString = [NSMutableString stringWithString:@"*** Request ***\n\n"];
    [logString appendFormat:@"%@\n\n", request.HTTPMethod];
    [logString appendFormat:@"URL : %@\n\n", request.URL.absoluteString];
    [logString appendFormat:@"Body : %@\n\n", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    [logString appendFormat:@"Time : %@\n\n", [self.dateFormatter stringFromDate:[NSDate date]]];
    [logString appendString:@"***\n"];
    fprintf(stderr,"%s", [logString UTF8String]);
}

- (void)logRequestWithAPIManager:(SRMBaseAPIManager *)APIManager URL:(NSString *)URL parameters:(id)parameters {
    if (!self.enabled) {
        return;
    }
    
    NSMutableString *logString = [NSMutableString stringWithFormat:@"***[%@ (Request)]***\n\n", [APIManager class]];
    [logString appendFormat:@"%@\n\n", [self nameFromRequestType:[APIManager requestMethodType]]];
    [logString appendFormat:@"URL : %@\n\n", URL];
    [logString appendFormat:@"Parameters : %@\n\n", parameters];
    [logString appendFormat:@"Time : %@\n\n", [self.dateFormatter stringFromDate:[NSDate date]]];
    [logString appendString:@"***\n"];
    fprintf(stderr,"%s", [logString UTF8String]);
}

- (void)logResponseWithAPIManager:(SRMBaseAPIManager *)APIManager response:(NSHTTPURLResponse *)response content:(id)content error:(NSError *)error {
    if (!self.enabled) {
        return;
    }
    
    NSMutableString *logString = [NSMutableString stringWithFormat:@"***[%@ (Response)]***\n\n", [APIManager class]];
    [logString appendFormat:@"Status : %@ %@\n\n", @(response.statusCode), [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    [logString appendFormat:@"Headers : %@\n\n", response.allHeaderFields];
    [logString appendFormat:@"Content : %@\n\n", content];
    [logString appendFormat:@"Error : %@\n\n", error];
    [logString appendFormat:@"Time : %@\n\n", [self.dateFormatter stringFromDate:[NSDate date]]];
    [logString appendString:@"***\n"];
    fprintf(stderr,"%s", [logString UTF8String]);
}

- (void)log:(NSString *)format, ... {
    if (!self.enabled) {
        return;
    }
    
    va_list arg_list;
    va_start(arg_list, format);
    NSString *information = [[NSString alloc] initWithFormat:format arguments:arg_list];
    va_end(arg_list);
    NSString *callerInformation = [NSThread callStackSymbols][1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[callerInformation  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    NSString *callerString = [NSString stringWithFormat:@"[%@ %@]", array[3], array[4]];
    fprintf(stderr,"%s %s %s\n", mLogTime, [callerString UTF8String], [information UTF8String]);
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    }
    
    return _dateFormatter;
}

- (NSString *)nameFromRequestType:(SRMAPIManagerRequestMethodType)type {
    NSString *name;
    
    switch (type) {
        case SRMAPIManagerRequestMethodTypeGET:
            name = @"GET";
            break;
        case SRMAPIManagerRequestMethodTypePOST:
            name = @"POST";
            break;
        case SRMAPIManagerRequestMethodTypePUT:
            name = @"PUT";
            break;
        case SRMAPIManagerRequestMethodTypeDELETE:
            name = @"DELETE";
            break;
    }
    
    return name;
}

@end
