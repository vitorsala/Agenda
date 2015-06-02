//
//  RelatorioViewController.swift
//  Agenda
//
//  Created by Bruno Omella Mainieri on 6/2/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import UIKit

class RelatorioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var materias:NSMutableArray!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.materias = NSMutableArray(array: MateriaManager.sharedInstance.fetchAllMaterias())
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.materias = NSMutableArray(array: MateriaManager.sharedInstance.fetchAllMaterias())
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.materias.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = (materias.objectAtIndex(indexPath.row) as! Materia).nomeMateria
        
        let media = TarefaManager.sharedInstance.getMediaSimples(materias.objectAtIndex(indexPath.row) as! Materia)
        
        if media < 0{
            cell.detailTextLabel?.text = "Nenhuma atividade registrada."
        }
        else{
            cell.detailTextLabel?.text = "\(media)"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notaTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NotaTVC") as! NotasMateriaViewController
        notaTVC.materia = self.materias.objectAtIndex(indexPath.row) as! Materia
        self.navigationController?.pushViewController(notaTVC, animated: true)
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
