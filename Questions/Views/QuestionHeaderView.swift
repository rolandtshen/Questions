//
//  QuestionHeaderView.swift
//  Questions
//
//  Created by Roland Shen on 7/20/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import UIKit
import Parse

class QuestionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var poster: PFUser?
    let newConvo = Conversation()
    
    @IBAction func messagePressed(sender: AnyObject) {
        newConvo.fromUser = PFUser.currentUser()
        newConvo.toUser = poster
        newConvo.saveInBackground()
    }
}
