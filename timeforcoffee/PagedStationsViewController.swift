
//
//  PagedStationsViewController.swift
//  timeforcoffee
//
//  Created by Christian Stocker on 06.03.15.
//  Copyright (c) 2015 Christian Stocker. All rights reserved.
//

import Foundation

class PagedStationsViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var test: UINavigationItem!

    //@IBOutlet var pageIndicator: UIPageControl!
    var currentPageIndex: Int?
    var scrollViewOffset: CGFloat? = 0
    var scrollViewWidth: CGFloat?
    var searchController: UISearchController?
    var scrollView: UIScrollView?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        currentPageIndex = 0
        var startingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StationsView") as StationsViewController
        startingViewController.showFavorites = false
        startingViewController.pageIndex = 0
        self.setViewControllers([startingViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

        var aboutButton = UIBarButtonItem(title: "☕︎", style: UIBarButtonItemStyle.Plain, target: self, action: "aboutClicked:")
        aboutButton.tintColor = UIColor.blackColor()

        let font = UIFont.systemFontOfSize(30)
        let buttonAttr = [NSFontAttributeName: font]
        aboutButton.setTitleTextAttributes(buttonAttr, forState: UIControlState.Normal)
        self.navigationItem.leftBarButtonItem = aboutButton
        self.edgesForExtendedLayout = UIRectEdge.None;

        setSearchButton()
        setTitleView()
        
        for v in self.view.subviews {
            if v.isKindOfClass(UIScrollView){
                scrollView = (v as UIScrollView)
                scrollView?.delegate = self
            }
        }
        if (scrollView != nil) {
            scrollViewDidScroll(scrollView!)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: "UIApplicationDidBecomeActiveNotification", object: nil)

    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        if (self.searchController == nil) {
            let currentView: StationsViewController  = self.viewControllers[0] as StationsViewController
            currentView.appsTableView?.refreshLocation()
        }
    }

    func setTitleView () {
        scrollViewWidth = UIScreen.mainScreen().bounds.size.width
        
        var titleView = UIView(frame: CGRect(x: 0, y: 0, width: scrollViewWidth! / 2, height: 30))

        var labelContainer = UIView(frame: CGRect(x: 0, y: 0, width: scrollViewWidth!, height: 20))
        labelContainer.tag = 100
        
        let labelFont = UIFont(name: "HelveticaNeue-Medium", size: 12.0)

        var pageLabel1 = UILabel(frame: CGRect(x: 0, y: 0, width: scrollViewWidth! / 2, height: 20))
        pageLabel1.text = "NEAREST STATIONS"
        pageLabel1.font = labelFont
        pageLabel1.textAlignment = NSTextAlignment.Center
        
        pageLabel1.tag = 1

        var pageLabel2 = UILabel(frame: CGRect(x: scrollViewWidth! / 2, y: 0, width: scrollViewWidth! / 2, height: 20))
        pageLabel2.text = "FAVORITES"
        pageLabel2.font = labelFont
        pageLabel2.textAlignment = NSTextAlignment.Center
        pageLabel2.tag = 2

        labelContainer.addSubview(pageLabel1)
        labelContainer.addSubview(pageLabel2)

        titleView.addSubview(labelContainer)
        
        
        var titlePageControl = UIPageControl(frame: CGRect(x: 0, y: 20, width: scrollViewWidth! / 2, height: 10))
        titlePageControl.tag = 50
        titlePageControl.numberOfPages = 2
        titlePageControl.currentPage = 0
        titlePageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        titlePageControl.pageIndicatorTintColor = UIColor.grayColor()
        
        titleView.addSubview(titlePageControl)
        

        self.navigationItem.titleView = titleView

        self.navigationItem.titleView?.layer.frame = CGRect(x: 0, y: 0, width: scrollViewWidth! / 2, height: 30)
        self.navigationItem.titleView?.clipsToBounds = false
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (currentPageIndex == 0) {
            scrollViewOffset = scrollView.contentOffset.x - scrollView.frame.width
            self.navigationItem.titleView?.viewWithTag(1)?.layer.opacity = 1 - Float(((scrollView.contentOffset.x - scrollViewWidth!) / scrollViewWidth!))
            self.navigationItem.titleView?.viewWithTag(2)?.layer.opacity = Float(((scrollView.contentOffset.x - scrollViewWidth!) / scrollViewWidth!))
        } else {
            scrollViewOffset = scrollView.contentOffset.x
            self.navigationItem.titleView?.viewWithTag(1)?.layer.opacity = -Float(((scrollView.contentOffset.x - scrollViewWidth!) / scrollViewWidth!))
            self.navigationItem.titleView?.viewWithTag(2)?.layer.opacity = 1 + Float(((scrollView.contentOffset.x - scrollViewWidth!) / scrollViewWidth!))
        }
        self.navigationItem.titleView?.viewWithTag(100)?.layer.position.x = (-scrollViewOffset! / 2) + scrollViewWidth! / 2
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc:StationsViewController = viewController as StationsViewController
        if (vc.pageIndex == 1) {
            return nil;
        }
        var newVc: StationsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StationsView") as StationsViewController
        newVc.pageIndex = 1
        newVc.showFavorites = true
        return newVc
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc:StationsViewController = viewController as StationsViewController
        if (vc.pageIndex == 0) {
            return nil;
        }
        var newVc: StationsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StationsView") as StationsViewController
        newVc.pageIndex = 0
        newVc.showFavorites = false
        return newVc
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if (completed == true && finished == true) {
            if let currentViewController = pageViewController.viewControllers?.first as? StationsViewController {
                if (currentViewController.pageIndex != currentPageIndex) {
                    setPageControlDot()
                }
            }
            let currentView: StationsViewController  = pageViewController.viewControllers[0] as StationsViewController
        }
    }

    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        let currentView: StationsViewController  = pendingViewControllers[0] as StationsViewController
        currentView.appsTableView?.refreshLocation()
    }

    func setPageControlDot() {
        let currentViewController = getCurrentView()
        currentPageIndex = currentViewController.pageIndex
        let pc: UIPageControl? = self.navigationItem.titleView?.viewWithTag(50) as UIPageControl?
        if (pc != nil) {
            pc?.currentPage = currentPageIndex!
        }
    }

    func getCurrentView() -> StationsViewController {
        return self.viewControllers[0] as StationsViewController
    }

    func setSearchButton() {
        var searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchClicked:")
        self.navigationItem.rightBarButtonItem = searchButton
    }
    
    func searchClicked(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ssv: StationsSearchViewController = storyboard.instantiateViewControllerWithIdentifier("StationsSearchView") as StationsSearchViewController;

        self.navigationController?.pushViewController(ssv, animated: false)
    }

    func aboutClicked(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController! = storyboard.instantiateViewControllerWithIdentifier("AboutViewController") as UIViewController
        self.navigationController?.presentViewController(vc, animated: true, completion: nil)

    }
}