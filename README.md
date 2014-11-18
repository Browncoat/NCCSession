NCCSession is a session mananger that makes it easy to store sensitive data between sessions in the keychain.

## How To Get Started

- [Download NCCSession](https://github.com/Browncoat/NCCSession/archive/master.zip)

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/ncccoredataclient). (Tag 'nccsession')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/nccsession).
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Requirements
iOS 5.1+

## Usage

To create a session and pass a dictionary to be stored in the keychain
```objective-c
NCCSession *session = [NCCSession createSessionWithUserId:userId userInfo:@{SESSION_TOKEN_NAME:accessToken, 
                                                      SESSION_ID_NAME:sessionId, 
                                                      API_KEY_NAME:apiKey, 
                                                      APP_ID_NAME:appId} service:@"com.yourapp"];
```

In `application:didFinishLaunchingWithOptions:` check to see if a session has already been saved 
```objective-c
NCCSession *session = [NCCSession sessionWithService:@"com.yourapp"];
if ([NCCSession isValid]) {
    [self doStuff];
}
```

Retrieve the userInfo dictionary that was previously store in the session keychain
```objective-c
NSDictionary *userInfo = [[NCCSession sharedSession] userInfo];
```

Clear a session user
```objective-c
[NCCSession invalidateSession];
```

You can also get a session for userId
```objective-c
NCCSession *session = [NCCSession sessionWithService:@"com.yourapp" userId:@"213"]
```

