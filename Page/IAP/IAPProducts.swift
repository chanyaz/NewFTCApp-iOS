// MARK: - IAP Tutorial 2: FTC's IAP Products Data

import Foundation

public struct IAPProducts {
    // MARK: Store all products locally to avoid networking problems
    private static let subscriptionsData = [
        [
            "id":"com.ft.ftchinese.mobile.subscription.intelligence3",
            "title":"FT研究院",
            "teaser":"中国商业和消费数据",
            "image":"http://i.ftimg.net/picture/3/000068413_piclink.jpg",
            "period":"year"
        ]
    ]
    
    private static let membershipData = [
        [
            "id":"com.ft.ftchinese.mobile.subscription.member",
            "title":"普通会员",
            "teaser":"",
            "image":"http://i.ftimg.net/picture/6/000068886_piclink.jpg",
            "period":"year",
            "benefits": [
                "阅读FT中文网所有独家内容",
                "收听英文文章音频"
            ],
            "privilege": Privilege(adDisplay: .reasonable, englishText: true, englishAudio: true, exclusiveContent: true, editorsChoice: false)
        ],
        [
            "id":"com.ft.ftchinese.mobile.subscription.vip",
            "title":"高端会员",
            "teaser":"",
            "image":"http://i.ftimg.net/picture/6/000068886_piclink.jpg",
            "period":"year",
            "benefits": [
                "《FT编辑精选》，每周不可错过的独家必读内容",
                "获得两张价值3999元的FT中文网年会门票",
                "阅读FT中文网所有独家内容",
                "收听英文文章音频"
            ],
            "privilege": Privilege(adDisplay: .reasonable, englishText: true, englishAudio: true, exclusiveContent: true, editorsChoice: true)
        ]
//        [
//            "id":"com.ft.ftchinese.mobile.subscription.diamond",
//            "title":"钻石会员",
//            "teaser":"",
//            "image":"http://i.ftimg.net/picture/6/000068886_piclink.jpg",
//            "period":"year",
//            "benefits": [
//                "《FT投资参考》和《FT科技季刊》",
//                "《FT周刊》，精选不可错过的必读内容",
//                "两张张价值9999元的FT中文网年会贵宾门票",
//                "阅读FT中文网所有独家内容",
//                "订制内容推送到客户端"
//            ],
//            "privilege": Privilege(adDisplay: .reasonable, englishText: true, englishAudio: true, exclusiveContent: true, editorsChoice: true)
//        ]
        //        [
        //            "id":"com.ft.ftchinese.mobile.subscription.trial",
        //            "title":"试读会员",
        //            "teaser":"注册成为试读会员",
        //            "image":"http://i.ftimg.net/picture/6/000068886_piclink.jpg",
        //            "period":"month",
        //            "benefits": [
        //                "1个月内屏蔽部分网站广告，升级阅读体验",
        //                "会员期间免费阅读4篇付费内容",
        //                "可选择开启手机客户端专属订制内容推送，你感兴趣的不再错过"
        //            ]
        //        ]
    ]
    
    private static let eBooksData = [
        [
            "id":"com.ft.ftchinese.mobile.book.yearbook2018",
            "title":"2017: 自信下的焦虑",
            "teaser":"FT中文网2017年刊",
            "description": "<p>回顾2017年FT中文网最受读者关注的内容，“中国的地缘政治局势”和“中国（中国人）在当今世界的地位”两大主题稳居榜首。 地缘政治方面，尽管南海局势出现缓和迹象，但从金正男遇刺到朝鲜多次核试验、洲际导弹试射，半岛局势一系列令人瞠目结舌的戏剧性发展不断提醒中国人：家门口的危机从未真正缓和，摊牌之日正在逼近。西南方向，中印两国在洞朗地区的军事对峙一度剑拔弩张，引发了国际市场对亚洲两大新兴经济体前途的担忧。与此同时，中国的相对西方的迅速崛起以及官方主导的“软实力”对外输出不但引发西方的强烈反弹，也凸显了正在大步“走出去”的中国人之种种矛盾心态。</p><p>2017年又是中国国内政经局势的定调之年。中共19大对高度集权的确认，仅仅缓解了国内外观察者的部分担忧；从经济何时触底到产业政策、楼市走向、教育改革，更多令人焦虑的问题随之而来。到了2017年下半年，多地爆出的幼儿园虐童丑闻和北京等大城市的“赶人”争议，令国人焦虑心态集中爆发。从看似光鲜的城市中产到苦苦追求生活改善的低收入、流动人口，不同阶层都意识到了自己“中国梦”的脆弱一面。</p>",
            "image":"http://i.ftimg.net/picture/9/000074679_piclink.jpg",
            "download": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=yearbook2018&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&018",
            "downloadfortry": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=yearbook2018&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&018"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.yearin2018",
            "title":"2017: 自信下的焦虑",
            "teaser":"FT中文网2017年刊",
            "description": "<p>回顾2017年FT中文网最受读者关注的内容，“中国的地缘政治局势”和“中国（中国人）在当今世界的地位”两大主题稳居榜首。 地缘政治方面，尽管南海局势出现缓和迹象，但从金正男遇刺到朝鲜多次核试验、洲际导弹试射，半岛局势一系列令人瞠目结舌的戏剧性发展不断提醒中国人：家门口的危机从未真正缓和，摊牌之日正在逼近。西南方向，中印两国在洞朗地区的军事对峙一度剑拔弩张，引发了国际市场对亚洲两大新兴经济体前途的担忧。与此同时，中国的相对西方的迅速崛起以及官方主导的“软实力”对外输出不但引发西方的强烈反弹，也凸显了正在大步“走出去”的中国人之种种矛盾心态。</p><p>2017年又是中国国内政经局势的定调之年。中共19大对高度集权的确认，仅仅缓解了国内外观察者的部分担忧；从经济何时触底到产业政策、楼市走向、教育改革，更多令人焦虑的问题随之而来。到了2017年下半年，多地爆出的幼儿园虐童丑闻和北京等大城市的“赶人”争议，令国人焦虑心态集中爆发。从看似光鲜的城市中产到苦苦追求生活改善的低收入、流动人口，不同阶层都意识到了自己“中国梦”的脆弱一面。</p>",
            "image":"http://i.ftimg.net/picture/9/000074679_piclink.jpg",
            "download": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=yearbook2017&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&020",
            "downloadfortry": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=yearbook2017&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&020"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.magazine",
            "title":"生活时尚·旅行特刊",
            "teaser":"探寻世界的尽头",
            "image":"http://i.ftimg.net/picture/4/000073894_piclink.jpg",
            "download": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10582_bodyonly.html",
            "downloadfortry": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10582_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.magazine2",
            "title":"如何在“人工智能”时代生存？——创新经济特刊",
            "teaser":"终身学习，是我们在人工智能时代的宿命",
            "image":"http://i.ftimg.net/picture/7/000073887_piclink.jpg",
            "download": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10584_bodyonly.html",
            "downloadfortry": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10584_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.career",
            "title":"管理·性别与职场",
            "teaser":"职场女性生存指南",
            "image":"http://i.ftimg.net/picture/7/000073927_piclink.jpg",
            "download": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10595_bodyonly.html",
            "downloadfortry": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10595_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.economy1",
            "title":"10年，金融危机为我们留下了什么？",
            "teaser":"世界经济·第1辑",
            "image":"http://i.ftimg.net/picture/3/000073933_piclink.jpg",
            "download": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10598_bodyonly.html",
            "downloadfortry": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10598_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.economy2",
            "title":"2018，掘金中国股市？",
            "teaser":"中国经济·第1辑",
            "image":"http://i.ftimg.net/picture/9/000073929_piclink.jpg",
            "download": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10599_bodyonly.html",
            "downloadfortry": "https://d1h6mhhb33bllx.cloudfront.net/ibook/10599_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.dailyenglish1",
            "title":"读《金融时报》学英语（一）",
            "teaser":"挑选FT每日英语文章精华，集结成册",
            "image":"http://i.ftimg.net/picture/5/000074025_piclink.jpg",
            "download": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=ebook-english-1&bodyonly=yes&webview=ftcapp&ad=no&013",
            "downloadfortry": "https://d1budb999l6vta.cloudfront.net/m/corp/preview.html?pageid=ebook-english-1&bodyonly=yes&webview=ftcapp&ad=no&try=yes&013"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.lunch1",
            "title":"与FT共进午餐（一）",
            "teaser":"英国《金融时报》最受欢迎的栏目",
            "image":"http://i.ftimg.net/picture/2/000068702_piclink.jpg",
            "download": "https://d1h6mhhb33bllx.cloudfront.net/lunch1_body.html",
            "downloadfortry": "https://d1h6mhhb33bllx.cloudfront.net/lunch1Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.lunch2",
            "title":"与FT共进午餐（二）",
            "teaser":"英国《金融时报》最受欢迎的栏目",
            "image":"http://i.ftimg.net/picture/3/000068703_piclink.jpg",
            "download": "https://d1h6mhhb33bllx.cloudfront.net/lunch2_body.html",
            "downloadfortry": "https://d1h6mhhb33bllx.cloudfront.net/lunch2Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.OutlookoftheFutureof2017",
            "title":"精选2016，展望2017",
            "teaser":" 2017年，我们熟悉的那个世界是否正在远去？",
            "image":"http://i.ftimg.net/picture/9/000068669_piclink.jpg",
            //"download": "https://danla2f5eudt1.cloudfront.net/channel/html-book-teawithft.html",
            //"downloadfortry": "https://danla2f5eudt1.cloudfront.net/channel/html-book-teawithft.html"
            "download": "https://d1h6mhhb33bllx.cloudfront.net/10430_body.html",
            "downloadfortry": "https://d1h6mhhb33bllx.cloudfront.net/10430_Preview.html"
        ]
    ]
    
    public static let finePrintItems = [
        (headline: "订阅价格与周期", lead: "您可以在应用内订阅《FT中文网会员》和《FT中文网高端会员》两种服务。《FT中文网会员》每年订阅价格为 198元（$28.99），订阅后您可以解锁阅读FT中文网每日新增的两篇独家文章内容，以及解锁双语文章的英语语音服务。《FT中文网高端会员》每年订阅价格为 1998元（$294.99），订阅后您可以解锁《FT中文网会员》提供的所有服务，再加上每周的《编辑精选》周刊。"),
        (headline: "付费方式", lead: "购买流程完全由Apple完成。您将通过Apple的iTunes账号，在确认购买成功之后完成支付。根据Apple的规定，在购买成功之后，您之前的试用期限（如果有）将被清零。"),
        (headline: "关于自动续订", lead: "苹果 App Store 官方订阅功能为自动续费订阅。用户需手动在 iTunes 账户设置管理中关闭自动续订功能, 如果订阅期结束前的一天内未关闭自动续订功能, 订阅周期会自动延续。"),
        (headline: "跨设备获取已订阅内容", lead: "《FT中文网会员》和《FT中文网高端会员》两种服务都适用于 iPhone 和 iPad，你的订阅可以同时在 iPhone/iPad 上使用。如果你已经在 iPad 上订阅, 在 iPhone 上, 请选择「恢复订阅」以查看已订阅内容；反之亦然。")
    ]
    
    // MARK: - update JSCode for displaying on WKWebView
    public static func updateHome(for type: String) -> String {
        let hightlightIds = ["com.ft.ftchinese.mobile.book.yearin2018"]
        let highlightJSON = IAP.getJSON(IAPs.shared.products, in: type, shuffle: true, filter: hightlightIds)
        let hightJSCode = JSCodes.get(in: "iap-highlight", with: highlightJSON, where: "center")
        let ids = [
            "com.ft.ftchinese.mobile.book.magazine",
            "com.ft.ftchinese.mobile.book.magazine2",
            "com.ft.ftchinese.mobile.book.career",
            "com.ft.ftchinese.mobile.book.economy1",
            "com.ft.ftchinese.mobile.book.economy2",
            "com.ft.ftchinese.mobile.book.dailyenglish1"
        ]
        let json = IAP.getJSON(IAPs.shared.products, in: type, shuffle: true, filter: ids)
        let jsCode = JSCodes.get(in: "iap-ebooks", with: json, where: "rail")
        let finalJsCode = "\(hightJSCode)\(jsCode)"
        IAPs.shared.jsCodes = finalJsCode
        return finalJsCode
    }
    
    // MARK: - Add product group names and titles
    public static let subscriptions = addProductGroup(subscriptionsData, group: "subscription", groupTitle: "订阅")
    public static let eBooks = addProductGroup(eBooksData, group: "ebook", groupTitle: "FT电子书")
    public static let memberships = addProductGroup(membershipData, group: "membership", groupTitle: "会员")
    
    // MARK: - The screen name for membership subscription view
    public static let membershipScreenName = "myft/membership"
    
    // MARK: - Combine all types of products into one and request for more information, such as price, from app store
    public static let allProducts = memberships + subscriptions + eBooks
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = getProductIds(products: allProducts)
    public static let store = IAPHelper(productIds: productIdentifiers)
    
    public static let serverUrlString = "https://api.ftmailbox.com/ios-receipt-validation.php"
    
    fileprivate static func addProductGroup(_ products:  [Dictionary<String, Any>], group: String, groupTitle: String) -> [Dictionary<String, Any>]{
        var newProducts:  [Dictionary<String, Any>] = []
        for product in products {
            var newProduct = product
            newProduct["group"] = group
            newProduct["groupTitle"] = groupTitle
            newProducts.append(newProduct)
        }
        return newProducts
    }
    
    fileprivate static func getProductIds(products: [Dictionary<String, Any>]) -> Set<ProductIdentifier> {
        var productIds: Set<ProductIdentifier> = []
        for product in products {
            if let productId = product["id"] as? String {
                productIds.insert(productId)
            }
        }
        return productIds
    }
}
