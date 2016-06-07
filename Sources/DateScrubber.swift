import UIKit

public protocol DateScrubberDelegate {

    func dateScrubber(dateScrubber:DateScrubber, didRequestToSetContentViewToYPosition yPosition: CGFloat)
}

public extension DateScrubberDelegate where Self: UICollectionViewController {

    func dateScrubber(dateScrubber:DateScrubber, didRequestToSetContentViewToYPosition yPosition: CGFloat){

        self.collectionView?.setContentOffset(CGPoint(x: 0,y: yPosition), animated: false)
    }
}

public class DateScrubber: UIViewController {
    static let RightEdgeInset: CGFloat = 5.0

    public var delegate : DateScrubberDelegate?

    public var viewHeight : CGFloat = 56.0

    public var containingViewFrame = UIScreen.mainScreen().bounds

    public var containingViewContentSize = UIScreen.mainScreen().bounds.size

    private let scrubberImageView = UIImageView()

    private let sectionLabel = SectionLabel()

    private let dragGestureRecognizer = UIPanGestureRecognizer()

    private var viewIsBeingDragged = false

    public var sectionLabelImage: UIImage? {
        didSet {
            if let sectionLabelImage = self.sectionLabelImage {

                self.sectionLabel.labelImage = sectionLabelImage
                self.viewHeight = sectionLabelImage.size.height
            }
        }
    }

    public var scrubberImage: UIImage? {
        didSet {
            if let scrubberImage = self.scrubberImage {

                scrubberImageView.image = scrubberImage
                scrubberImageView.frame = CGRectMake(containingViewFrame.width - scrubberImage.size.width - DateScrubber.RightEdgeInset, 0, scrubberImage.size.width, scrubberImage.size.height)
                self.view.addSubview(scrubberImageView)
            }
        }
    }

    public var font : UIFont? {
        didSet {
            if let font = self.font {
                sectionLabel.setFont(font)
            }
        }
    }

    public var textColor : UIColor? {
        didSet {
            if let textColor = self.textColor {
                sectionLabel.setTextColor(textColor)
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setSectionlabelFrame()
        self.view.addSubview(self.sectionLabel)

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleDrag))
        self.scrubberImageView.userInteractionEnabled  = true
        self.scrubberImageView.addGestureRecognizer(self.dragGestureRecognizer)
    }

    public func updateFrame(scrollView scrollView: UIScrollView) {

        if viewIsBeingDragged {
            return
        }

        let yPos = calculateYPosInView(forYPosInContentView: scrollView.contentOffset.y + containingViewFrame.minY)

        self.setFrame(atYpos: yPos)
    }

    public func updateSectionTitle(title : String){
        self.sectionLabel.setText(title)
        self.setSectionlabelFrame()
    }

    private func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat{

        let percentageInContentView = yPosInContentView / containingViewContentSize.height
        return (containingViewFrame.height * percentageInContentView ) + containingViewFrame.minY
    }

    private func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {

        let percentageInView = (yPosInView - containingViewFrame.minY) / containingViewFrame.height
        return (containingViewContentSize.height * percentageInView) - containingViewFrame.minY
    }

    func handleDrag(gestureRecognizer : UIPanGestureRecognizer) {

        self.viewIsBeingDragged = gestureRecognizer.state != .Ended

        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {

            let translation = gestureRecognizer.translationInView(self.view)
            var newYPosForDateScrubber =  self.view.frame.origin.y + translation.y


            if newYPosForDateScrubber < containingViewFrame.minY {
                newYPosForDateScrubber = containingViewFrame.minY
            }

            if newYPosForDateScrubber > containingViewFrame.height + containingViewFrame.minY - viewHeight {
                newYPosForDateScrubber = containingViewFrame.height + containingViewFrame.minY - viewHeight
            }

            self.setFrame(atYpos: newYPosForDateScrubber)

            let yPosInContentInContentView = calculateYPosInContentView(forYPosInView: newYPosForDateScrubber)
            self.delegate?.dateScrubber(self, didRequestToSetContentViewToYPosition: yPosInContentInContentView)

            gestureRecognizer.setTranslation(CGPoint(x: translation.x, y: 0), inView: self.view)
        }
    }

    private func setFrame(atYpos yPos: CGFloat){
        self.view.frame = CGRectMake(0, yPos, UIScreen.mainScreen().bounds.width, viewHeight)
    }

    private func setSectionlabelFrame(){
        self.sectionLabel.frame = CGRectMake(self.view.frame.width - SectionLabel.RightOffsetForSectionLabel - self.sectionLabel.sectionlabelWidth, 0, self.sectionLabel.sectionlabelWidth, viewHeight)

    }
}