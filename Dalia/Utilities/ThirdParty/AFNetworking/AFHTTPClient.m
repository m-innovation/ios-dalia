// AFHTTPClient.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONUtilities.h"

#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#endif

#ifdef _SYSTEMCONFIGURATION_H
#import <SystemConfiguration/SystemConfiguration.h>
#endif

NSString * const AFNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";

//static NSString * const kAFMultipartFormLineDelimiter = @"\r\n"; // CRLF
static NSString * const kAFMultipartFormBoundary = @"Boundary+0xAbCdEfGbOuNdArY";

@interface AFMultipartFormData : NSObject <AFMultipartFormData> {
@private
    NSStringEncoding _stringEncoding;
    NSMutableData *_mutableData;
}

@property (readonly) NSData *data;

- (id)initWithStringEncoding:(NSStringEncoding)encoding;

@end

#pragma mark -

#ifdef _SYSTEMCONFIGURATION_H
typedef SCNetworkReachabilityRef AFNetworkReachabilityRef;
#else
typedef id AFNetworkReachabilityRef;
#endif

typedef void (^AFNetworkReachabilityStatusBlock)(BOOL isNetworkReachable);
typedef void (^AFCompletionBlock)(void);

static NSUInteger const kAFHTTPClientDefaultMaxConcurrentOperationCount = 4;

static NSString * AFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]); 
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding] autorelease];
}

NSString * AFURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    
    /* 
     The documentation for `CFURLCreateStringByAddingPercentEscapes` suggests that one should "pre-process" URL strings with unpredictable sequences that may already contain percent escapes. However, if the string contains an unescaped sequence with '%' appearing without an escape code (such as when representing percentages like "42%"), `stringByReplacingPercentEscapesUsingEncoding` will return `nil`. Thus, the string is only unescaped if there are no invalid percent-escaped sequences. 
    */
    NSString *unescapedString = [string stringByReplacingPercentEscapesUsingEncoding:encoding];
    if (unescapedString) {
        string = unescapedString;
    }
    
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, (CFStringRef)kAFLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding)) autorelease];
}

#pragma mark -

@interface AFQueryStringComponent : NSObject {
@private
    NSString *_key;
    NSString *_value;
}

@property (readwrite, nonatomic, retain) id key;
@property (readwrite, nonatomic, retain) id value;

- (id)initWithKey:(id)key value:(id)value; 
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;

@end

@implementation AFQueryStringComponent 
@synthesize key = _key;
@synthesize value = _value;

- (id)initWithKey:(id)key value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.key = key;
    self.value = value;
    
    return self;
}

- (void)dealloc {
    [_key release];
    [_value release];
    [super dealloc];
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    return [NSString stringWithFormat:@"%@=%@", self.key, AFURLEncodedStringFromStringWithEncoding([self.value description], stringEncoding)];
}

@end

#pragma mark -

extern NSArray * AFQueryStringComponentsFromKeyAndValue(NSString *key, id value);
extern NSArray * AFQueryStringComponentsFromKeyAndDictionaryValue(NSString *key, NSDictionary *value);
extern NSArray * AFQueryStringComponentsFromKeyAndArrayValue(NSString *key, NSArray *value);

NSString * AFQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutableComponents = [NSMutableArray array];
    for (AFQueryStringComponent *component in AFQueryStringComponentsFromKeyAndValue(nil, parameters)) {
        [mutableComponents addObject:[component URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutableComponents componentsJoinedByString:@"&"];
}

NSArray * AFQueryStringComponentsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    if([value isKindOfClass:[NSDictionary class]]) {
        [mutableQueryStringComponents addObjectsFromArray:AFQueryStringComponentsFromKeyAndDictionaryValue(key, value)];
    } else if([value isKindOfClass:[NSArray class]]) {
        [mutableQueryStringComponents addObjectsFromArray:AFQueryStringComponentsFromKeyAndArrayValue(key, value)];
    } else {
        [mutableQueryStringComponents addObject:[[[AFQueryStringComponent alloc] initWithKey:key value:value] autorelease]];
    } 
    
    return mutableQueryStringComponents;
}

NSArray * AFQueryStringComponentsFromKeyAndDictionaryValue(NSString *key, NSDictionary *value){
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    [value enumerateKeysAndObjectsUsingBlock:^(id nestedKey, id nestedValue, BOOL *stop) {
        [mutableQueryStringComponents addObjectsFromArray:AFQueryStringComponentsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
    }];
    
    return mutableQueryStringComponents;
}

NSArray * AFQueryStringComponentsFromKeyAndArrayValue(NSString *key, NSArray *value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    [value enumerateObjectsUsingBlock:^(id nestedValue, NSUInteger idx, BOOL *stop) {
        [mutableQueryStringComponents addObjectsFromArray:AFQueryStringComponentsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
    }];
    
    return mutableQueryStringComponents;
}

static NSString * AFJSONStringFromParameters(NSDictionary *parameters) {
    NSError *error = nil;
    NSData *JSONData = AFJSONEncode(parameters, &error);
    
    if (!error) {
        return [[[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding] autorelease];
    } else {
        return nil;
    }
}

static NSString * AFPropertyListStringFromParameters(NSDictionary *parameters) {
    NSString *propertyListString = nil;
    NSError *error = nil;
    
    NSData *propertyListData = [NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    if (!error) {
        propertyListString = [[[NSString alloc] initWithData:propertyListData encoding:NSUTF8StringEncoding] autorelease];
    }
    
    return propertyListString;
}

@interface AFHTTPClient ()
@property (readwrite, nonatomic, retain) NSURL *baseURL;
@property (readwrite, nonatomic, retain) NSMutableArray *registeredHTTPOperationClassNames;
@property (readwrite, nonatomic, retain) NSMutableDictionary *defaultHeaders;
@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, assign) AFNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, copy) AFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;

#ifdef _SYSTEMCONFIGURATION_H
- (void)startMonitoringNetworkReachability;
- (void)stopMonitoringNetworkReachability;
#endif
@end

@implementation AFHTTPClient
@synthesize baseURL = _baseURL;
@synthesize stringEncoding = _stringEncoding;
@synthesize parameterEncoding = _parameterEncoding;
@synthesize registeredHTTPOperationClassNames = _registeredHTTPOperationClassNames;
@synthesize defaultHeaders = _defaultHeaders;
@synthesize operationQueue = _operationQueue;
@synthesize networkReachability = _networkReachability;
@synthesize networkReachabilityStatusBlock = _networkReachabilityStatusBlock;

+ (AFHTTPClient *)clientWithBaseURL:(NSURL *)url {
    return [[[self alloc] initWithBaseURL:url] autorelease];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.baseURL = url;
    
    self.stringEncoding = NSUTF8StringEncoding;
    self.parameterEncoding = AFFormURLParameterEncoding;
	
    self.registeredHTTPOperationClassNames = [NSMutableArray array];
    
	self.defaultHeaders = [NSMutableDictionary dictionary];
    
	// Accept-Encoding HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3
	[self setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
	
	// Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
	NSString *preferredLanguageCodes = [[NSLocale preferredLanguages] componentsJoinedByString:@", "];
	[self setDefaultHeader:@"Accept-Language" value:[NSString stringWithFormat:@"%@, en-us;q=0.8", preferredLanguageCodes]];

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)]];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown"]];
#endif
    
#ifdef _SYSTEMCONFIGURATION_H
    [self startMonitoringNetworkReachability];
#endif
    
    self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
	[self.operationQueue setMaxConcurrentOperationCount:kAFHTTPClientDefaultMaxConcurrentOperationCount];
    
    return self;
}

- (void)dealloc {
#ifdef _SYSTEMCONFIGURATION_H
    [self stopMonitoringNetworkReachability];
#endif
    
    [_baseURL release];
    [_registeredHTTPOperationClassNames release];
    [_defaultHeaders release];
    [_operationQueue release];
    [_networkReachabilityStatusBlock release];
    
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, baseURL: %@, defaultHeaders: %@, registeredOperationClasses: %@, operationQueue: %@>", NSStringFromClass([self class]), self, [self.baseURL absoluteString], self.defaultHeaders, self.registeredHTTPOperationClassNames, self.operationQueue];
}

#pragma mark -

#ifdef _SYSTEMCONFIGURATION_H
static void AFReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL isNetworkReachable = (isReachable && !needsConnection);
        
    AFNetworkReachabilityStatusBlock block = (AFNetworkReachabilityStatusBlock)info;
    if (block) {
        block(isNetworkReachable);
    }
        
    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingReachabilityDidChangeNotification object:[NSNumber numberWithBool:isNetworkReachable]];
}

- (void)startMonitoringNetworkReachability {
    [self stopMonitoringNetworkReachability];
    self.networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [[self.baseURL host] UTF8String]);
    SCNetworkReachabilityContext context = {0, self.networkReachabilityStatusBlock, NULL, NULL, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, AFReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), (CFStringRef)NSRunLoopCommonModes);
}

- (void)stopMonitoringNetworkReachability {
    if (_networkReachability) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_networkReachability, CFRunLoopGetMain(), (CFStringRef)NSRunLoopCommonModes);
        CFRelease(_networkReachability);
    }
}

- (void)setReachabilityStatusChangeBlock:(void (^)(BOOL isNetworkReachable))block {
    self.networkReachabilityStatusBlock = block;
    [self startMonitoringNetworkReachability];
}
#endif

#pragma mark -

- (BOOL)registerHTTPOperationClass:(Class)operationClass {
    if (![operationClass isSubclassOfClass:[AFHTTPRequestOperation class]]) {
        return NO;
    }
    
    NSString *className = NSStringFromClass(operationClass);
    [self.registeredHTTPOperationClassNames removeObject:className];
    [self.registeredHTTPOperationClassNames insertObject:className atIndex:0];
    
    return YES;
}

- (void)unregisterHTTPOperationClass:(Class)operationClass {
    NSString *className = NSStringFromClass(operationClass);
    [self.registeredHTTPOperationClassNames removeObject:className];
}

#pragma mark -

- (NSString *)defaultValueForHeader:(NSString *)header {
	return [self.defaultHeaders valueForKey:header];
}

- (void)setDefaultHeader:(NSString *)header value:(NSString *)value {
	[self.defaultHeaders setValue:value forKey:header];
}

- (void)setAuthorizationHeaderWithUsername:(NSString *)username password:(NSString *)password {
	NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", username, password];
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", AFBase64EncodedStringFromString(basicAuthCredentials)]];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token token=\"%@\"", token]];
}

- (void)clearAuthorizationHeader {
	[self.defaultHeaders removeObjectForKey:@"Authorization"];
}

#pragma mark -

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method 
                                      path:(NSString *)path 
                                parameters:(NSDictionary *)parameters 
{	
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPMethod:method];
    [request setAllHTTPHeaderFields:self.defaultHeaders];
	
    if (parameters) {        
        if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];
            [request setURL:url];
        } else {
            NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
            switch (self.parameterEncoding) {
                case AFFormURLParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding) dataUsingEncoding:self.stringEncoding]];
                    break;
                case AFJSONParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[AFJSONStringFromParameters(parameters) dataUsingEncoding:self.stringEncoding]];
                    break;
                case AFPropertyListParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[AFPropertyListStringFromParameters(parameters) dataUsingEncoding:self.stringEncoding]];
                    break;
            }
        }
    }
    
	return request;
}

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>formData))block
{
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:nil];
    __block AFMultipartFormData *formData = [[AFMultipartFormData alloc] initWithStringEncoding:self.stringEncoding];
    
    for (AFQueryStringComponent *component in AFQueryStringComponentsFromKeyAndValue(nil, parameters)) {
        NSData *data = nil;
        if ([component.value isKindOfClass:[NSData class]]) {
            data = component.value;
        } else {
            data = [[component.value description] dataUsingEncoding:self.stringEncoding];
        }
        
        [formData appendPartWithFormData:data name:[component.key description]];
    }

    if (block) {
        block(formData);
    }
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kAFMultipartFormBoundary] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[formData data]];
    
    [formData autorelease];
    
    return request;
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest 
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = nil;
    NSString *className = nil;
    NSEnumerator *enumerator = [self.registeredHTTPOperationClassNames reverseObjectEnumerator];
    while (!operation && (className = [enumerator nextObject])) {
        Class op_class = NSClassFromString(className);
        if (op_class && [op_class canProcessRequest:urlRequest]) {
            operation = [[(AFHTTPRequestOperation *)[op_class alloc] initWithRequest:urlRequest] autorelease];
        }
    }
    
    if (!operation) {
        operation = [[[AFHTTPRequestOperation alloc] initWithRequest:urlRequest] autorelease];
    }
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
       
    return operation;
}

#pragma mark -

- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    [self.operationQueue addOperation:operation];
}

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method path:(NSString *)path {
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }
        
        if ((!method || [method isEqualToString:[[(AFHTTPRequestOperation *)operation request] HTTPMethod]]) && [path isEqualToString:[[[(AFHTTPRequestOperation *)operation request] URL] path]]) {
            [operation cancel];
        }
    }
}

- (void)enqueueBatchOfHTTPRequestOperationsWithRequests:(NSArray *)requests 
                                          progressBlock:(void (^)(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations))progressBlock 
                                        completionBlock:(void (^)(NSArray *operations))completionBlock
{
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (NSURLRequest *request in requests) {
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:nil failure:nil];
        [mutableOperations addObject:operation];
    }
    
    [self enqueueBatchOfHTTPRequestOperations:mutableOperations progressBlock:progressBlock completionBlock:completionBlock];
}

- (void)enqueueBatchOfHTTPRequestOperations:(NSArray *)operations 
                              progressBlock:(void (^)(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations))progressBlock 
                            completionBlock:(void (^)(NSArray *operations))completionBlock
{
    NSBlockOperation *batchedOperation = [NSBlockOperation blockOperationWithBlock:^{
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(operations);
            });
        }
    }];
    
    [self.operationQueue addOperation:batchedOperation];
    
    NSPredicate *finishedOperationPredicate = [NSPredicate predicateWithFormat:@"isFinished == YES"];
    
    for (AFHTTPRequestOperation *operation in operations) {
        AFCompletionBlock originalCompletionBlock = [[operation.completionBlock copy] autorelease];
        operation.completionBlock = ^{
            if (progressBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock([[batchedOperation.dependencies filteredArrayUsingPredicate:finishedOperationPredicate] count], [batchedOperation.dependencies count]);
                });
            }
            
            if (originalCompletionBlock) {
                originalCompletionBlock();
            }
        };
        
        [batchedOperation addDependency:operation];
        [self enqueueHTTPRequestOperation:operation];
    }
}

#pragma mark -

- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters 
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path 
      parameters:(NSDictionary *)parameters 
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)putPath:(NSString *)path 
     parameters:(NSDictionary *)parameters 
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)deletePath:(NSString *)path 
        parameters:(NSDictionary *)parameters 
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)patchPath:(NSString *)path 
       parameters:(NSDictionary *)parameters 
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:@"PATCH" path:path parameters:parameters];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

@end

#pragma mark -

static NSString * const kAFMultipartFormCRLF = @"\r\n";

static inline NSString * AFMultipartFormInitialBoundary() {
    return [NSString stringWithFormat:@"--%@%@", kAFMultipartFormBoundary, kAFMultipartFormCRLF];
}

static inline NSString * AFMultipartFormEncapsulationBoundary() {
    return [NSString stringWithFormat:@"%@--%@%@", kAFMultipartFormCRLF, kAFMultipartFormBoundary, kAFMultipartFormCRLF];
}

static inline NSString * AFMultipartFormFinalBoundary() {
    return [NSString stringWithFormat:@"%@--%@--%@", kAFMultipartFormCRLF, kAFMultipartFormBoundary, kAFMultipartFormCRLF];
}

@interface AFMultipartFormData ()
@property (readwrite, nonatomic, assign) NSStringEncoding stringEncoding;
@property (readwrite, nonatomic, retain) NSMutableData *mutableData;
@end

@implementation AFMultipartFormData
@synthesize stringEncoding = _stringEncoding;
@synthesize mutableData = _mutableData;

- (id)initWithStringEncoding:(NSStringEncoding)encoding {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = encoding;
    self.mutableData = [NSMutableData dataWithLength:0];
    
    return self;
}

- (void)dealloc {
    [_mutableData release];
    [super dealloc];
}

- (NSData *)data {
    NSMutableData *finalizedData = [NSMutableData dataWithData:self.mutableData];
    [finalizedData appendData:[AFMultipartFormFinalBoundary() dataUsingEncoding:self.stringEncoding]];
    return finalizedData;
}

#pragma mark - AFMultipartFormData

- (void)appendPartWithHeaders:(NSDictionary *)headers body:(NSData *)body {
    if ([self.mutableData length] == 0) {
        [self appendString:AFMultipartFormInitialBoundary()];
    } else {
        [self appendString:AFMultipartFormEncapsulationBoundary()];
    }
    
    for (NSString *field in [headers allKeys]) {
        [self appendString:[NSString stringWithFormat:@"%@: %@%@", field, [headers valueForKey:field], kAFMultipartFormCRLF]];
    }
    
    [self appendString:kAFMultipartFormCRLF];
    [self appendData:body];
}

- (void)appendPartWithFormData:(NSData *)data name:(NSString *)name {
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"", name] forKey:@"Content-Disposition"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendPartWithFileData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName] forKey:@"Content-Disposition"];
    [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL name:(NSString *)name error:(NSError **)error {
    if (![fileURL isFileURL]) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:fileURL forKey:NSURLErrorFailingURLErrorKey];
        [userInfo setValue:NSLocalizedString(@"Expected URL to be a file URL", nil) forKey:NSLocalizedFailureReasonErrorKey];
        if (error != NULL) {
          *error = [[[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:NSURLErrorBadURL userInfo:userInfo] autorelease];  
        }
        
        return NO;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
    [request setCachePolicy:NSURLCacheStorageNotAllowed];
    
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    
    if (data && response) {
        [self appendPartWithFileData:data name:name fileName:[response suggestedFilename] mimeType:[response MIMEType]];
        
        return YES;
    } else {
        return NO;
    }
}

- (void)appendData:(NSData *)data {
    [self.mutableData appendData:data];
}

- (void)appendString:(NSString *)string {
    [self appendData:[string dataUsingEncoding:self.stringEncoding]];
}

@end
