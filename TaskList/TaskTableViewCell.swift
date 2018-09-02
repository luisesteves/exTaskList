 //
 //  File.swift
 //  TaskList
 //
 //  Created by Luís Esteves on 02/09/2018.
 //  Copyright © 2018 Michal Miko. All rights reserved.
 //
import UIKit

class TaskTableViewCell: UITableViewCell {    
    private let categoryStripeView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let labelDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let labelCategory: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .lightGray
        return label
    }()
    
    private let labelDateShouldDone: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .lightGray
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        SetUpLayoutCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     
    public func setCell(taskToShow: Task) {
        
        var dateWhenDoneNotEmpty = Task.dateShouldBeDoneToString(date: taskToShow.dateToComplete)
        if dateWhenDoneNotEmpty == "" {
            dateWhenDoneNotEmpty = "Date not set"
        }
        var categoryNameNoEmpty = ""
        if let categoryNameIsExist = taskToShow.category?.name {
            categoryNameNoEmpty = categoryNameIsExist
        } else {
            categoryNameNoEmpty = "No category"
        }
        
        if taskToShow.isItDone {
            accessoryType = .checkmark
            labelDescription.textColor = .lightGray
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: taskToShow.taskTitle)
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            labelDescription.attributedText = attributeString
        } else {
            accessoryType = .none
            labelDescription.textColor = .black
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: taskToShow.taskTitle)
            labelDescription.attributedText = attributeString
        }
        
        labelCategory.text = categoryNameNoEmpty
        categoryStripeView.backgroundColor = taskToShow.category?.color
        labelDateShouldDone.text = dateWhenDoneNotEmpty

    }
    
   
     
    fileprivate func SetUpLayoutCell() {
        
        addSubview(categoryStripeView)
        addSubview(labelDescription)
        addSubview(labelCategory)
        addSubview(labelDateShouldDone)
        
        categoryStripeView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        categoryStripeView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        categoryStripeView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        categoryStripeView.widthAnchor.constraint(equalToConstant: 5).isActive = true
        
        labelDescription.leadingAnchor.constraint(equalTo: categoryStripeView.trailingAnchor, constant: 15).isActive = true
        labelDescription.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
         
        labelDescription.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        
        labelCategory.leadingAnchor.constraint(equalTo: categoryStripeView.trailingAnchor, constant: 15).isActive = true
        labelCategory.topAnchor.constraint(equalTo: labelDescription.bottomAnchor, constant: 15).isActive = true
        labelCategory.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        labelCategory.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3).isActive = true
        
        labelDateShouldDone.leadingAnchor.constraint(equalTo: labelCategory.trailingAnchor, constant: 15).isActive = true
        labelDateShouldDone.topAnchor.constraint(equalTo: labelDescription.bottomAnchor, constant: 15).isActive = true
        labelDateShouldDone.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        labelDateShouldDone.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    }
    
    

    
    
}
