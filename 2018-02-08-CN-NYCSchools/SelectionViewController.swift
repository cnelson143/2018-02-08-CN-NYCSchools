//
//  SelectionViewController.swift
//  2018-02-08-CN-NYCSchools
//
//  Created by Christopher Nelson on 2/12/18.
//  Copyright © 2018 Odeon Software Inc. All rights reserved.
//

import UIKit

protocol SelectDelegate {

    func didPerformSelection(selection : String)
    func didCancelSelection()

}

class SelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    var delegate : SelectDelegate?
    var selectedText : String?
    var selectionArray : Array<String> = []
    var includeAll : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(includeAll)
        {
            selectionArray.insert("All", at: 0)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return selectionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectionCell", for: indexPath)
        
        let selectionText : String = selectionArray[indexPath.row];
        
        cell.textLabel!.text = selectionText
        cell.accessoryType = .none;
        if selectionText == self.selectedText
        {
            cell.accessoryType = .checkmark;
        }
        else if(self.includeAll && indexPath.row == 0 && selectionText == "All" && self.selectedText?.count == 0)
        {
            cell.accessoryType = .checkmark;
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var selectionText : String = selectionArray[indexPath.row];
        
        if(includeAll && indexPath.row == 0)
        {
            selectionText = ""
        }
        
        if(delegate != nil)
        {
            delegate!.didPerformSelection(selection: selectionText)
        }
    }

    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem)
    {
        if(delegate != nil)
        {
            delegate!.didCancelSelection()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
