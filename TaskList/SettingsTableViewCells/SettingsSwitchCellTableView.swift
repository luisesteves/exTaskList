 //
 //  File.swift
 //  TaskList
 //
 //  Created by Luís Esteves on 02/09/2018.
 //  Copyright © 2018 Michal Miko. All rights reserved.
 //
import UIKit

class SwitchCell: UITableViewCell {
    
    weak var delegate: SwitchCellDelegate?
    
    private let descriptionSwitchLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .boldSystemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
   private  let cellSwitch: UISwitch = {
        let cellSwitch = UISwitch()
        cellSwitch.translatesAutoresizingMaskIntoConstraints = false
        return cellSwitch
    }()
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellSwitch.addTarget(self, action: #selector(switchHandleAction), for: .valueChanged)
        setUpLayout()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public func setTitleOfSwitch(switchDescription: String) {
        descriptionSwitchLabel.text = switchDescription
    }
    
    
    public func setSwitch(isEnabled: Bool, isOn: Bool) {
        cellSwitch.isOn = isOn
        cellSwitch.isEnabled = isEnabled
    }
    
    @objc func switchHandleAction(sender: UISwitch) {
        delegate?.switchCellTableViewValueChanged(self)
    }
    
     
    fileprivate func setUpLayout() {
        
        addSubview(descriptionSwitchLabel)
        addSubview(cellSwitch)
        cellSwitch.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        cellSwitch.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        cellSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        
        descriptionSwitchLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        descriptionSwitchLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        descriptionSwitchLabel.trailingAnchor.constraint(equalTo: cellSwitch.leadingAnchor, constant: -10).isActive = true
        descriptionSwitchLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }
    
    
    
    
}

