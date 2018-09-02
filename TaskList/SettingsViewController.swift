//
//  File.swift
//  TaskList
//
//  Created by Luís Esteves on 02/09/2018.
//  Copyright © 2018 Michal Miko. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsViewController: UITableViewController, CategoryShowCellDelegate, SwitchCellDelegate {

    weak var delegate: SettingsTableViewControllerDelegate?

    private let categoryShowID = "categoryShowID"
    private let swichCellID = "switchID"

    let notificationCenter = UNUserNotificationCenter.current()
    var isAllNotificationOff = false
    

    var arrayOfCategory = [Category]()

    private let titleSectionArray = ["Category list:", "Notification:", "Sorting by:"]

    private var notificationSettingsTitle = ["All notification Off"]
    private let notificationOnOff = false

    private let orderBySettingsTitle = ["Order by name", "Order by date"]
    private var orderBy = [true, false]
    

    private var selectedRowToExpand = -1
    private var rowExpandedLastTime = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 160))
        tableView.tableFooterView = footerView
        tableView.register(CategoryShowCell.self, forCellReuseIdentifier: categoryShowID)
        tableView.register(SwitchCell.self, forCellReuseIdentifier: swichCellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Settings"
        checkNotificationIsSet()
        tableView.reloadData()
    }
    

    fileprivate func checkNotificationIsSet() {
            notificationCenter.getPendingNotificationRequests { (notifications) in
                DispatchQueue.main.async() {
                    self.notificationSettingsTitle[0] = "Turn notification off (\(notifications.count) pending)"
                    if notifications.count == 0 {
                        self.isAllNotificationOff = true
                    } else {
                        self.isAllNotificationOff = false
                    }
                    
                    self.tableView.reloadSections([1], with: .automatic)
                    
                }
            }
    }
    

    func switchCellTableViewValueChanged(_ sender: SwitchCell) {
        guard let switchIndexPath = tableView.indexPath(for: sender) else { return }
        

        if switchIndexPath.section == 2 {
            for index in 0...orderBy.count - 1 {
                if index == switchIndexPath.row {
                    orderBy[index] = true

                    delegate?.setHowShouldBeTasksSorted(indexHowToSort: index)
                } else {
                    orderBy[index] = false
                }
            }
            tableView.reloadData()
            
        } else if switchIndexPath.section == 1 {

            notificationCenter.removeAllPendingNotificationRequests()
            checkNotificationIsSet()
        }
    }
    

    func categoryShowCellSaveButtonTapped(_ sender: CategoryShowCell) {
        guard let indexPathTappedCell = tableView.indexPath(for: sender) else  { return }
        

        guard let category = sender.getCategory() else {
            showAlert(message: "Too short category name. Try type at least 3 characters.")
            return
        }

        guard arrayOfCategory.contains(where: { tempCategory in tempCategory.name != category.name }) else {
            showAlert(message: "Category with same name already exists")
            return
        }

        if indexPathTappedCell.row == arrayOfCategory.count {

            for tempCategory in arrayOfCategory {
                if tempCategory.name == category.name {
                    showAlert(message: "Category with same name already exists")
                    return
                }
            }

            arrayOfCategory.append(category)

            delegate?.saveNewCategory(newCategory: category)
        } else {

            let oldCategory = arrayOfCategory[indexPathTappedCell.row]
            let newCategory = category

            delegate?.updateCategoryInExistingTasks(categoryToDelete: oldCategory, newCategory: newCategory)
            
        }

        selectedRowToExpand = -1
        tableView.reloadData()
    }

    func showAlert(message: String) {
        let allertController = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(allertController, animated: true, completion: nil)
    }
    override internal func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}





extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return titleSectionArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleSectionArray[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:

            return arrayOfCategory.count + 1
        case 1:
            return notificationSettingsTitle.count
        default:
            return orderBySettingsTitle.count
        }
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {

            rowExpandedLastTime = selectedRowToExpand
            selectedRowToExpand = selectedRowToExpand == indexPath.row ? -1 : indexPath.row

            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            if rowExpandedLastTime >= 0 {
                let indexPathrowExpandedLastTime = IndexPath(item: rowExpandedLastTime, section: 0)
                tableView.reloadRows(at: [indexPathrowExpandedLastTime], with: .automatic)
            }
            tableView.endUpdates()
        }
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if selectedRowToExpand == indexPath.row {
                return 95
            } else {
                return 45
            }
        } else {
            return 45
        }
        
    }
    

    fileprivate func getCellCategorySection(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryShowID, for: indexPath) as! CategoryShowCell

        if indexPath.row < arrayOfCategory.count {
            cell.setCell(category: arrayOfCategory[indexPath.row])
        } else {
            cell.setCell(category: Category(nameOfCategory: "", ColorOfCategory: .white))
        }

        selectedRowToExpand == indexPath.row ? cell.editViewIsHidden(isHidden: false) : cell.editViewIsHidden(isHidden: true)
        
        cell.delegate = self
        return cell
    }
    

    fileprivate func getCellNavigationSection(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: swichCellID, for: indexPath) as! SwitchCell
        cell.setTitleOfSwitch(switchDescription: notificationSettingsTitle[indexPath.row])
        cell.setSwitch(isEnabled: !isAllNotificationOff, isOn: isAllNotificationOff)
        cell.delegate = self
        return cell
    }
    

    fileprivate func getCellSortingSection(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: swichCellID, for: indexPath) as! SwitchCell
        cell.setTitleOfSwitch(switchDescription: orderBySettingsTitle[indexPath.row])
        cell.setSwitch(isEnabled: !orderBy[indexPath.row], isOn: orderBy[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            return getCellCategorySection(tableView, indexPath)
        case 1:
            return getCellNavigationSection(tableView, indexPath)
        default:
            return getCellSortingSection(tableView, indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red: 0.79, green: 0.85, blue: 0.31, alpha: 0.6)
    }
    
}


