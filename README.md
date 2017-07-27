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

### Channel Page Collection View on iPad: 
1. Done: Stop using auto-resizing cells on Regular size. 
2. Use prefetch to make scrolling smooth. 
3. FT Academy
4. FT Intelligence
5. Most Popular
6. Calendar


### Channel Structure: Xiangyun
1. In Progress: The final correct channel structure. 
2. Done: Retrieve and convert other types of API. 

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
