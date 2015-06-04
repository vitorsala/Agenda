//
//  MateriasTableViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/1/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit
import EventKit

class MateriasTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var arrayMaterias = NSMutableArray()
    
    let em:EventManager = EventManager.sharedInstance;


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Se o usuário não permitiu que usassem o calendário anteriormente, pergunta de novo lol.
        if(!em.verificaPermissao()){
            em.eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
                {[weak self] (granted: Bool, error: NSError!) -> Void in
                    if granted {
                        //NSNotificationCenter.defaultCenter().addObserver(self!.em, selector: "calendarioUpdated", name: EKEventStoreChangedNotification, object: nil);
                        println("porra ligo no granted");
                    } else {
                        println("Access denied")
                    }
                })
        }

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        arrayMaterias = NSMutableArray(array: MateriaManager.sharedInstance.fetchAllMaterias())
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        arrayMaterias = NSMutableArray(array: MateriaManager.sharedInstance.fetchAllMaterias())
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMaterias.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        cell.textLabel?.text = (arrayMaterias.objectAtIndex(indexPath.row) as! Materia).nomeMateria
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tarefaTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TarefasTVC") as! TarefaTableViewController
        tarefaTVC.materia = self.arrayMaterias.objectAtIndex(indexPath.row) as! Materia
        self.navigationController?.pushViewController(tarefaTVC, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
