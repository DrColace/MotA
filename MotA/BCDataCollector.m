//
//  BCDataCollector.m
//  MotA
//
//  Created by Drew Colace on 5/1/17.
//  Copyright © 2017 Drew Colace. All rights reserved.
//

#import "BCDataCollector.h"
#import "AFNetworking.h"

NSString * const BC_LOOKUP_STRING = @"sf";
NSString * const BC_STRING_DEFINITIONS = @"lfs";
NSString * const BC_STRING_DEFINITION = @"lf";

NSString * const BC_HOST_STRING = @"http://www.nactem.ac.uk/software/acromine/dictionary.py";
NSString * const BC_HTTP_CONTENT_TYPE = @"text/plain";


@interface BCDataCollector (/*private*/)

@property (nonatomic, strong)   NSString *URLString;
@property (nonatomic, strong)   AFHTTPSessionManager *manager;

@end


@implementation BCDataCollector

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.URLString = BC_HOST_STRING;
        
        self.manager = [AFHTTPSessionManager manager];
        
        NSMutableSet    *responseContentType = [NSMutableSet setWithSet:self.manager.responseSerializer.acceptableContentTypes];
        
        // necessary modification to the acceptable response content type
        // since the server service is not setting content type as json
        [responseContentType addObject:BC_HTTP_CONTENT_TYPE];
        
        self.manager.responseSerializer.acceptableContentTypes = responseContentType;
    }

    return self;
}

- (void)lookupAcronym:(NSString *)lookupString suceeded:(void (^)(NSArray *))suceeded failed:(void (^)(void))failed
{
    [self.manager GET:self.URLString parameters:@{BC_LOOKUP_STRING : lookupString} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *updatedDefinitions;
        
        if([responseObject count] > 0)
        {
            NSArray *responseArray = [[responseObject objectAtIndex:0] objectForKey:BC_STRING_DEFINITIONS];
            
            updatedDefinitions = [responseArray valueForKey:BC_STRING_DEFINITION];
        }
        else
        {
            updatedDefinitions = [NSArray array];
        }
        
        if(suceeded)
        {
            suceeded(updatedDefinitions);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // we could bubble up the error code or have a enumerated list of errors that are specially handled
        if(failed)
        {
            failed();
        }
    }];
}

@end
