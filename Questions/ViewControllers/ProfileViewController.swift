//
//  ProfileViewController.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import ParseUI
import ChameleonFramework
import Parse

class ProfileViewController: PFQueryTableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var questionsLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var editProfileButton: UIButton!
    
    let colorPicker = CategoryHelper()
    var user: PFUser?
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white]
        
        editProfileButton.layer.borderWidth = 1.0
        editProfileButton.layer.borderColor = UIColor.flatGray().cgColor
        editProfileButton.backgroundColor = UIColor.white
        
        profilePicView.layer.cornerRadius = profilePicView.frame.width / 2
        profilePicView.clipsToBounds = true
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if(user == nil) {
            user = PFUser.current()
        }
        
        getUsername { (username) in
            self.fullNameLabel.text = username
        }
        
        getProfilePic((user)!, completionHandler: { (image) in
            self.profilePicView.image = image
        })
        
        getNumLikes { (numLikes) in
            self.likesLabel.text = "\(numLikes)"
        }
        
        getNumAnswers { (numAnswers) in
            self.answersLabel.text = "\(numAnswers)"
        }
        
        getNumQuestions { (numQuestions) in
            self.questionsLabel.text = "\(numQuestions)"
        }
        
        getBio(user!) { (bio) in
            self.bioLabel.sizeToFit()
            self.bioLabel.text = bio
        }
        
        self.objectsPerPage = 5
        self.loadObjects()
    }
    
    // get posts made by current user
    override func queryForTable() -> PFQuery<PFObject> {
        let query = PFQuery(className: "Post")
        query.includeKey("user")
        query.whereKey("user", equalTo: user)
        query.order(byDescending: "createdAt")
        query.limit = 100
        return query
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profilePostCell") as! ProfileCellView
        let question = object as! Question
        cell.categoryLabel.text = question.category
        cell.categoryBox.backgroundColor = colorPicker.colorChooser(question.category!)
        cell.questionLabel.text = question.question
        cell.timeLabel.text = (question.createdAt as NSDate?)?.shortTimeAgo(since: Date())
        return cell
    }
    
    //MARK: Downloads
    
    func getProfilePic(_ user: PFUser, completionHandler: @escaping (UIImage) -> Void) {
        let profile = user
        if let picture = profile.object(forKey: "profilePic") as? PFFile {
            picture.getDataInBackground(block: { (data, error) in
                if (data != nil) {
                    completionHandler(UIImage(data: data!)!)
                }
            })
        }
    }
    
    func getBio(_ object: PFObject, completionHandler: @escaping (String) -> Void) {
        user?.fetchInBackground { user, error in
            if(user!["bio"] != nil) {
                completionHandler(user!["bio"] as! String)
            }
            else {
                completionHandler("You don't have a bio!")
            }
        }
    }
    
    func getUsername(_ completionHandler: @escaping (String) -> Void) {
        user?.fetchInBackground { user, error in
            completionHandler((self.user?.username)!)
        }
    }
    
    func getNumLikes(_ completionHandler: @escaping (Int) -> Void) {
        let query = PFQuery(className: "Like")
        query.whereKey("fromUser", equalTo: user ?? PFUser.current)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    func getNumQuestions(_ completionHandler: @escaping (Int) -> Void) {
        let query = PFQuery(className: "Post")
        query.whereKey("user", equalTo: user ?? PFUser.current)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    func getNumAnswers(_ completionHandler: @escaping (Int) -> Void) {
        let query = PFQuery(className: "Reply")
        query.whereKey("fromUser", equalTo: user)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    //MARK: Segue Methods
    
    @IBAction func unwindToProfileViewController(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = self.objects![indexPath!.row] as? Question
                let detail = segue.destination as! DetailContainerViewController
                detail.question = obj
            }
        }
    }
}
