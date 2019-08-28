import UIKit

protocol PageViewDelegate: class {
  func pageViewDidZoom(_ pageView: PageView)
  func remoteImageDidLoad(_ image: UIImage?, imageView: UIImageView)
  func pageView(_ pageView: PageView, didTouchPlayButton videoURL: URL)
  func pageViewDidTouch(_ pageView: PageView)
}

class PageView: UIScrollView {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.isUserInteractionEnabled = true

    return imageView
  }()

  lazy var playButton: UIButton = {
    let button = UIButton(type: .custom)
    button.frame.size = CGSize(width: 60, height: 60)
    button.setBackgroundImage(AssetManager.image("lightbox_play"), for: UIControl.State())
    button.addTarget(self, action: #selector(playButtonTouched(_:)), for: .touchUpInside)

    button.layer.shadowOffset = CGSize(width: 1, height: 1)
    button.layer.shadowColor = UIColor.gray.cgColor
    button.layer.masksToBounds = false
    button.layer.shadowOpacity = 0.8

    return button
  }()
    
    lazy var videoPlayerView: VideoPlayerView = {
        let videoPlayerView = VideoPlayerView()
        
        return videoPlayerView
    }()

  lazy var loadingIndicator: UIView = LightboxConfig.makeLoadingIndicator()

  var image: LightboxImage
  var contentFrame = CGRect.zero
  weak var pageViewDelegate: PageViewDelegate?

  var hasZoomed: Bool {
    return zoomScale != 1.0
  }

  // MARK: - Initializers

  init(image: LightboxImage) {
    self.image = image
    super.init(frame: CGRect.zero)

    configure()

    fetchImage()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func configure() {
    if nil != self.image.videoURL {
        addVideoPlayerView()
    } else {
        addSubview(imageView)
    }

//    updatePlayButton()
    
    addSubview(loadingIndicator)

    delegate = self
    isMultipleTouchEnabled = true
    minimumZoomScale = LightboxConfig.Zoom.minimumScale
    maximumZoomScale = LightboxConfig.Zoom.maximumScale
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false

    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDoubleTapped(_:)))
    doubleTapRecognizer.numberOfTapsRequired = 2
    doubleTapRecognizer.numberOfTouchesRequired = 1
    addGestureRecognizer(doubleTapRecognizer)

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
    addGestureRecognizer(tapRecognizer)

    tapRecognizer.require(toFail: doubleTapRecognizer)
  }

  // MARK: - Update
    func prepareDisplay() {
        if let videoUrl = image.videoURL {
            videoPlayerView.videoURL = videoUrl
            videoPlayerView.play()
        }
    }
    
  func update(with image: LightboxImage) {
    self.image = image
//    updatePlayButton()
    fetchImage()
  }

  func updatePlayButton () {
    if self.image.videoURL != nil && !subviews.contains(playButton) {
      addSubview(playButton)
    } else if self.image.videoURL == nil && subviews.contains(playButton) {
      playButton.removeFromSuperview()
    }
  }
    
    func addVideoPlayerView() {
//        if let videoUrl = self.image.videoURL, !subviews.contains(videoPlayerView) {
//            videoPlayerView.videoURL = videoUrl
            addSubview(videoPlayerView)
//        } else if self.image.videoURL == nil && subviews.contains(playButton) {
//            videoPlayerView.removeFromSuperview()
//        }
    }

  // MARK: - Fetch
  private func fetchImage () {
    loadingIndicator.alpha = 1
    self.image.addImageTo(imageView) { [weak self] image in
      guard let self = self else {
        return
      }

      self.isUserInteractionEnabled = true
      self.configureImageView()
      self.pageViewDelegate?.remoteImageDidLoad(image, imageView: self.imageView)

      UIView.animate(withDuration: 0.4) {
        self.loadingIndicator.alpha = 0
      }
    }
  }

  // MARK: - Recognizers

  @objc func scrollViewDoubleTapped(_ recognizer: UITapGestureRecognizer) {
    let pointInView = recognizer.location(in: imageView)
    let newZoomScale = zoomScale > minimumZoomScale
      ? minimumZoomScale
      : maximumZoomScale

    let width = contentFrame.size.width / newZoomScale
    let height = contentFrame.size.height / newZoomScale
    let x = pointInView.x - (width / 2.0)
    let y = pointInView.y - (height / 2.0)

    let rectToZoomTo = CGRect(x: x, y: y, width: width, height: height)

    zoom(to: rectToZoomTo, animated: true)
  }

  @objc func viewTapped(_ recognizer: UITapGestureRecognizer) {
    pageViewDelegate?.pageViewDidTouch(self)
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    loadingIndicator.center = imageView.center
//    playButton.center = imageView.center
  }

  func configureImageView() {
    guard let image = imageView.image else {
        centerImageView()
        return
    }

    let imageViewSize = imageView.frame.size
    let imageSize = image.size
    let realImageViewSize: CGSize

    if imageSize.width / imageSize.height > imageViewSize.width / imageViewSize.height {
      realImageViewSize = CGSize(
        width: imageViewSize.width,
        height: imageViewSize.width / imageSize.width * imageSize.height)
    } else {
      realImageViewSize = CGSize(
        width: imageViewSize.height / imageSize.height * imageSize.width,
        height: imageViewSize.height)
    }

    imageView.frame = CGRect(origin: CGPoint.zero, size: realImageViewSize)

    centerImageView()
  }

  func centerImageView() {
    let boundsSize = contentFrame.size
    var imageViewFrame = imageView.frame

    if imageViewFrame.size.width < boundsSize.width {
      imageViewFrame.origin.x = (boundsSize.width - imageViewFrame.size.width) / 2.0
    } else {
      imageViewFrame.origin.x = 0.0
    }

    if imageViewFrame.size.height < boundsSize.height {
      imageViewFrame.origin.y = (boundsSize.height - imageViewFrame.size.height) / 2.0
    } else {
      imageViewFrame.origin.y = 0.0
    }

    imageView.frame = imageViewFrame
  }
    
    func configureVideoPlayer() {
        let boundSize = contentFrame.size
        var videoPlayerFrame = videoPlayerView.frame
        videoPlayerFrame.size = boundSize
        
        videoPlayerView.frame = videoPlayerFrame
        
        
//        videoPlayerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        videoPlayerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        videoPlayerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        videoPlayerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

  // MARK: - Action

  @objc func playButtonTouched(_ button: UIButton) {
    guard let videoURL = image.videoURL else { return }

    pageViewDelegate?.pageView(self, didTouchPlayButton: videoURL as URL)
  }
}

// MARK: - LayoutConfigurable

extension PageView: LayoutConfigurable {

  @objc func configureLayout() {
    contentFrame = frame
    contentSize = frame.size
    imageView.frame = frame
    zoomScale = minimumZoomScale

    if image.videoURL != nil {
        configureVideoPlayer()
    } else {
        configureImageView()
    }
  }
}

// MARK: - UIScrollViewDelegate

extension PageView: UIScrollViewDelegate {

  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    centerImageView()
    pageViewDelegate?.pageViewDidZoom(self)
  }
}
