//
//  OrteTableViewController.swift
//  Orte
//
//  Created by Christian Liefeldt on 06.03.18.
//  Copyright © 2018 CL. All rights reserved.
//

import UIKit

var places = [Dictionary<String, String>()]
var activePlace = -1

class OrteTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let TempOrte = UserDefaults.standard.object(forKey: "places") as? [Dictionary<String, String>]{
            places = TempOrte
        }
        if places.count == 1 && places[0].count == 0 {
            places.remove(at: 0)
            places.append(["name":"Ingolstadt", "lat":"48.7665351", "lon":"11.4257541"])
        }
        
        activePlace = -1
        table.reloadData()
    }
    @IBOutlet var table: UITableView!

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            places.remove(at: indexPath.row)
            UserDefaults.standard.set(places, forKey: "places")
            table.reloadData()
        }
    }
  

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if places[indexPath.row]["name"] != nil{
            cell.textLabel?.text = places[indexPath.row]["name"]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activePlace = indexPath.row
        performSegue(withIdentifier: "toEdit", sender: nil)
        
    }
}


