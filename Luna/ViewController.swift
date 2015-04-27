//
//  ViewController.swift
//  Luna
//
//  Created by Andrew Shepard on 3/1/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import UIKit

let myContext = UnsafeMutablePointer<Void>()

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var model: LunarPhaseModel!
    
    override func awakeFromNib() {
        self.model = LunarPhaseModel()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private lazy var dataSource: PhasesDataSource = {
        return PhasesDataSource(model: self.model)
    }()
    
    private lazy var headerView: LunarHeaderView? = {
        let nib = NSBundle.mainBundle().loadNibNamed(LunarHeaderView.nibName, owner: self, options: nil)
        if let headerView = nib.first as? LunarHeaderView {
            if self.traitCollection.userInterfaceIdiom == .Pad {
                headerView.frame = CGRectInset(UIScreen.mainScreen().bounds, 0.0, 200.0)
            }
            else {
                headerView.frame = UIScreen.mainScreen().bounds
            }
            return headerView
        }
        return nil
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.pagingEnabled = true
        self.tableView.rowHeight = 44.0
        
        // gradient
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.hexColor("232526").CGColor, UIColor.hexColor("414345").CGColor]
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
        self.view.backgroundColor = UIColor.redColor()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorColor = UIColor.lightGrayColor()
        
        //ugly
        self.dataSource.tableView = self.tableView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "modelDidUpdate:", name: MoonDidUpdateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveError:", name: LunarModelDidReceiveErrorNotification, object: nil)
        
        self.model.addObserver(self, forKeyPath: "loading", options: NSKeyValueObservingOptions.New, context: myContext)
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.tableHeaderView = self.headerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if self.model == object as? LunarPhaseModel && keyPath == "loading" && context == myContext {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = self.model.loading
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - Update Handlers

    func didReceiveError(notification: NSNotification) -> Void {
        // TODO: add end user error handling
        println("error notification: \(notification.userInfo)")
    }
    
    func modelDidUpdate(notification: NSNotification) -> Void {
        self.updateLunarViewModel()
    }
    
    func updateLunarViewModel() -> Void {
        let result = self.model.currentMoon
        
        switch result {
        case .Success(let moon):
            let viewModel = LunarViewModel(moon: moon.unbox)
            self.headerView?.viewModel = viewModel
        case .Failure(let reason):
            println("error updating view model, no data")
        }
    }
}

