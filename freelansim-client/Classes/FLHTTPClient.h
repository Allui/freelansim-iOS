//
//  FLHTTPClient.h
//  freelansim-client
//
//  Created by Кирилл on 16.12.12.
//  Copyright (c) 2012 Kirill Kunst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"



typedef void (^FLHTTPClientSuccess)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^FLHTTPClientSuccessWithArray)(NSArray *objects, AFHTTPRequestOperation *operation, id responseObject, BOOL *stop);
typedef void (^FLHTTPClientFailure)(AFHTTPRequestOperation *operation, NSError *error);

@interface FLHTTPClient : AFHTTPClient {
    dispatch_queue_t _callbackQueue;
}

+(FLHTTPClient *)sharedClient;

-(void)getTasksWithCategories:(NSArray *)categories page:(int)page success:(FLHTTPClientSuccessWithArray)success failure:(FLHTTPClientFailure)failure;

@end
