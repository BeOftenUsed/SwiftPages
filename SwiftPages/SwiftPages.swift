//
//  SwiftPages.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 6/27/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit


// MARK: - SwiftPages

public class SwiftPages: UIView {
    
    // Items variables
    private var containerView: UIView!
    private var scrollView: UIScrollView!
    private var topBar: UIView!
    private var animatedBar: UIView!
    private var viewControllerIDs = [String]()
    private var buttonTitles = [String]()
    private var buttonImages = [UIImage]()
    private var pageViews = [UIViewController?]()
    private var currentPage: Int!
    
    // Container view position variables
    private var xOrigin: CGFloat = 0
    private var yOrigin: CGFloat = 64
    private var distanceToBottom: CGFloat = 0
    
    // Color variables
    private var animatedBarColor = UIColor(red: 28/255, green: 95/255, blue: 185/255, alpha: 1)
    private var topBarBackground = UIColor.whiteColor()
    private var buttonsTextColor = UIColor.grayColor()
    private var containerViewBackground = UIColor.whiteColor()
    
    // Item size variables
    private var topBarHeight: CGFloat = 52
    private var animatedBarHeight: CGFloat = 3
    
    // Bar item variables
    private var aeroEffectInTopBar = false //This gives the top bap a blurred effect, also overlayes the it over the VC's
    private var buttonsWithImages = false
    private var barShadow = true
    private var shadowView : UIView!
    private var shadowViewGradient = CAGradientLayer()
    private var buttonsTextFontAndSize = UIFont(name: "HelveticaNeue-Light", size: 20)!
    private var blurView : UIVisualEffectView!
    private var barButtons = [UIButton?]()
    
    // MARK: - Positions Of The Container View API -
    public func setOriginX (origin : CGFloat) { xOrigin = origin }
    public func setOriginY (origin : CGFloat) { yOrigin = origin }
    public func setDistanceToBottom (distance : CGFloat) { distanceToBottom = distance }
    
    // MARK: - API's -
    public func setAnimatedBarColor (color : UIColor) { animatedBarColor = color }
    public func setTopBarBackground (color : UIColor) { topBarBackground = color }
    public func setButtonsTextColor (color : UIColor) { buttonsTextColor = color }
    public func setContainerViewBackground (color : UIColor) { containerViewBackground = color }
    public func setTopBarHeight (pointSize : CGFloat) { topBarHeight = pointSize}
    public func setAnimatedBarHeight (pointSize : CGFloat) { animatedBarHeight = pointSize}
    public func setButtonsTextFontAndSize (fontAndSize : UIFont) { buttonsTextFontAndSize = fontAndSize}
    public func enableAeroEffectInTopBar (boolValue : Bool) { aeroEffectInTopBar = boolValue}
    public func enableButtonsWithImages (boolValue : Bool) { buttonsWithImages = boolValue}
    public func enableBarShadow (boolValue : Bool) { barShadow = boolValue}
    
    override public func drawRect(rect: CGRect) {
        let pagesContainerHeight = frame.height - yOrigin - distanceToBottom
        let pagesContainerWidth = frame.width
        
        //Set the notifications for an orientation change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("orientationWillChange"), name: UIApplicationWillChangeStatusBarOrientationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("orientationDidChange"), name: UIDeviceOrientationDidChangeNotification, object: nil)

        
        // Set the containerView, every item is constructed relative to this view
        containerView = UIView(frame: CGRect(x: xOrigin, y: yOrigin, width: pagesContainerWidth, height: pagesContainerHeight))
        containerView.backgroundColor = containerViewBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        //Add the constraints to the containerView.
        if #available(iOS 9.0, *) {
            let horizontalConstraint = containerView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor)
            let verticalConstraint = containerView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor)
            let widthConstraint = containerView.widthAnchor.constraintEqualToAnchor(self.widthAnchor)
            let heightConstraint = containerView.heightAnchor.constraintEqualToAnchor(self.heightAnchor)
            NSLayoutConstraint.activateConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        }

        
        // Set the scrollview
        if aeroEffectInTopBar {
            scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height))
        } else {
            scrollView = UIScrollView(frame: CGRect(x: 0, y: topBarHeight, width: containerView.frame.size.width, height: containerView.frame.size.height - topBarHeight))
        }
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.contentOffset = CGPointMake(0, 0)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scrollView)
        
        //Add the constraints to the scrollview.
        if #available(iOS 9.0, *) {
            let leadingConstraint = scrollView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor)
            let trailingConstraint = scrollView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor)
            let topConstraint = scrollView.topAnchor.constraintEqualToAnchor(containerView.topAnchor)
            let bottomConstraint = scrollView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor)
            NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        }
        
        // Set the top bar
        topBar = UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: topBarHeight))
        topBar.backgroundColor = topBarBackground
        
        if aeroEffectInTopBar {
            // Create the blurred visual effect
            // You can choose between ExtraLight, Light and Dark
            topBar.backgroundColor = UIColor.clearColor()
            
            let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = topBar.bounds
            blurView.translatesAutoresizingMaskIntoConstraints = false
            topBar.addSubview(blurView)
        }
        topBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(topBar)
        
//        //Add the constraints to the scrollview.
//        if #available(iOS 9.0, *) {
//            let topBarLeadingConstraint = topBar.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor)
//            let topBarTrailingConstraint = topBar.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor)
//            let topBarTopConstraint = topBar.topAnchor.constraintEqualToAnchor(containerView.topAnchor)
//            let topBarHeightConstraint = topBar.heightAnchor.constraintEqualToAnchor(topBar.heightAnchor)
//            NSLayoutConstraint.activateConstraints([topBarLeadingConstraint, topBarTrailingConstraint, topBarTopConstraint, topBarHeightConstraint])
//        }
        
        // Set the top bar buttons
        // Check to see if the top bar will be created with images ot text
        if buttonsWithImages {
            var buttonsXPosition: CGFloat = 0
            
            for (index, image) in buttonImages.enumerate() {
                let frame = CGRect(x: buttonsXPosition, y: 0, width: containerView.frame.size.width / (CGFloat)(viewControllerIDs.count), height: topBarHeight)
                
                let barButton = UIButton(frame: frame)
                barButton.backgroundColor = UIColor.clearColor()
                barButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                barButton.setImage(image, forState: .Normal)
                barButton.tag = index
                barButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
                topBar.addSubview(barButton)
                
                barButtons.append(barButton)
                
                buttonsXPosition += containerView.frame.size.width / (CGFloat)(viewControllerIDs.count)
            }
        } else {
            var buttonsXPosition: CGFloat = 0
            
            for (index, title) in buttonTitles.enumerate() {
                let frame = CGRect(x: buttonsXPosition, y: 0, width: containerView.frame.size.width / (CGFloat)(viewControllerIDs.count), height: topBarHeight)
                
                let barButton = UIButton(frame: frame)
                barButton.backgroundColor = UIColor.clearColor()
                barButton.titleLabel!.font = buttonsTextFontAndSize
                barButton.setTitle(title, forState: .Normal)
                barButton.setTitleColor(buttonsTextColor, forState: .Normal)
                barButton.tag = index
                barButton.addTarget(self, action: "barButtonAction:", forControlEvents: .TouchUpInside)
                topBar.addSubview(barButton)
                
                barButtons.append(barButton)
                
                buttonsXPosition += containerView.frame.size.width / (CGFloat)(viewControllerIDs.count)
            }
        }
        
        // Set up the animated UIView
        animatedBar = UIView(frame: CGRect(x: 0, y: topBarHeight - animatedBarHeight + 1, width: (containerView.frame.size.width / (CGFloat)(viewControllerIDs.count)) * 0.8, height: animatedBarHeight))
        animatedBar.center.x = containerView.frame.size.width / (CGFloat)(viewControllerIDs.count < 1)
        animatedBar.backgroundColor = animatedBarColor
        containerView.addSubview(animatedBar)
        
        // Add the bar shadow (set to true or false with the barShadow var)
        if barShadow {
            shadowView = UIView(frame: CGRect(x: 0, y: topBarHeight, width: containerView.frame.size.width, height: 4))
            shadowViewGradient.frame = shadowView.bounds
            shadowViewGradient.colors = [UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.28).CGColor, UIColor.clearColor().CGColor]
            shadowView.layer.insertSublayer(shadowViewGradient, atIndex: 0)
            containerView.addSubview(shadowView)
        }
        
        let pageCount = viewControllerIDs.count
        
        // Fill the array containing the VC instances with nil objects as placeholders
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // Defining the content size of the scrollview
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageCount),
            height: pagesScrollViewSize.height)
        
        // Load the pages to show initially
        loadVisiblePages()
        
        alignSubviews()
    }
    
    // MARK: - Initialization Functions -
    public func initializeWithVCIDsArrayAndButtonTitlesArray (VCIDsArray: [String], buttonTitlesArray: [String]) {
        // Important - Titles Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCIDsArray.count == buttonTitlesArray.count {
            viewControllerIDs = VCIDsArray
            buttonTitles = buttonTitlesArray
            buttonsWithImages = false
        } else {
            print("Initilization failed, the VC ID array count does not match the button titles array count.")
        }
    }
    
    public func initializeWithVCIDsArrayAndButtonImagesArray (VCIDsArray: [String], buttonImagesArray: [UIImage]) {
        // Important - Images Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCIDsArray.count == buttonImagesArray.count {
            viewControllerIDs = VCIDsArray
            buttonImages = buttonImagesArray
            buttonsWithImages = true
        } else {
            print("Initilization failed, the VC ID array count does not match the button images array count.")
        }
    }
    
    public func alignSubviews() {
        
        let pageCount = viewControllerIDs.count
        
        //Setup the new frames
        scrollView.contentSize = CGSizeMake(CGFloat(pageCount) * scrollView.bounds.size.width,
            scrollView.bounds.size.height);
        topBar.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: topBarHeight)
        blurView?.frame = topBar.bounds
        
        //Set the new frame of the scrollview contents
        var i = 0
        for viewController in pageViews {
            viewController?.view.frame = CGRectMake(CGFloat(i) * scrollView.bounds.size.width, 0,
                scrollView.bounds.size.width, scrollView.bounds.size.height)
            i++
        }
        
        //Set the new frame for the bar buttons
        var buttonsXPosition: CGFloat = 0
        for button in barButtons {
            let newFrame = CGRect(x: buttonsXPosition, y: 0, width: containerView.frame.size.width / (CGFloat)(viewControllerIDs.count), height: topBarHeight)
            button?.frame = newFrame
            buttonsXPosition += containerView.frame.size.width / (CGFloat)(viewControllerIDs.count)
        }
        
        // Set the new frame
        animatedBar.frame.size = CGSize(width: (containerView.frame.size.width / (CGFloat)(viewControllerIDs.count)) * 0.8, height: animatedBarHeight)
        if barShadow {
            shadowView.frame.size = CGSize(width: containerView.frame.size.width, height: 4)
            shadowViewGradient.frame = shadowView.bounds
        }
    }
    
    public func loadPage(page: Int) {
        // If it's outside the range of what you have to display, then do nothing
        guard page >= 0 && page < viewControllerIDs.count else { return }
        
        // Do nothing if the view is already loaded.
        guard pageViews[page] == nil else { return }
        
        print("Loading Page \(page)")
        
        // The pageView instance is nil, create the page
        var frame = scrollView.bounds
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0.0
        
        // Look for the VC by its identifier in the storyboard and add it to the scrollview
        let newPageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(viewControllerIDs[page])
        newPageView.view.frame = frame
        scrollView.addSubview(newPageView.view)
        
        // Replace the nil in the pageViews array with the VC just created
        pageViews[page] = newPageView
    }
    
    public func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
    }
    
    public func barButtonAction(sender: UIButton?) {
        let index: Int = sender!.tag
        let pagesScrollViewSize = scrollView.frame.size
        
        scrollView.setContentOffset(CGPoint(x: pagesScrollViewSize.width * (CGFloat)(index), y: 0), animated: true)
    }
    
    func orientationWillChange() {
        print("*****orientationWillChange")
        currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        print("Page -> \(currentPage)")
    }
    
    func orientationDidChange() {
        print("*****orientationDidChange")
        alignSubviews()
        scrollView.contentOffset = CGPointMake(CGFloat(currentPage) * scrollView.frame.size.width, 0)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


// MARK: - SwiftPages: UIScrollViewDelegate

extension SwiftPages: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
        
        // The calculations for the animated bar's movements
        // The offset addition is based on the width of the animated bar (button width times 0.8)
        let offsetAddition = (containerView.frame.size.width / (CGFloat)(viewControllerIDs.count)) * 0.1
        animatedBar.frame = CGRect(x: (offsetAddition + (scrollView.contentOffset.x / (CGFloat)(viewControllerIDs.count))), y: animatedBar.frame.origin.y, width: animatedBar.frame.size.width, height: animatedBar.frame.size.height)
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
}