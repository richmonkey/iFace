

#import <Foundation/Foundation.h>

typedef enum{
	
	TAHttpOperationFailToCreateConnect,    // 创建连接失败
	TAHttpOperationServerNotFound,         // 未找到服务器
	TAHttpOperationTimeout,                // 连接超时
	TAHttpOperationServerUnknown,          // 服务器发生未知错误
	TAHttpOperationUnknown                 // 未知错误
	
}TAHttpOperationError;

@class TAHttpOperation;

typedef void (^SuccessBlock)(TAHttpOperation*commObj, NSURLResponse *response, NSData *data);
typedef void (^FailBlock)(TAHttpOperation*commObj, TAHttpOperationError error);

#pragma mark -
#pragma mark TAHttpOperation Http通信操作类

@interface TAHttpOperation : NSOperation {
@protected
	BOOL                executing;
    BOOL                finished;
	NSURLConnection     *urlConnection;
	NSMutableData       *responseData;
	NSUInteger          timeoutInterval;
}

@property(nonatomic, copy)NSString *targetURL;
@property(nonatomic, copy)NSString *method;
@property(nonatomic, copy)NSDictionary *headers;
@property(nonatomic, copy)NSData *postBody;
@property(nonatomic, copy)SuccessBlock successCB;
@property(nonatomic, copy)FailBlock failCB;
@property(nonatomic)NSURLResponse *responseHeader;

-(id)initWithTimeoutInterval : (double)dblTimeout;


+(TAHttpOperation*)httpOperationWithTimeoutInterval : (double)dblTimeout;


+(NSString*)descriptionOfError: (TAHttpOperationError) error;

@end
