import UIKit
import Lightbox

class ViewController: UIViewController, LightboxControllerPageDelegate {
    var circleView: CircleView!
  lazy var showButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.addTarget(self, action: #selector(showLightbox), for: .touchUpInside)
    button.setTitle("Show me the lightbox", for: UIControl.State())
    button.setTitleColor(UIColor(red:0.47, green:0.6, blue:0.13, alpha:1), for: UIControl.State())
    button.titleLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 30)
    button.frame = UIScreen.main.bounds
    button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
    
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
    view.backgroundColor = UIColor.white
    view.addSubview(showButton)
    
    
  }
  
  // MARK: - Action methods
  
  @objc func showLightbox() {
    let images = [
      LightboxImage(imageURL: URL(string: "https://cdn.arstechnica.net/2011/10/05/iphone4s_sample_apple-4e8c706-intro.jpg")!),
      LightboxImage(
        image: UIImage(named: "photo1")!,
        text: "Photography is the science, art, application and practice of creating durable images by recording light or other electromagnetic radiation, either electronically by means of an image sensor, or chemically by means of a light-sensitive material such as photographic film",
        isPlaceholder: false
      ),
      LightboxImage(
        image: UIImage(named: "photo2")!,
        text: "Emoji 😍 (/ɪˈmoʊdʒi/; singular emoji, plural emoji or emojis;[4] from the Japanese 絵文字えもじ, pronounced [emodʑi]) are ideograms and smileys used in electronic messages and web pages. Emoji are used much like emoticons and exist in various genres, including facial expressions, common objects, places and types of weather 🌅☔️💦, and animals 🐶🐱",
        videoURL: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"),
//        videoURL: URL(string: "https://rdvtest01.rdv.mobi/media/2018/11/08/17/portofolio-video.4518228835161590.4518229147689059.6_encoded.mp4")
        isPlaceholder: false
      ),
      LightboxImage(
        image: UIImage(named: "photo3")!,
        text: "A lightbox is a translucent surface illuminated from behind, used for situations where a shape laid upon the surface needs to be seen with high contrast.",
        isPlaceholder: false
      )
    ]
    LightboxConfig.CloseButton.text = "X"
    LightboxConfig.CloseButton.size = CGSize(width: 30.0, height: 30.0)
    LightboxConfig.PageIndicator.enabled = true

    let controller = LightboxController(images: images)
    circleView = CircleView(frame: CGRect(x: 0, y: 16, width: 30, height: 30))
    controller.headerView.pageIndicator = circleView
    
    controller.scrollView.isScrollEnabled = false
    controller.dynamicBackground = true
    controller.pageDelegate = self
    present(controller, animated: true, completion: nil)
  }
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        circleView.go(from: CGFloat(page) / 4.0, to: CGFloat(page + 1) / 4.0, animated: true)
    }
}

