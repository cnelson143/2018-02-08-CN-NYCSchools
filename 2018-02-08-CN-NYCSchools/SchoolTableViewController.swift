//
//  ViewController.swift
//  2018-02-08-CN-NYCSchools
//
//  Created by Christopher Nelson on 2/8/18.
//  Copyright © 2018 Odeon Software Inc. All rights reserved.
//

import UIKit

class SchoolTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating,  UISearchBarDelegate, SelectDelegate
{
    let nycSchoolURLString = "https://data.cityofnewyork.us/resource/97mf-9njv.json"
    let nycSchoolScoreURLString = "https://data.cityofnewyork.us/resource/734v-jeq5.json";

    @IBOutlet weak var tableView: UITableView!
    
    var searchResultsTableViewController = UITableViewController.init()
    var searchController: UISearchController?
    
    var searchFilteredItems: Array<SchoolDataObject> = []
    
    var selectedBorough: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "NYC Schools2"
        
        if let selectedBoroughTemp = UserDefaults.standard.object(forKey: "selectedBorough") as? String
        {
            selectedBorough = selectedBoroughTemp
        }
        
        tableView.register(UINib.init(nibName: "SchoolTableViewCell", bundle: nil), forCellReuseIdentifier: "schoolCell")
        
        let refreshControl : UIRefreshControl! = UIRefreshControl.init()
        refreshControl.addTarget(self, action: #selector(refreshControlUpdate), for: .valueChanged)
        tableView.refreshControl = refreshControl;

        searchController = UISearchController.init(searchResultsController: searchResultsTableViewController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController?.searchBar
        
        // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
        searchResultsTableViewController.tableView.delegate = self
        searchResultsTableViewController.tableView.dataSource = self

        searchController?.delegate = self
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = true;
        searchController?.searchBar.delegate = self; // so we can monitor text changes + others
        
        definesPresentationContext = true;  // know where you want UISearchController to be displayed

        searchResultsTableViewController.tableView.register(UINib.init(nibName: "SchoolTableViewCell", bundle: nil), forCellReuseIdentifier: "schoolCell")

        tableView.refreshControl?.beginRefreshing()

        refreshControlUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedBorough.count == 0
        {
            self.title = "NYC Schools2 (All)"
        }
        else
        {
            self.title = String.init(format: "NYC Schools2 (%@)", arguments: [self.selectedBorough])
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func refreshControlUpdate()
    {
        var myboroughs : Array<String>?
        
        if selectedBorough.count > 0
        {
            myboroughs = [selectedBorough]
        }
        ApplicationDataObject.shared.loadShchoolData(forURL: nycSchoolURLString, withScoresURL: nycSchoolScoreURLString, boroughs: myboroughs) { (success, error) in
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
                self.tableView.refreshControl?.endRefreshing()
                
                if success
                {
                    print("Success")
                }
                else
                {
                    print("No Success")
                }

            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if (tableView == self.searchResultsTableViewController.tableView)
        {
            return self.searchFilteredItems.count;
        }

        return ApplicationDataObject.shared.schoolList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath) as! SchoolTableViewCell
        
        var schoolDataObject : SchoolDataObject!
        if(tableView == self.searchResultsTableViewController.tableView)
        {
            schoolDataObject = self.searchFilteredItems[indexPath.row];
        }
        else
        {
            schoolDataObject = ApplicationDataObject.shared.schoolList[indexPath.row];
        }

        cell.schoolLabel.text = schoolDataObject.schoolName!
        cell.addressLabel.text = schoolDataObject.address!
        cell.cityStZipLabel.text = String.init(format: "%@, %@ %@", arguments: [schoolDataObject.city!, schoolDataObject.state!, schoolDataObject.zip!])
        if let borough = schoolDataObject.borough
        {
            cell.boroughLabel.text = borough
        }
        
        if(indexPath.row % 2 == 0)
        {
            cell.backgroundColor = UIColor.init(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.0)
        }
        else
        {
            cell.backgroundColor = UIColor.white
        }
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var schoolDataObject : SchoolDataObject!
        if(tableView == self.searchResultsTableViewController.tableView)
        {
            schoolDataObject = self.searchFilteredItems[indexPath.row];
        }
        else
        {
            schoolDataObject = ApplicationDataObject.shared.schoolList[indexPath.row];
        }

        self.performSegue(withIdentifier: "schoolDetailSegue", sender: schoolDataObject)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 125
        
    }
    
    func didPerformSelection(selection: String)
    {
        selectedBorough = selection
        
        UserDefaults.standard.setValue(selectedBorough, forKey: "selectedBorough")
        
        DispatchQueue.main.async {
            
            self.tableView.refreshControl?.beginRefreshing()
            ApplicationDataObject.shared.resetSchoolData()
            self.tableView .reloadData()
            
            self.dismiss(animated: true, completion: {
                
                self.refreshControlUpdate()
                
            })
            
        }
    }
    
    func didCancelSelection()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UISearchControllerDelegate
    
    func willPresentSearchController(_ searchController: UISearchController) {
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
        self.searchFilteredItems.removeAll()
        
        self.tableView.reloadData()
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchString = searchController.searchBar.text;
        
        var filtered : Array<SchoolDataObject>  = ApplicationDataObject.shared.schoolList.filter{$0.schoolName!.lowercased().contains(searchString!.lowercased())}
        filtered.sort(by: { (obj1, obj2) -> Bool in
            
            return obj1.schoolName! < obj2.schoolName!
            
        })
        searchFilteredItems = filtered
        //filteredArrayUsingPredicate:predicate];
        self.searchResultsTableViewController.tableView.reloadData()
    }

    // Mark: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var pass = true
        
        if identifier == "selectBoroughSegue"
        {
            if ApplicationDataObject.shared.schoolList.count > 0
            {
                pass = true
            }
            else
            {
                pass = false
            }
        }
        
        return pass;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if(segue.identifier == "schoolDetailSegue")
        {
            let schoolData : SchoolDataObject = sender as! SchoolDataObject;
            let schoolVC : SchoolDetailViewController = segue.destination as! SchoolDetailViewController;
            schoolVC.schoolData = schoolData;
        }
        else if(segue.identifier == "selectBoroughSegue")
        {
            let navCtrl : UINavigationController = segue.destination as! UINavigationController
            let selectionViewController : SelectionViewController = navCtrl.topViewController as! SelectionViewController
            
            selectionViewController.delegate = self
            selectionViewController.selectedText = selectedBorough
            selectionViewController.includeAll = true
            selectionViewController.selectionArray = ApplicationDataObject.shared.borooghList
        }
    }
}

