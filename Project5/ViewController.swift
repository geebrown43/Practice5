//
//  ViewController.swift
//  Project5
//
//  Created by Gavin Brown on 1/10/19.
//  Copyright © 2019 DevelopIT. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords : [String] = []
    var usedWords: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: ".txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath){
                allWords = startWords.components(separatedBy: "\n")
            }
            else {
                allWords = ["silkworm"]
            }
        }
        startGame()
        
    }
    
    func startGame() {
        title = allWords.randomElement()  // sets view control title to be random word in array
        usedWords.removeAll(keepingCapacity: true) // removes all values from usedWords array
        tableView.reloadData() // method allows us to check we've loaded all the data correctly
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter", message: nil, preferredStyle: .alert)
        ac.addTextField() // adds a editable text field to UIAlertController
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac]   // trailing closure syntax - use unowned so Swift doesnt create a strong reference cycle
            (action: UIAlertAction) in  // everything for the "in" keyword describes the closure everything after is the closure -- could also use  action in --- since action is not used we could just use _ in
            let answer = ac.textFields![0]
            
            
            self.submit(answer: answer.text!)
        }
        ac.addAction(submitAction) // method is used to add AlertAction to AlertController
        present(ac, animated: true)
    }
    
    func submit(answer:String){
         let lowerAnswer = answer.lowercased()
        let errorTitle : String
        let errorMessage: String
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    if isLong(word: lowerAnswer){
                        usedWords.insert(answer, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic) // this call inserts no rows into the tableview
                        return
                    } else {
                        errorMessage = "Hey you can thinking of something better mate"
                        errorTitle = "Word to short must be greater the 3 characters"
                    }
                    
                } else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You can't just make them up"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from '\(title!.lowercased())'!"
        }
         let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
       var temp = title?.lowercased()
        for letter in word {
            if let pos = temp?.range(of: String(letter)) {   //range return optional position of where item was found -- String(letter) is used because for loop returns Characters and range expects String
                temp?.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word:String) -> Bool {
        let checker = UITextChecker() // class used to spot spelling errors
        let range = NSMakeRange(0, word.utf16.count) // used to make a string range starting at O and going through strings length -- When working with UIKit make sure you use utf16.count instead of just count
        let misspelledrange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en") // return a NSRange structure which tells where misspelling was found
        return misspelledrange.location == NSNotFound // if a misspelling was NOT found NSRange will return NSNotFound
}
    
    func isLong(word:String) -> Bool {
        return word.utf16.count >  3
    }
}
