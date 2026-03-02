//
//  MainViewController.swift
//  Example
//
//  Created by Bingo on 2024/1/10.
//

import UIKit
import AUIFoundation
import AUIAICall
import SafariServices

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        AUIAICallManager.defaultManager.userId = "Your_User_Id"
        

        self.showCallAgentEntrance()
        self.showChatAgentEntrance()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showMainViewController(ani: false)
//            self.testSwiftyMarkdown()
//            self.testPushToTalkView()
        }
    }
    
    func showMainViewController(ani: Bool) {
        let vc = AUIAICallMainViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func showCallAgentEntrance() {
        
        let btn = AVBlockButton(frame: CGRect(x: 48, y: 100, width: 120, height: 40))
        btn.setTitle("VoiceCall", for: .normal)
        btn.av_setLayerBorderColor(UIColor.black, borderWidth: 1.0)
        btn.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(btn)
        
        btn.clickBlock = { sender in
            if let scene = AUIAICallAgentManager.shared.getScenes(for: .VoiceAgent).first {
                AUIAICallManager.defaultManager.startCall(agentType: .VoiceAgent, scene: scene)
            }
        }
    }
    
    func showChatAgentEntrance() {
        
        let btn = AVBlockButton(frame: CGRect(x: 48, y: 180, width: 120, height: 40))
        btn.setTitle("Chatbot", for: .normal)
        btn.av_setLayerBorderColor(UIColor.black, borderWidth: 1.0)
        btn.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(btn)
        
        btn.clickBlock = { sender in
            if let scene = AUIAICallAgentManager.shared.getScenes("ChatAgent").first {
                AUIAICallManager.defaultManager.startChat(scene: scene)
            }
        }
    }
    
    func testPushToTalkView() {
        let view = AUIAICallPushToTalkView(frame: self.view.bounds)
        self.view.addSubview(view)
    }
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: CGRect(x: 12, y: 240, width: self.view.bounds.width - 24, height: 400))
        scroll.contentSize = CGSize(width: scroll.bounds.width, height: 3600)
        scroll.backgroundColor = AVTheme.bg_medium
        self.view.addSubview(scroll)
        return scroll
    }()
    
    lazy var markdownView: AUIAIChatMarkdownView = {
        let view = AUIAIChatMarkdownView(frame: CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 90))
        view.backgroundColor = AVTheme.fill_weak
        self.scrollView.addSubview(view)
        return view
    }()
    
}

extension MainViewController {
    func testSwiftyMarkdown() {
        
        let attributedText = AUIAIChatMarkdownManager.shared.toAttributedString(markdownString: markdownContent3, isLeft: false)
        self.markdownView.attributedText = attributedText
        debugPrint(attributedText)
        
        self.testAttributeTextBounding1()
        
        let maxImageSize = CGSize(width: self.markdownView.av_width, height: CGFloat.greatestFiniteMagnitude)
        AUIAIChatMarkdownManager.shared.renderImage(attributedString: attributedText, originMarkdownString: markdownContent3, maxImageSize: maxImageSize) { attr in
            self.markdownView.attributedText = attr
            debugPrint(attr)
            self.testAttributeTextBounding1()
        }
    }
    
    
    
    var markdownContent1: String {
        return """
        *italics* or _italics_
        **bold** or __bold__
        ~~Linethrough~~Strikethroughs.
        `code`

        # Header 1
        ## Header 2
        ### Header 3
        #### Header 4
        ##### Header 5 #####
        ###### Header 6 ######

            Indented code blocks (spaces or tabs)

        [Links](http://voyagetravelapps.com/)
        ![Images](<Name of asset in bundle>)

        [Referenced Links][1]
        ![Referenced Images][2]

        [1]: http://voyagetravelapps.com/
        [2]: <Name of asset in bundle>

        > Blockquotes

        - Bulleted
        
        - Lists
            - Including indented lists
                - Up to three levels
        - Neat!

        1. Ordered
        1. Lists
            1. Including indented lists
                - Up to three levels
        """
    }
    
    var markdownContent3: String {
        return """
        1. Bulleted Including indented lists光绪年间。这里展示了大量光绪年间。这里展示了大量光绪年间。这里展示了大量光绪年间。这里展示了大量光绪年间。这里展示了大量光绪年间。这里展示了大量
        2. Lists
        官方智能体：您无需做任何配置，系统已为您预置模板，您可直接体验Demo![Images1](https://help-static-aliyun-doc.aliyuncs.com/assets/img/en-US/0758191471/p910663.jpg)
        ![图片2](https://help-static-aliyun-doc.aliyuncs.com/assets/img/en-US/0758191471/p828779.png)
        """
    }
    
    var markdownContent2: String {
        return "好的，那我们继续聊聊广州吧！广州是一座充满活力和魅力的城市，既有悠久的历史文化，又有现代化的都市风貌。接下来，我给你介绍一些广州更有趣的地方和活动，让你更好地了解这座城市的魅力。\n\n### 广州的文化与历史\n\n1. **陈家祠（广东民间工艺博物馆）**\n   - 陈家祠是岭南地区最具代表性的建筑之一，建于清朝光绪年间。这里展示了大量的木雕、石雕、砖雕等传统工艺品，非常适合对历史文化感兴趣的朋友。\n\n2. **越秀公园**\n   - 越秀公园是广州最大的综合性公园，里面有五羊雕像、古城墙遗址等景点。登上镇海楼，可以俯瞰整个广州市区，感受这座城市的历史变迁。\n\n3. **西关大屋**\n   - 西关是广州老城区的一部分，保留了许多传统的岭南民居。这里的建筑风格独特，充满了浓厚的生活气息，漫步其中仿佛穿越回了旧时光。\n\n### 美食天堂\n\n1. **早茶**\n   - 广州的早茶文化非常有名，虾饺、叉烧包、肠粉、凤爪等都是必点的经典点心。推荐去陶陶居、莲香楼这些老字号品尝正宗的广式早茶。\n\n2. **粤菜**\n   - 白切鸡、煲仔饭、艇仔粥、烧腊等都是广州的传统美食。如果你想尝试正宗的粤菜，可以去炳胜品味、惠食佳这样的餐厅。\n\n3. **夜市小吃**\n   - 广州的夜市也非常热闹，上下九步行街、北京路步行街等地有很多小吃摊位，你可以尝到各种地道的小吃，比如牛杂、炸云吞、糖水等。\n\n### 现代与时尚\n\n1. **天河城商圈**\n   - 天河城是广州最繁华的商业区之一，这里有大型购物中心、电影院、餐厅等各种娱乐设施，适合购物和休闲。\n\n2. **珠江新城**\n   - 珠江新城是广州的新CBD，高楼林立，现代感十足。这里有许多高档写字楼、豪华酒店和国际品牌商店，夜晚的珠江新城灯火辉煌，非常美丽。\n\n3. **K11购物艺术中心**\n   - K11不仅是一个购物中心，更是一个融合了艺术、文化和购物的综合空间。这里经常举办各种艺术展览和文化活动，适合喜欢艺术的朋友。\n\n### 自然与休闲\n\n1. **白云山**\n   - 白云山是广州的“绿肺”，空气清新，风景优美。你可以选择徒步登山，或者乘坐缆车上山，沿途欣赏自然风光。\n\n2. **南沙湿地公园**\n   - 南沙湿地公园是广州的一个生态旅游景点，这里有大片的红树林和湿地，适合观鸟和亲近大自然。\n\n3. **海珠湖公园**\n   - 海珠湖公园是一个城市中的湖泊公园，环境优美，适合散步、骑行或划船，是个放松心情的好地方。\n\n### 文化活动与节日\n\n1. **广府庙会**\n   - 每年农历正月十五前后，广州会举办广府庙会，展示传统的民俗文化，如舞狮、舞龙、猜灯谜等，非常热闹。\n\n2. **广州国际灯光节**\n   - 这个灯光节通常在每年的11月至次年1月举行，期间珠江两岸和各大地标建筑会被绚丽多彩的灯光装饰，非常壮观。\n\n3. **广州马拉松**\n   - 如果你喜欢运动，可以关注一下广州马拉松，这是一项每年举行的国际性赛事，吸引了众多跑步爱好者参与。\n\n希望这些信息能帮助你更好地了解广州，并为你提供一些出行灵感。如果你有具体的问题或者想了解更多细节，随时告诉我哦！ 😊\n\n有什么特别想去的地方或者感兴趣的活动吗？"
    }
    
    func testAttributeTextBounding() {

//        let frame = self.markdownView.frame
//        let size = self.markdownView.sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
//        self.markdownView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: size.height)
        self.markdownView.sizeToFit()
    }
    
    func testAttributeTextBounding1() {
        
        let frame = self.markdownView.frame
        let maxSize = CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude) // 限制宽度，允许无限制高度
        let boundingBox = self.markdownView.attributedText!.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        self.markdownView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: ceil(boundingBox.height))
    }
    
    func testAttributeTextBounding2() {
        
        let frame = self.markdownView.frame
        let maxSize = CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude) // 限制宽度，允许无限制高度
        let textStorage = NSTextStorage(attributedString: self.markdownView.attributedText!)
        let textContainer = NSTextContainer(size: maxSize)
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0 // 移除默认的左右填充
        textContainer.maximumNumberOfLines = 0 // 允许多行显示
        layoutManager.ensureLayout(for: textContainer)
        let boundingBox = layoutManager.usedRect(for: textContainer)
        
        self.markdownView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: ceil(boundingBox.height))
    }
    
    func testAttributeString() {
        // 创建段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8 // 设置行间距
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.paragraphSpacingBefore = 8
        paragraphStyle.headIndent = 33.168 // 设置段落首行缩进
        paragraphStyle.firstLineHeadIndent = 33.168 // 设置首行额外缩进
        // 创建富文本属性
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        // 创建段落样式
        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.lineSpacing = 0 // 设置行间距
        paragraphStyle2.paragraphSpacing = 8
        paragraphStyle2.paragraphSpacingBefore = 8
        paragraphStyle2.headIndent = 33.168 // 设置段落首行缩进
        paragraphStyle2.firstLineHeadIndent = 33.168 // 设置首行额外缩进
        // 创建富文本属性
        let attributes2: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle2
        ]

        let attributedString = NSMutableAttributedString(string: "• ", attributes: attributes2)
        attributedString.append(NSAttributedString(string: "列表项 1如果你喜欢运动，可以关注一下广州马拉松，这是一项每年举行的国际性赛事，吸引了众多跑步爱好者参与。", attributes: attributes))
        debugPrint(attributedString)
        
        self.markdownView.attributedText = attributedString
    }
    
    func enumerateAttachments(in attributedString: NSAttributedString) {
        // 遍历整个字符串的范围
        let range = NSRange(location: 0, length: attributedString.length)
        
        attributedString.enumerateAttributes(in: range, options: []) { attributes, range, _ in
            // 检查是否有 NSTextAttachment 属性
            if let attachment = attributes[NSAttributedString.Key.attachment] as? NSTextAttachment {
                print("找到附件：\(attachment)")
                
                // 获取附件的图片
                if let image = attachment.image {
                    print("附件图片尺寸：\(image.size)")
                } else if let imageData = attachment.fileWrapper?.regularFileContents,
                          let image = UIImage(data: imageData) {
                    print("附件图片数据：\(image)")
                }
                
                // 打印附件所在的文本范围
                print("附件所在范围：\(range)")
            }
        }
    }

}
