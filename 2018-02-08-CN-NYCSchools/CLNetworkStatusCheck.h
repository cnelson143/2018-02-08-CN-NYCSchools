#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} CLNetworkStatus;

#define kNetworkStatusCheckChangedNotification @"NetworkStatusCheckChangedNotification"

@interface CLNetworkStatusCheck: NSObject

+ (CLNetworkStatusCheck *)sharedInstance;

@property (nonatomic) BOOL localWiFiRef;
@property (nonatomic) SCNetworkReachabilityRef networkStatusCheckRef;

//networkStatusCheckWithHostName- Use to check the networkStatusCheck of a particular host name. 
+ (CLNetworkStatusCheck*) networkStatusCheckWithHostName: (NSString*) hostName;

// networkStatusCheckForInternetConnection- checks whether the default route is available.
// Should be used by applications that do not connect to a particular host
+ (CLNetworkStatusCheck*) networkStatusCheckForInternetConnection;

// networkStatusCheckForLocalWiFi- checks whether a local wifi connection is available.
+ (CLNetworkStatusCheck*) networkStatusCheckForLocalWiFi;

// Start listening for networkStatusCheck notifications on the current run loop
- (BOOL) startNotifier;
- (void) stopNotifier;

- (CLNetworkStatus) currentNetworkStatusCheck;
//WWAN may be available, but not active until a connection has been established.
//WiFi may require a connection for VPN on Demand.
- (BOOL) connectionRequired;

+ (void) networkStatusCheckWithCompletionhandler:(void (^)(BOOL available))completionHandler;

+ (BOOL) isNetworkAvailable;

@end


