# New FTChinese iOS App

## How To Start
$ sudo gem install cocoapods

$ pod install --repo-update

$ open Page.xcworkspace

For more, check out [Cocoa Pod](https://cocoapods.org/)


## Overall Goal
The aim of this project is to create a "mother of all news apps". With this project as a "scalfold", anyone who knows the basics of iOS development should be able to build a decent news app in a few minutes. For now, we have two milestones. 

## Migrate the current FTChinese hybrid app to a pure native app
### News Reader
### Billigual Support
### Channels
### Advertising: including launch ad, in page ad and paid post
### In-app Purchase

## Enhancement to existing hybrid app
### Done: All possible customizations in one place
### Done: Smooth Panning between content
### Done: Pull to refresh
### Infinite Scrolling in Home and Channel Pages
### In Progress: Dynamic Type Support
### Autorenewing Subscription
### JSON formating that supports as many as possible APIs
### In Progress: Newspaper experience on iPad

## Development Milestones

### Advertising: 
1. Done: Retrieve Ad info from Dolphin's script string
2. Done: Send third party impressions until they are confirmed
3. Done: Tap link for Ad Views
4. Done: Tap Link in content view
5. Done: Launch Screen Ad
6. Done: Native Banner
7. Done: Web Banner
8. Information flow
9. Done: Show Image if there's time

### Channel Page: 
1. Done: Stop using auto-resizing cells on Regular size. 
2. Use prefetch to make scrolling smooth. 
3. FT Academy
4. FT Intelligence
5. Most Popular
6. Calendar

### APIs
1. Done: Stories
2. Done: Retrieve and convert other types of API. 
3. Interactive Features
4. Videos: 

### Content Page: 
1. Done: Come up with bilingual and english switch. 
2. In Progress: Functionalities and buttons. 
3. Done: Video. 
4. Interactive Features. 
5. custom link
6. Handle Links
7. Done: Offline and Caches for Content
8. Done: A progress indicator untill web page is completely updated

### Offline and Caches
1. Done: Channel
2. Done: Content
3. Done: Clean
4. Done: Prefetch

### Sharing
1. Done: WeChat
2. Need Check: Built-ins

### Tracking
1. Done: Google
2. FTC's own tracking

### Audio
1. Done: Speech to Text
2. Done: Radio

### AI
1. Chat Room
2. Customer Service
3. Recommendation

### Core data

### Anvanced Notifications

### Today Widget

### Store
1. eBook
2. eReader

### Login and Registration
1. Normal 
2. WeChat

### myFT


## Completed Tasks
1. Video Page Take Full Screen Width 
2. Done: Send third party impressions until they are confirmed
3. Done: Tap link for Ad Views
1. Workspace
2. Cocoa Pod
3. Google Analytics
2. Done: Tracking Third Party Ad impression with native code
3. WeChat Share 
3. Home Page Font Size Review
1. Article Share Button
2. Article Switch to English and Billingual
1. Article Text-To-Speech
1. API as func rather than constant
2. Audio: Replicate the story board; Get a test page; Run
Advertisement Popped Out
Close Button Need to Pop
Some audios are not playable
1. Cache the current page apis
2. Cache stories
prefetch stories
3. Add Tracker to Detail Page
4. Update MPU ad by removing background color when displaying actual ad image
Track "list to story" event
Bug: Can't remember preference
track "listen to story" end event




Solution to the Collection View Crash Problem might be found here: 

https://fangpenlin.com/posts/2016/04/29/uicollectionview-invalid-number-of-items-crash-issue/


objc[1222]: Class PLBuildVersion is implemented in both /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/PrivateFrameworks/AssetsLibraryServices.framework/AssetsLibraryServices (0x10b45fcc0) and /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/PrivateFrameworks/PhotoLibraryServices.framework/PhotoLibraryServices (0x10b2766f0). One of the two will be used. Which one is undefined.
2017-07-27 19:21:28.565 Page[1222] <Warning> [Firebase/Analytics][I-ACS005000] The AdSupport Framework is not currently linked. Some features will not function properly. Learn more at http://goo.gl/9vSsPb
2017-07-27 19:21:28.594 Page[1222] <Notice> [Firebase/Analytics][I-ACS023007] Firebase Analytics v.3900000 started
2017-07-27 19:21:28.595 Page[1222] <Notice> [Firebase/Analytics][I-ACS023008] To enable debug logging set the following application argument: -FIRAnalyticsDebugEnabled (see http://goo.gl/RfcP7r)
2017-07-27 19:21:28.622 Page[1222] <Notice> [Firebase/Analytics][I-ACS003007] Successfully created Firebase Analytics App Delegate Proxy automatically. To disable the proxy, set the flag FirebaseAppDelegateProxyEnabled to NO in the Info.plist
201707211920.0
201707271702.0
get schedule from bundled json
[2]
0: 2
send to https://bsch.serving-sys.com/serving/adServer.bs?cn=display&c=19&mc=imp&pli=21977036&PluID=0&ord=__TIME__&rtu=-1&mb=1
2017-07-27 19:21:28.796 Page[1222:11198] Presenting view controllers on detached view controllers is discouraged <Page.ChannelViewController: 0x7feb456075e0>.
Return the data view controller for 0
2017-07-27 19:21:29.166 Page[1222:11198] Unbalanced calls to begin/end appearance transitions for <Page.CustomTabBarController: 0x7feb4540d6c0>.
Remote notification support is unavailable due to error: Error Domain=NSCocoaErrorDomain Code=3010 "remote notifications are not supported in the simulator" UserInfo={NSLocalizedDescription=remote notifications are not supported in the simulator}
send track for event: iPhone Launch Ad, Sent, https://bsch.serving-sys.com/serving/adServer.bs?cn=display&c=19&mc=imp&pli=21977036&PluID=0&ord=__TIME__&rtu=-1&mb=1
send track for event: iPhone Launch Ad, Sent, https://bsch.serving-sys.com/serving/adServer.bs?cn=display&c=19&mc=imp&pli=21977036&PluID=0&ord=__TIME__&rtu=-1&mb=1
sent impression to https://bsch.serving-sys.com/serving/adServer.bs?cn=display&c=19&mc=imp&pli=21977036&PluID=0&ord=__TIME__&rtu=-1&mb=1&fttime=150115448879042
2017-07-27 19:21:29.412 Page[1222] <Warning> [Firebase/Analytics][I-ACS032003] iAd framework is not linked. Search Ad Attribution Reporter is disabled.
2017-07-27 19:21:29.421 Page[1222] <Notice> [Firebase/Analytics][I-ACS023012] Firebase Analytics enabled
update UI from the internet with https://danla2f5eudt1.cloudfront.net/index.php/jsapi/home
User is on Wifi, Continue to prefetch content
File needs to be downloaded. id: 001073566, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073566
File needs to be downloaded. id: 001073556, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073556
File needs to be downloaded. id: 001073549, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073549
File needs to be downloaded. id: 001073584, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073584
File needs to be downloaded. id: 001073583, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073583
File needs to be downloaded. id: 001073563, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073563
File needs to be downloaded. id: 001073575, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073575
File needs to be downloaded. id: 001073573, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073573
File needs to be downloaded. id: 001073564, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073564
File needs to be downloaded. id: 001073568, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073568
File needs to be downloaded. id: 001073560, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073560
File needs to be downloaded. id: 001073571, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073571
File needs to be downloaded. id: 001073562, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073562
File needs to be downloaded. id: 001073579, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073579
File needs to be downloaded. id: 001073567, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073567
File needs to be downloaded. id: 001073570, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073570
File needs to be downloaded. id: 001073569, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073569
File needs to be downloaded. id: 001073572, type: story, api url is https://danla2f5eudt1.cloudfront.net/index.php/jsapi/get_story_more_info/001073572
Launch Ad Closed Successfully! 
2017-07-27 19:21:39.619 Page[1222:11198] *** Assertion failure in -[UICollectionViewData invalidateItemsAtIndexPaths:], /BuildRoot/Library/Caches/com.apple.xbs/Sources/UIKit_Sim/UIKit-3600.7.47/UICollectionViewData.m:150
2017-07-27 19:21:39.640 Page[1222:11198] WARNING: GoogleAnalytics 3.17 void GAIUncaughtExceptionHandler(NSException *) (GAIUncaughtExceptionHandler.m:48): Uncaught exception: attempting to invalidate an item at an invalid indexPath: <NSIndexPath: 0xc000000002400316> {length = 2, path = 3 - 18} globalIndex: 28 numItems: 28
2017-07-27 19:21:39.683 Page[1222:11198] invalid mode 'kCFRunLoopCommonModes' provided to CFRunLoopRunSpecific - break on _CFRunLoopError_RunCalledWithInvalidMode to debug. This message will only appear once per execution.
2017-07-27 19:21:44.656 Page[1222:11198] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'attempting to invalidate an item at an invalid indexPath: <NSIndexPath: 0xc000000002400316> {length = 2, path = 3 - 18} globalIndex: 28 numItems: 28'
*** First throw call stack:
(
	0   CoreFoundation                      0x0000000102feeb0b __exceptionPreprocess + 171
	1   libobjc.A.dylib                     0x000000010587e141 objc_exception_throw + 48
	2   CoreFoundation                      0x0000000102ff2cf2 +[NSException raise:format:arguments:] + 98
	3   Foundation                          0x0000000105418536 -[NSAssertionHandler handleFailureInMethod:object:file:lineNumber:description:] + 193
	4   UIKit                               0x0000000104477c0c -[UICollectionViewData invalidateItemsAtIndexPaths:] + 626
	5   UIKit                               0x000000010443a80f __41-[UICollectionView _invalidateWithBlock:]_block_invoke + 21
	6   UIKit                               0x000000010443a80f __41-[UICollectionView _invalidateWithBlock:]_block_invoke + 21
	7   UIKit                               0x000000010443a80f __41-[UICollectionView _invalidateWithBlock:]_block_invoke + 21
	8   UIKit                               0x000000010443a80f __41-[UICollectionView _invalidateWithBlock:]_block_invoke + 21
	9   UIKit                               0x000000010443a80f __41-[UICollectionView _invalidateWithBlock:]_block_invoke + 21
	10  UIKit                               0x000000010441e731 -[UICollectionView _updateVisibleCellsNow:] + 12304
	11  UIKit                               0x000000010442238e -[UICollectionView layoutSubviews] + 313
	12  UIKit                               0x0000000103ba855b -[UIView(CALayerDelegate) layoutSublayersOfLayer:] + 1268
	13  QuartzCore                          0x000000010745a904 -[CALayer layoutSublayers] + 146
	14  QuartzCore                          0x000000010744e526 _ZN2CA5Layer16layout_if_neededEPNS_11TransactionE + 370
	15  QuartzCore                          0x000000010744e3a0 _ZN2CA5Layer28layout_and_display_if_neededEPNS_11TransactionE + 24
	16  QuartzCore                          0x00000001073dde92 _ZN2CA7Context18commit_transactionEPNS_11TransactionE + 294
	17  QuartzCore                          0x000000010740a130 _ZN2CA11Transaction6commitEv + 468
	18  QuartzCore                          0x00000001073676cf _ZN2CA7Display11DisplayLink14dispatch_itemsEyyy + 601
	19  CoreFoundation                      0x0000000102f81b61 __CFMachPortPerform + 161
	20  CoreFoundation                      0x0000000102f81aa9 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__ + 41
	21  CoreFoundation                      0x0000000102f81a21 __CFRunLoopDoSource1 + 465
	22  CoreFoundation                      0x0000000102f79ba0 __CFRunLoopRun + 2352
	23  CoreFoundation                      0x0000000102f79016 CFRunLoopRunSpecific + 406
	24  GraphicsServices                    0x00000001098c3a24 GSEventRunModal + 62
	25  UIKit                               0x0000000103ae5134 UIApplicationMain + 159
	26  Page                                0x0000000101cd6397 main + 55
	27  libdyld.dylib                       0x000000010889965d start + 1
	28  ???                                 0x0000000000000001 0x0 + 1
)
libc++abi.dylib: terminating with uncaught exception of type NSException
(lldb) 


