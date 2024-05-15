//
//  JoinedClassesCell.swift
//  break-the-ice-438
//
//  Created by Sam Hong on 12/2/23.
//

import Foundation

import UIKit

class JoinedClassesCell: UITableViewCell {
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var createGroupsButton: UIButton!

    @IBAction func createGroupsButtonTapped(_ sender: UIButton) {
        print("Create Groups button tapped")
        
    }
}

