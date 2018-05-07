# New FTChinese iOS App

## Overall Goal

There are a thousand details that you need to pay attention to for an app to work properly. These, like sharing, push notification, swiping between pages are basically the same thing. But it takes a lot of repetitive work to make everything right. 

The aim of this project is to get rid of the trouble of reinventing wheels so that you, the developer, can focus on the unique features of your app. Using it as a "scalfold", a seasoned iOS SWIFT developer should be able to build a decent news app in a few minutes. 

For now, it does the following things: 

## News App With Enough Functionalities
### News reader
### Billigual uupport
### Swipe between channels and pieces of content
### Advertising: including launch ad, in page, banners, MPUs and paid post
### In-app purchase: buying, downloading. 
### In-app purchase: autorenewing subscription. 

## Some good features
### All possible customizations in one place: You just need to replicate the target "ftchinese"
### Smooth Panning between content
### Pull to refresh
### JSON formating that supports as many as possible APIs
### Newspaper experience on iPad

## Future development
### Infinite Scrolling for page that uses collection view

## Pitfalls: What we learned the hard way
### Dynamic Type Support: 
It is more trouble than it's worth. We implemented for a while but readers don't understand why the fonts become so large even though they set it by themselves. It is good intension, but users don't buy it. They just think your design is bad. 

### WKWebView VS Collection View: 
If you want to build anything more complicated than the current FTChinese news app, then I'd suggest that you use HTML (WKWebView) as much as possible, rather than Collection View or Table View. The problem with collection view is that it is hard to make it scrolling smoothly, despite what you heard in WWDC. 

As a proof, you can look at other apps developed by the world's best iOS developers such as WeChat, PodCast, Apple App Store. Scoll their home and list screens. Then launch the FTChinese app and compare the smoothness. Once you notice the difference, it's hard to un-notice it. 

The FTChinese allows you to use collection view to display list screens. But we suggest that you stick to WKWebView as much as possible. For advanced iOS developers, you can use profilling to check the difference between collection view and WKWebView. 

### Sharing: 
If a large chunk of your audience is in China, you should use WeChat and Weibo's SDK rather than their share extension for sharing. And you should use a customized action sheet view controller rather than the iOS one. There are serious bugs with the share extensions and there's no way to hide any share extension from the iOS' default action view controller. If user experiences bugs after they share, they blame you, not Apple, WeChat and Weibo. So my advice is, use your own share sheet and fall back to iOS develop activity view controller. 

### Always Validate: 
As a client side, don't blindly trust anyone or anything, not even your own servers. If you have large audience in China, that's especially true. For example, what can go wrong with an HTML snippet of less than 10k? According to our own tracking, it returns wrong results 5000 times a day. (Yes, the server guy should fix it. But the client should validate. ) If we don't validate every HTML snippet we get, some users are going to be really upset. 

### Avoid dependency as much as as possible: 
Depending on code writen by others can be easy at the start but brings a lot of pain along the way. Take the example of an e-pub reader. When you install it through cocoapods, it automatically adds another 8 dependencies for you. This makes your app build very slow and adds another 10 MB to your app size, which is big deal. What if the code that you depend on stopped upgraging to the latest SWIFT? What if the code has bug that causes fatal run-time error? So I depend on things only when I have to. That means only three SDKs: WeChat, Google Analytics and Weibo. 


## How To Start
$ sudo gem install cocoapods

$ pod install --repo-update

$ open Page.xcworkspace

For more, check out [Cocoa Pod](https://cocoapods.org/)


## Deprecated: Development Milestones moved to Redmine

### Channel Page: 
1. Done: Stop using auto-resizing cells on Regular size. 
2. Done: Use prefetch to make scrolling smooth. 
3. Done: FT Academy
4. Done: FT Intelligence
5. Done: Most Popular
6. Done: Videos
7. Done: Calendar
8. Done: Title View: Image for News Channel
9. Rejected: Infinite Scrolling in Home and Channel Pages
10. Done: Make all channel pages available


### Done: APIs
1. Done: Stories
2. Done: Retrieve and convert other types of API. 
3. Done: Interactive Features
4. Done: Videos: 
5. Done: Switch Between Domains for APIs
6. Done: Stories By Date


### Done: Advertising: 
1. Done: Retrieve Ad info from Dolphin's script string
2. Done: Send third party impressions until they are confirmed
3. Done: Tap link for Ad Views
4. Done: Tap Link in content view
5. Done: Launch Screen Ad
6. Done: Native Banner
7. Done: Web Banner
8. Done: Paid Post
9. Done: Show Image if there's time
10. Done: Parse Video Ad into native
11. Special Report: Adjustment based on API
12. Done: In-Page Full Screen: Disable Close Button and Function
13. Done: MPU New: Adjustment based on Date
14. Done: Implement new ad setting


### Content Page: 
1. Done: Come up with bilingual and english switch. 
2. Done: Functionalities and buttons. 
3. Done: Video. 
4. Done: Interactive Features. 
5. Done: custom link
6. Done: Handle Story Links
7. Done: Handle video and interative links
8. Done: Handle Tag Links
9. Done: Offline and Caches for Content
10. Done: A progress indicator untill web page is completely updated
11. Done: Full Screen Ad
12. If an interactive is a speedread, let it read the english text
13. Hide/show sound button properly
14. Done: Tag page should show title in navigation
15. Done: Add new layout to display all cover
16. Done: User comments
17. Done: Display column layout on iPad
18. Done: Show Font Size preference


### Done: Sharing
1. Done: WeChat
2. Done: Need Check: Built-ins

### Done: Tracking
1. Done: Google
2. Done: FTC's own tracking

### AI
1. Done: Chat Room
2. Customer Service
3. Rejected: Recommendation

### Core data

### Done: Notifications
1. Done: Handle Notification Types
2. Done: Move Notification Extensions

### Done: Today Widget

### Done: In-App Purchase: StoreKit
1. Done: eBook
2. Done: eReader

### Done: myFT
1. Done: Follow: Save the preference as a Dictionary. a. In content page; b. In MyFT Page Channel List
2. Done: Clippings
3. Done: Read
4. Done: API: If there's under 5 follows, request all of them as one request. Otherwise request the latest 10000 items and filter them 
1. Done: 电子书阅读
3. Done: Big 5 Version
4. Done: 恢复购买
2. Done: 金融英语速读无法评论


Data View: 
1. Done: Watch List
2. Done: Reading History
3. Done: Login and Register
4. Done: My Subscription

### Done: Big 5 Version: https://github.com/Insfgg99x/FGReverser

## Completed Tasks

### In-App Purchase

### Done: Search




### Login and Registration
1. Done: Normal Login
2. Done: Normal Registration
3. Done: WeChat


### Audio
1. Done: Speech to Text
2. Done: Radio

### Offline and Caches
1. Done: Channel
2. Done: Content
3. Done: Clean
4. Done: Prefetch

### Other Tasks: 
1. Done: Video Page Take Full Screen Width 
2. Done: Send third party impressions until they are confirmed
3. Done: Tap link for Ad Views
1. Done: Workspace
2. Done: Cocoa Pod
3. Done: Google Analytics
2. Done: Tracking Third Party Ad impression with native code
3. Done: WeChat Share 
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

### Bug List: 
1. Done: Why can't MyFT be stored locally? It's because file name is not correct. 
1. Done: 金融英语速读无法调整字号：创建设置页面
4. Done: 每日英语双语阅读的Switch颜色需要更换
5. Done: 视频的Bug：退出页面还在播，已经翻页的还在播放
6. Done: 下啦刷新设置页面