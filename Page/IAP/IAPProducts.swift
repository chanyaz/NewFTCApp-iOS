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
            "title":"标准会员",
            "teaser":"",
            "image":"http://i.ftimg.net/picture/6/000068886_piclink.jpg",
            "period":"year",
            "benefits": [
                "精选深度分析",
                "中英双语内容",
                "金融英语速读训练",
                "英语原声电台",
                "无限浏览7日前所有历史文章（近8万篇）"
            ],
            "key": "standard",
            "privilege": Privilege(adDisplay: .reasonable, englishText: true, englishAudio: true, exclusiveContent: true, editorsChoice: false, speedreading: true, radio: true, archive: true, book: false)
        ],
        [
            "id":"com.ft.ftchinese.mobile.subscription.vip",
            "title":"高端会员",
            "teaser":"",
            "image":"http://i.ftimg.net/picture/6/000068886_piclink.jpg",
            "period":"year",
            "benefits": [
                "享受“标准会员”所有权益",
                "编辑精选，总编/各版块主编每周五为您推荐本周必读资讯，分享他们的思想与观点",
                "FT中文网2018年度论坛门票2张，价值3,999元/张（不包含食宿差旅）"
            ],
            "key": "premium",
            "privilege": Privilege(adDisplay: .reasonable, englishText: true, englishAudio: true, exclusiveContent: true, editorsChoice: true, speedreading: true, radio: true, archive: true, book: true)
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
    ]
    
    private static let eBooksData = [
        [
            "id":"com.ft.ftchinese.mobile.book.bubble",
            "title":"是非区块链：技术、投机与泡沫",
            "teaser":"英国《金融时报》为您呈上的此书，为您在了解分析区块链、比特币甚至ICO提供更全面的参考。",
            "description": "<p>区块链，作为一项被预测为会对社会和商业带来巨大变革的新技术，因比特币的一路暴涨和各类数字代币的发行而热度不减。区块链技术的应用和探索会走向何方？比特币的暴涨趋势是否还会延续？数字代币究竟是投资风口，还是一种新型网络诈骗？英国《金融时报》为您呈上此书，为您在了解分析区块链、比特币甚至ICO提供更全面的参考。</p>",
            "image":"https://creatives002.ftimg.net/bubble.jpg",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooksfqkljstjypm&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&013",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooksfqkljstjypm&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&013"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.democracy",
            "title":"英国脱欧：民主的胜利还是失败？",
            "teaser":"我们呈上这本小书，希望能帮助您对英国公投脱离欧盟做出自己的思考和判断。",
            "description": "<p>英国公投脱离欧盟，震动世界。有人惊叹，英国人明知脱欧会给英国造成伤害，却“任性出走”，是民粹主义卷土重来、精英政治和代议民主失败的明证。有人担忧，英国人再次选择“光荣孤立”于欧洲之外，标志着几十年来作为世界发展基石的全球化进程出现大逆转。</p><p>英国人真的在自掘坟墓吗？他们还有后悔药可吃吗？民粹主义抬头，是否意味着民主政治的溃败？英国和欧盟的分手，会对世界地缘政治，尤其是中国的全球地位，带来怎样的影响？</p><p>我们呈上这本小书，希望能帮助您对这些问题做出自己的思考和判断。</p>",
            "image":"https://creatives002.ftimg.net/democracy.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookygtomzdslhssb&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&027",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookygtomzdslhssb&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&027"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.ob5",
            "title":"牛津女学霸的30年职场观察录 5",
            "teaser":"我们推出的露西·凯拉韦(Lucy Kellaway)的专栏精选集，献给在职场中进击的你。",
            "description": "<p>牛津毕业的露西·凯拉韦(Lucy Kellaway)曾是英国《金融时报》明星专栏作家,为这家百年老报撰写职场和管理专栏长达25年，直到2017年夏天，她出人意料地离开FT，转行做起了中学数学教师。她解释说：在“旁观”职场多年后，她希>望能投身其中，真正做些什么。</p><p>FT中文网多年来持续翻译露西的专栏，她在中国也拥有众多忠实读者。</p><p>她善于从办公室生活的点滴中探索人性，不吝于分享自己对职业生涯的烦恼和感悟。</p><p>她大胆取笑企业宣传中华丽而空洞的辞藻，戳穿职场文化中的伪善和潜规则。</p><p>她不断记录新的技术、时尚、社会变迁如何影响职场生态，以及人与人的相处方式。</p><p>她的语言犀利幽默，常常让人在莞尔中深思。她转行做老师的决定，让许多拥趸在最初的失望后又为她击掌叫好。</p><p>在她离开FT之际，我们推出她的专栏精选集，献给在职场中进击的你。</p>",
            "image":"https://creatives002.ftimg.net/ob.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl5&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&026",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl5&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&026"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.ob4",
            "title":"牛津女学霸的30年职场观察录 4",
            "teaser":"我们推出的露西·凯拉韦(Lucy Kellaway)的专栏精选集，献给在职场中进击的你。",
            "description": "<p>牛津毕业的露西·凯拉韦(Lucy Kellaway)曾是英国《金融时报》明星专栏作家,为这家百年老报撰写职场和管理专栏长达25年，直到2017年夏天，她出人意料地离开FT，转行做起了中学数学教师。她解释说：在“旁观”职场多年后，她希>望能投身其中，真正做些什么。</p><p>FT中文网多年来持续翻译露西的专栏，她在中国也拥有众多忠实读者。</p><p>她善于从办公室生活的点滴中探索人性，不吝于分享自己对职业生涯的烦恼和感悟。</p><p>她大胆取笑企业宣传中华丽而空洞的辞藻，戳穿职场文化中的伪善和潜规则。</p><p>她不断记录新的技术、时尚、社会变迁如何影响职场生态，以及人与人的相处方式。</p><p>她的语言犀利幽默，常常让人在莞尔中深思。她转行做老师的决定，让许多拥趸在最初的失望后又为她击掌叫好。</p><p>在她离开FT之际，我们推出她的专栏精选集，献给在职场中进击的你。</p>",
            "image":"https://creatives002.ftimg.net/ob.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl4&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&025",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl4&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&025"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.ob3",
            "title":"牛津女学霸的30年职场观察录 3",
            "teaser":"我们推出的露西·凯拉韦(Lucy Kellaway)的专栏精选集，献给在职场中进击的你。",
            "description": "<p>牛津毕业的露西·凯拉韦(Lucy Kellaway)曾是英国《金融时报》明星专栏作家,为这家百年老报撰写职场和管理专栏长达25年，直到2017年夏天，她出人意料地离开FT，转行做起了中学数学教师。她解释说：在“旁观”职场多年后，她希>望能投身其中，真正做些什么。</p><p>FT中文网多年来持续翻译露西的专栏，她在中国也拥有众多忠实读者。</p><p>她善于从办公室生活的点滴中探索人性，不吝于分享自己对职业生涯的烦恼和感悟。</p><p>她大胆取笑企业宣传中华丽而空洞的辞藻，戳穿职场文化中的伪善和潜规则。</p><p>她不断记录新的技术、时尚、社会变迁如何影响职场生态，以及人与人的相处方式。</p><p>她的语言犀利幽默，常常让人在莞尔中深思。她转行做老师的决定，让许多拥趸在最初的失望后又为她击掌叫好。</p><p>在她离开FT之际，我们推出她的专栏精选集，献给在职场中进击的你。</p>",
            "image":"https://creatives002.ftimg.net/ob.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl3&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&024",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl3&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&024"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.ob2",
            "title":"牛津女学霸的30年职场观察录 2",
            "teaser":"我们推出的露西·凯拉韦(Lucy Kellaway)的专栏精选集，献给在职场中进击的你。",
            "description": "<p>牛津毕业的露西·凯拉韦(Lucy Kellaway)曾是英国《金融时报》明星专栏作家,为这家百年老报撰写职场和管理专栏长达25年，直到2017年夏天，她出人意料地离开FT，转行做起了中学数学教师。她解释说：在“旁观”职场多年后，她希>望能投身其中，真正做些什么。</p><p>FT中文网多年来持续翻译露西的专栏，她在中国也拥有众多忠实读者。</p><p>她善于从办公室生活的点滴中探索人性，不吝于分享自己对职业生涯的烦恼和感悟。</p><p>她大胆取笑企业宣传中华丽而空洞的辞藻，戳穿职场文化中的伪善和潜规则。</p><p>她不断记录新的技术、时尚、社会变迁如何影响职场生态，以及人与人的相处方式。</p><p>她的语言犀利幽默，常常让人在莞尔中深思。她转行做老师的决定，让许多拥趸在最初的失望后又为她击掌叫好。</p><p>在她离开FT之际，我们推出她的专栏精选集，献给在职场中进击的你。</p>",
            "image":"https://creatives002.ftimg.net/ob.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl2&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&023",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl2&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&023"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.ob1",
            "title":"牛津女学霸的30年职场观察录 1",
            "teaser":"我们推出的露西·凯拉韦(Lucy Kellaway)的专栏精选集，献给在职场中进击的你。",
            "description": "<p>牛津毕业的露西·凯拉韦(Lucy Kellaway)曾是英国《金融时报》明星专栏作家,为这家百年老报撰写职场和管理专栏长达25年，直到2017年夏天，她出人意料地离开FT，转行做起了中学数学教师。她解释说：在“旁观”职场多年后，她希望能投身其中，真正做些什么。</p><p>FT中文网多年来持续翻译露西的专栏，她在中国也拥有众多忠实读者。</p><p>她善于从办公室生活的点滴中探索人性，不吝于分享自己对职业生涯的烦恼和感悟。</p><p>她大胆取笑企业宣传中华丽而空洞的辞藻，戳穿职场文化中的伪善和潜规则。</p><p>她不断记录新的技术、时尚、社会变迁如何影响职场生态，以及人与人的相处方式。</p><p>她的语言犀利幽默，常常让人在莞尔中深思。她转行做老师的决定，让许多拥趸在最初的失望后又为她击掌叫好。</p><p>在她离开FT之际，我们推出她的专栏精选集，献给在职场中进击的你。</p>",
            "image":"https://creatives002.ftimg.net/ob.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl1&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&022",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooknjnxb30nzcgcl1&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&022"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.to",
            "title":"面对特朗普挑战，中国经济会走向何方？",
            "teaser":"2018年中国经济会走向何方？",
            "description": "<p>在中国经济增长放缓、去产能未见明显成效、税负日益难以承受、人民币不断贬值、资本加速外流之际，唐纳德·特朗普意外登上美国总统宝座又给中国带来了巨大的外部挑战，令中国经济雪上加霜。</p><p>特朗普奉行“美国优先”，力主制造业工作岗位回流美国，扬言对进口自中国的商品开征税率为45%的关税、要与中国打贸易战和货币战，他掀起的这股“逆全球化”潮流是否会给过去30年受益于全球化的中国造成严重打击？2018年中国经济会走向何方？</p>",
            "image":"https://creatives002.ftimg.net/to.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookmdtlptzzgjjhzxhf&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&019",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookmdtlptzzgjjhzxhf&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&019"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.trump",
            "title":"美国人为什么支持特朗普",
            "teaser":"谁是特朗普？如果您有此疑问，希望FT中文网为您精选出的这组文章能够给出您想要的答案。",
            "description": "<p>谁是特朗普？这个信口开河、制造分歧、身居“体制外”的美国总统参选人，为何突然之间就在共和党总统初选中成为了领跑者？他的拥趸只是些受教育程度和收入较低的美国蓝领白人吗？这个人真的当选了美国总统，会给美国社会以及国际政局带来什么影响？谁有能力阻挡他的脚步、击破他的总统梦？如果您有这些疑问，希望FT中文网为您精选出的这组文章能够给出您想要的答案。</p>",
            "image":"https://creatives002.ftimg.net/trump.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookmgrwsmzctlp&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&018",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookmgrwsmzctlp&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&018"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.vaccine",
            "title":"寻找安全的疫苗",
            "teaser":"我们选择的文章将帮助读者认清疫苗之争真相，同时思考深层次的医疗体制问题。",
            "description": "<p>“山东疫苗案”引发的恐慌遍及大江南北，剧情的不断反转和各方斗嘴更是令人嗔目结舌。在纷繁的线索中，我们如何理清头绪，如何看待疫苗争议及其背后的政府责任、科学与伦理关系。我们选择的文章将帮助读者认清疫苗之争真相，同时思考深层次的医疗体制问题。</p>",
            "image":"https://creatives002.ftimg.net/vaccine.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookxzaqdym&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&017",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookxzaqdym&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&017"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.ps",
            "title":"以邻为鉴：一位中国媒体人的日本观察",
            "teaser":"中国法律媒体人段宏庆以访问研究员的身份，学习、总结日本的经验，希望对中国社会的进步有所裨益。",
            "description": "<p>2016年底，中国法律媒体人段宏庆以访问研究员的身份，在东京大学东洋文化研究所度过三个月的时光。不会日语、此前也从未到过东京的他，用笔记录下了这段全新的生活。他关注日本的法律制度、社会问题、文化现象，希望通过完整呈现一个普通中国人观察、了解日本的过程，让更多中国人正确认识日本，更希望通过学习、总结日本的经验，对中国社会的进步有所裨益。</p>",
            "image":"https://creatives002.ftimg.net/ps.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookylwjywzgmtrdrbgc&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&016",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookylwjywzgmtrdrbgc&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&016"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.elegantly",
            "title":"职场女性：优雅地战斗",
            "teaser":"FT中文网精选近年好文，倾听女性自己的声音，与各行各业的卓越女性对话。",
            "description": "<p>又到“三八”国际劳动妇女节，一次庆祝女性在经济社会等各领域成就的隆重仪式，一场对女性爱与美的盛大告白。不过，不管过不过节，每天清早你睁眼面对的琐碎日常，都是一场场迷你的战斗。性别平等仍任重道远，社会对女性的偏见不一而足。FT中文网精选近年好文，倾听女性自己的声音，与各行各业的卓越女性对话，并尝试从学术视角解析两性差别及平权努力，希望职场中的你因自信和了解而更美。愿你能以优雅的姿势，在世俗的眼光中彪悍前行。</p>",
            "image":"https://creatives002.ftimg.net/elegantly.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookszcnxyydzd&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&015",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookszcnxyydzd&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&015"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.bj",
            "title":"拆分北京",
            "teaser":"被民间形象地解读为“北京迁出北京”这一政策,是否最终能达到决策层所期待的效果？",
            "description": "<p>2015年7月，中共北京市委宣布，北京将在通州区加快建设“行政副中心”，这一政策后来被民间形象地解读为“北京迁出北京”，或者说把“作为首都的北京”和“作为北京的北京”拆分开来。“迁出”和“拆分”对于北京这座城市来说，或许是必有之义。然而，这次大搬迁最终能否达到决策层所期待的效果？目前生活在北京市的两三千万人口，他们的生活已经、即将受到何种深远影响？在官方规划公布一年之际，FT中文网邀请资深媒体人黎岩撰写“拆分北京”系列报道，试图梳理这一政策出台的政治、历史渊源，并分析这一重大行政决定与一代人的生活轨迹之间错综复杂的关系。</p>",
            "image":"https://creatives002.ftimg.net/bj.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookcfbj&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&014",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebookcfbj&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&014"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.person",
            "title":"留学，可以怎样改变一个人",
            "teaser":"FT中文网精选留学及海外教育领域文章，希望学子在踏上征途之时，对当下和未来生出更清晰思考。",
            "description": "<p>留学是一个不多见的永远都是热点的话题。从秋季冬季的准备与申请，春季面对录取通知书的选择，一直到夏天终于启程背负行囊远赴异国他乡。</p><p>FT中文网精选留学及海外教育领域文章，作者们或曾经漂洋过海，深深得益于那一段海外深造的经历，或正身处欧美大学的校园，在课业和生活中体味留学的酸甜苦辣，或对中国留学生的历史与变迁如数家珍。希望又一批学子在勇敢而又憧憬地踏上征途之时，能够对当下和未来，生出更清晰的思考。</p>",
            "image":"https://creatives002.ftimg.net/person.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooklxkyzygbygr&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&011",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooklxkyzygbygr&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&011"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.market",
            "title":"楼市之惑",
            "teaser":"怎样实现“让普通百姓买得起房”？面对中国房地产市场和住宅产业发展的空前机遇，如何把握住？",
            "description": "<p>历经“九八房改”、第二次房改后，如今的房价仍然居高不下。中国经过近20年的发展，目前正处于房地产发展高峰期的交汇点。值得深思的是，“去库存”的效果如何？怎样实现“让普通百姓买得起房”？面对中国房地产市场和住宅产业发展的空前机遇，如何把握住？2018年中国房地产业的挑战和机遇究竟在何处？</p>",
            "image":"https://creatives002.ftimg.net/market.png",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooklszh&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&016",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebooklszh&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&016"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.yearbook2018",
            "title":"2018前瞻：中美博弈之年？",
            "teaser":"2018前瞻：中美博弈之年？",
            "description": "<p>编者按:美国总统特朗普会在今年遭遇弹劾吗？他会为了凝聚支持而兑现选举承诺、发动对华贸易战吗？中国领导人会因取悦特朗普的成本越来越高而决定放弃忍耐、与美国彻底闹僵吗？中国经济能成功防范住“灰犀牛”吗？房地产市场会在今年发生巨变吗？技术创新能否给各国经济带来新出路，使它们免于陷入相互对抗？投资者在注定要动荡的一年，又该如何把握？FT中文网整合一个多月来分析人士对今年前景做出的各种预测，希望能给读者带来答案。</p >",
            "image":"https://creatives002.ftimg.net/2018.jpg",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=yearbook2018&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&018",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=yearbook2018&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&018"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.yearin2018",
            "title":"2017: 自信下的焦虑",
            "teaser":"FT中文网2017年刊",
            "description": "<p>回顾2017年FT中文网最受读者关注的内容，“中国的地缘政治局势”和“中国（中国人）在当今世界的地位”两大主题稳居榜首。 地缘政治方面，尽管南海局势出现缓和迹象，但从金正男遇刺到朝鲜多次核试验、洲际导弹试射，半岛局势一系列令人瞠目结舌的戏剧性发展不断提醒中国人：家门口的危机从未真正缓和，摊牌之日正在逼近。西南方向，中印两国在洞朗地区的军事对峙一度剑拔弩张，引发了国际市场对亚洲两大新兴经济体前途的担忧。与此同时，中国的相对西方的迅速崛起以及官方主导的“软实力”对外输出不但引发西方的强烈反弹，也凸显了正在大步“走出去”的中国人之种种矛盾心态。</p ><p>2017年又是中国国内政经局势的定调之年。中共19大对高度集权的确认，仅仅缓解了国内外观察者的部分担忧；从经济何时触底到产业政策、楼市走向、教育改革，更多令人焦虑的问题随之而来。到了2017年下半年，多地爆出的幼儿园虐童丑闻和北京等大城市的“赶人”争议，令国人焦虑心态集中爆发。从看似光鲜的城市中产到苦苦追求生活改善的低收入、流动人口，不同阶层都意识到了自己“中国梦”的脆弱一面。</p >",
            "image":"http://i.ftimg.net/picture/9/000074679_piclink.jpg",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=yearbook2017&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&v=6.8&020",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=yearbook2017&bodyonly=yes&webview=ftcapp&ad=no&showEnglishAudio=yes&try=yes&v=6.8&020"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.magazine",
            "title":"生活时尚·旅行特刊",
            "teaser":"探寻世界的尽头",
            "image":"http://i.ftimg.net/picture/4/000073894_piclink.jpg",
            "download": "https://creatives002.ftimg.net/ibook/10582_bodyonly.html",
            "downloadfortry": "https://creatives002.ftimg.net/ibook/10582_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.magazine2",
            "title":"如何在“人工智能”时代生存？——创新经济特刊",
            "teaser":"终身学习，是我们在人工智能时代的宿命",
            "image":"http://i.ftimg.net/picture/7/000073887_piclink.jpg",
            "download": "https://creatives002.ftimg.net/ibook/10584_bodyonly.html",
            "downloadfortry": "https://creatives002.ftimg.net/ibook/10584_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.career",
            "title":"管理·性别与职场",
            "teaser":"职场女性生存指南",
            "image":"http://i.ftimg.net/picture/7/000073927_piclink.jpg",
            "download": "https://creatives002.ftimg.net/ibook/10595_bodyonly.html",
            "downloadfortry": "https://creatives002.ftimg.net/ibook/10595_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.economy1",
            "title":"10年，金融危机为我们留下了什么？",
            "teaser":"世界经济·第1辑",
            "image":"http://i.ftimg.net/picture/3/000073933_piclink.jpg",
            "download": "https://creatives002.ftimg.net/ibook/10598_bodyonly.html",
            "downloadfortry": "https://creatives002.ftimg.net/ibook/10598_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.economy2",
            "title":"2018，掘金中国股市？",
            "teaser":"中国经济·第1辑",
            "image":"http://i.ftimg.net/picture/9/000073929_piclink.jpg",
            "download": "https://creatives002.ftimg.net/ibook/10599_bodyonly.html",
            "downloadfortry": "https://creatives002.ftimg.net/ibook/10599_Preview.html"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.dailyenglish1",
            "title":"读《金融时报》学英语（一）",
            "teaser":"挑选FT每日英语文章精华，集结成册",
            "image":"http://i.ftimg.net/picture/5/000074025_piclink.jpg",
            "download": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebook-english-1&bodyonly=yes&webview=ftcapp&ad=no&014",
            "downloadfortry": "https://api003.ftmailbox.com/m/corp/preview.html?pageid=ebook-english-1&bodyonly=yes&webview=ftcapp&ad=no&try=yes&014"
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
        let hightlightIds = ["com.ft.ftchinese.mobile.book.yearbook2018"]
        let highlightJSON = IAP.getJSON(IAPs.shared.products, in: type, shuffle: true, filter: hightlightIds)
        let hightJSCode = JSCodes.get(in: "iap-highlight", with: highlightJSON, where: "center")
        let ids:[String] = [
//            "com.ft.ftchinese.mobile.book.magazine",
//            "com.ft.ftchinese.mobile.book.magazine2",
//            "com.ft.ftchinese.mobile.book.career",
//            "com.ft.ftchinese.mobile.book.economy1",
//            "com.ft.ftchinese.mobile.book.economy2",
//            "com.ft.ftchinese.mobile.book.dailyenglish1"
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
