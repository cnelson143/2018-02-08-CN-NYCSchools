/*
 File: CLNetworkStatus.m
*/

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>

#import "CLNetworkStatusCheck.h"

#define kShouldPrintNetworkStatusFlags 1

static void PrintReachabilityFlags(SCNetworkReachabilityFlags    flags, const char* comment)
{
#if kShouldPrintNetworkStatusCheckFlags
	
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
			(flags & kSCNetworkReachabilityFlagsIsWWAN)				  ? 'W' : '-',
			(flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
			
			(flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
			(flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
			(flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
			(flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
			comment
			);
#endif
}

@interface CLNetworkStatusCheck ()

@end

@implementation CLNetworkStatusCheck

+ (CLNetworkStatusCheck *)sharedInstance;
{
    static dispatch_once_t onceToken;
    
    __strong static id _sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CLNetworkStatusCheck alloc] init];
    });
    return _sharedInstance;
}

static void NetworkStatusCheckCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
	#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [CLNetworkStatusCheck class]], @"info was wrong class in ReachabilityCallback");

	//We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
	// in case someon uses the Reachablity object in a different thread.
	/////NSAutoreleasePool* myPool = [[NSAutoreleasePool alloc] init];
	
	CLNetworkStatusCheck* noteObject = (__bridge CLNetworkStatusCheck*) info;
	// Post a notification to notify the client that the network reachability changed.
	[[NSNotificationCenter defaultCenter] postNotificationName: kNetworkStatusCheckChangedNotification object: noteObject];
	
	/////[myPool release];
}

- (BOOL) startNotifier
{
	BOOL retVal = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	if(SCNetworkReachabilitySetCallback(self.networkStatusCheckRef, NetworkStatusCheckCallback, &context))
	{
		if(SCNetworkReachabilityScheduleWithRunLoop(self.networkStatusCheckRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
		{
			retVal = YES;
		}
	}
	return retVal;
}

- (void) stopNotifier
{
	if(self.networkStatusCheckRef!= NULL)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(self.networkStatusCheckRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}

- (void) dealloc
{
	[self stopNotifier];
	if(self.networkStatusCheckRef!= NULL)
	{
		CFRelease(self.networkStatusCheckRef);
	}
	//[super dealloc];
}

+ (CLNetworkStatusCheck*) networkStatusCheckWithHostName: (NSString*) hostName;
{
	CLNetworkStatusCheck* retVal = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if(reachability!= NULL)
	{
		retVal= [[self alloc] init];
		if(retVal!= NULL)
		{
			retVal.networkStatusCheckRef = reachability;
			retVal.localWiFiRef = NO;
		}
        else
        {
            CFRelease(reachability);
        }
	}
    else
    {
        CFRelease(reachability);
    }
	return retVal;
}

+ (CLNetworkStatusCheck*) networkStatusCheckWithAddress: (const struct sockaddr_in*) hostAddress;
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
	CLNetworkStatusCheck* retVal = NULL;
	if(reachability!= NULL)
	{
		retVal= [[self alloc] init];
		if(retVal!= NULL)
		{
			retVal.networkStatusCheckRef = reachability;
			retVal.localWiFiRef = NO;
		}
        else
        {
            CFRelease(reachability);
        }
	}
    else
    {
        CFRelease(reachability);
    }
	return retVal;
}

+ (CLNetworkStatusCheck*) networkStatusCheckForInternetConnection;
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	return [self networkStatusCheckWithAddress: &zeroAddress];
}

+ (CLNetworkStatusCheck*) networkStatusCheckForLocalWiFi;
{
	[super init];
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	CLNetworkStatusCheck* retVal = [self networkStatusCheckWithAddress: &localWifiAddress];
	if(retVal!= NULL)
	{
		retVal.localWiFiRef = YES;
	}
	return retVal;
}

#pragma mark Network Flag Handling

- (CLNetworkStatus) localWiFiStatusForFlags: (SCNetworkReachabilityFlags) flags
{
	PrintReachabilityFlags(flags, "localWiFiStatusForFlags");

	BOOL retVal = NotReachable;
	if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
	{
		retVal = ReachableViaWiFi;	
	}
	return retVal;
}

- (CLNetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags
{
	PrintReachabilityFlags(flags, "networkStatusForFlags");
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// if target host is not reachable
		return NotReachable;
	}

	BOOL retVal = NotReachable;
	
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		// if target host is reachable and no connection is required
		//  then we'll assume (for now) that your on Wi-Fi
		retVal = ReachableViaWiFi;
	}
	
	
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
		(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
			// ... and the connection is on-demand (or on-traffic) if the
			//     calling application is using the CFSocketStream or higher APIs

			if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
			{
				// ... and no [user] intervention is needed
				retVal = ReachableViaWiFi;
			}
		}
	
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		// ... but WWAN connections are OK if the calling application
		//     is using the CFNetwork (CFSocketStream?) APIs.
		retVal = ReachableViaWWAN;
	}
	return retVal;
}

- (BOOL) connectionRequired;
{
	NSAssert(self.networkStatusCheckRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(self.networkStatusCheckRef, &flags))
	{
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}
	return NO;
}

+ (BOOL) isNetworkAvailable
{
    BOOL networkAvailable = NO;
    
    CLNetworkStatusCheck* networkCheck = [CLNetworkStatusCheck networkStatusCheckForInternetConnection];
    if([networkCheck currentNetworkStatusCheck] == ReachableViaWWAN || [networkCheck currentNetworkStatusCheck] == ReachableViaWiFi)
        networkAvailable = YES;

    return networkAvailable;
}

- (CLNetworkStatus) currentNetworkStatusCheck
{
	NSAssert(self.networkStatusCheckRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
	CLNetworkStatus retVal = NotReachable;
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(self.networkStatusCheckRef, &flags))
	{
		if(self.localWiFiRef)
		{
			retVal = [self localWiFiStatusForFlags: flags];
		}
		else
		{
			retVal = [self networkStatusForFlags: flags];
		}
	}
	return retVal;
}

+ (void) networkStatusCheckWithCompletionhandler:(void (^)(BOOL available))completionHandler
{
    BOOL available = NO;
    CLNetworkStatusCheck* networkCheck = [CLNetworkStatusCheck networkStatusCheckForInternetConnection];
    if([networkCheck currentNetworkStatusCheck] == ReachableViaWWAN || [networkCheck currentNetworkStatusCheck] == ReachableViaWiFi)
        available = YES;
    
    if(completionHandler != nil)
    {
        completionHandler(available);
    }
}


@end
