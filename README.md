# New FTChinese iOS App

## Development Milestones
### Task at Hand: 
1. Done: Make all channel pages available
2. Update Ads
3. Big 5 Version
4. 恢复购买
5. 高端会员

### Bugs
1. 金融英语速读无法调整字号：创建设置页面
2. 金融英语速读无法评论
3. 金融英语速读无法听
4. Done: 每日英语双语阅读的Switch颜色需要更换
5. Done: 视频的Bug：退出页面还在播，已经翻页的还在播放

### Channel Page: 
1. Done: Stop using auto-resizing cells on Regular size. 
2. Done: Use prefetch to make scrolling smooth. 
3. FT Academy
4. FT Intelligence
5. Most Popular
6. Videos
7. Calendar
8. Done: Title View: Image for News Channel
9. Infinite Scrolling in Home and Channel Pages


### APIs
1. Done: Stories
2. Done: Retrieve and convert other types of API. 
3. Interactive Features
4. Videos: 
5. Switch Between Domains for APIs
6. Stories By Date


### Advertising: 
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
13. MPU New: Adjustment based on Date


### Content Page: 
1. Done: Come up with bilingual and english switch. 
2. Functionalities and buttons. 
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
17. Display column layout on iPad
18. Done: Show Font Size preference


### Sharing
1. Done: WeChat
2. Done: Need Check: Built-ins

### Tracking
1. Done: Google
2. FTC's own tracking

### AI
1. Chat Room
2. Customer Service
3. Recommendation

### Core data

### Notifications
1. Done: Handle Notification Types
2. Done: Move Notification Extensions

### Done: Today Widget

### In-App Purchase: StoreKit
1. Done: eBook
2. Done: eReader

### Done: myFT
1. Done: Follow: Save the preference as a Dictionary. a. In content page; b. In MyFT Page Channel List
2. Done: Clippings
3. Done: Read
4. API: If there's under 5 follows, request all of them as one request. Otherwise request the latest 10000 items and filter them 

Data View: 
1. Watch List
2. Reading History
3. Login and Register
4. My Subscription

### Big 5 Version: https://github.com/Insfgg99x/FGReverser

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
### Dynamic Type Support
### Autorenewing Subscription
### JSON formating that supports as many as possible APIs
### Newspaper experience on iPad


