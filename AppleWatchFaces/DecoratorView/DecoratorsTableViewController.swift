//
//  DecoratorsTableViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 12/2/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

class DecoratorsTableViewController: UITableViewController {

    weak var decoratorPreviewController: DecoratorPreviewController?
    
    func addNewItem( ringType: RingTypes) {
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings.count-1, section: 0)], with: .automatic)
        self.tableView.endUpdates()
    }
    
    func redrawPreview() {
        //tell clock previe to redraw!
        if let dPreviewVC = decoratorPreviewController {
            dPreviewVC.redraw(clockSetting: SettingsViewController.currentClockSetting)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        
        //important only select one at a time
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsSelectionDuringEditing = true
        self.setEditing(true, animated: true)
        //NOTE: editingMode is set in previewController so editing mode is displayed correctly in the parent
    }
    
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        
//        //toggle selection
//        if tableView.indexPathForSelectedRow == indexPath {
//            tableView.deselectRow(at: indexPath, animated: true)
//            // animate
//            tableView.beginUpdates()
//            tableView.endUpdates()
//            
//            return nil
//        }
//        return indexPath
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //debugPrint("selected cell:" + indexPath.description)
        
        if let dPreviewVC = decoratorPreviewController {
            dPreviewVC.highlightRing(ringNumber: indexPath.row)
        }
        // animate
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if !tableView.isEditing {
            return .none
        } else {
            return .delete
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var cellHeight:CGFloat = 68
        
        guard let clockSettings = SettingsViewController.currentClockSetting.clockFaceSettings
            else { return cellHeight }
        
        let ringSetting = clockSettings.ringSettings[indexPath.row]
        
        //if selected show
        if let selectedPath = tableView.indexPathForSelectedRow {
            //debugPrint("selectedpath:" + selectedPath.description + indexPath.description)
            if selectedPath.row == indexPath.row {
                switch ringSetting.ringType {
                case .RingTypeTextNode:
                    cellHeight = 270.0
                case .RingTypeTextRotatingNode:
                    cellHeight =  270.0
                case .RingTypeShapeNode:
                    cellHeight =  160.0
                case .RingTypeDigitalTime:
                    cellHeight =  290.0
                case .RingTypeSpacer:
                    cellHeight =  cellHeight + 0
                }
            }
        }
        
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = DecoratorTableViewCell()
        
        if let clockSettings = SettingsViewController.currentClockSetting.clockFaceSettings {
            let ringSetting = clockSettings.ringSettings[indexPath.row]
            
            if (ringSetting.ringType == .RingTypeSpacer) {
                cell = tableView.dequeueReusableCell(withIdentifier: "decoratorEditorSpacerID", for: indexPath) as! DecoratorSpacerTableViewCell
            }
        
            if (ringSetting.ringType == .RingTypeShapeNode) {
                cell = tableView.dequeueReusableCell(withIdentifier: "decoratorEditorShapeID", for: indexPath) as! DecoratorShapeTableViewCell
            }
            
            if (ringSetting.ringType == .RingTypeTextNode || ringSetting.ringType == .RingTypeTextRotatingNode) {
                cell = tableView.dequeueReusableCell(withIdentifier: "decoratorEditorTextID", for: indexPath) as! DecoratorTextTableViewCell
            }
            
            if (ringSetting.ringType == .RingTypeDigitalTime) {
                cell = tableView.dequeueReusableCell(withIdentifier: "decoratorEditorDigitalTimeID", for: indexPath) as! DecoratorDigitalTimeTableViewCell
            }
            
            cell.setupUIForClockRingSetting(clockRingSetting: ringSetting)
        }
        
        cell.parentTableview = self.tableView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow = sourceIndexPath.row;
        let destRow = destinationIndexPath.row;
        
        if nil != SettingsViewController.currentClockSetting.clockFaceSettings {
            let object = SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings[sourceRow]
            SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings.remove(at: sourceRow)
            SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings.insert(object, at: destRow)
        }
        
        redrawPreview()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if nil != SettingsViewController.currentClockSetting.clockFaceSettings {
                let sourceRow = indexPath.row;
                //let trashedSetting = clockSettings.ringSettings[sourceRow]
                SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings.remove(at: sourceRow)
                tableView.deleteRows(at: [indexPath], with: .none)
                            
                redrawPreview()
            }
        
        }
    }
    
    func valueForHeader( section: Int) -> String {
        let ringSetting = SettingsViewController.currentClockSetting.clockFaceSettings!.ringSettings[ section ]
        return ringSetting.ringType.rawValue
    }
    
}
