//
//  ViewController.swift
//  Scramble
//
//  Created by Ricardo Varjão on 10/03/21.
//

import UIKit

import GoogleMobileAds

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GADBannerViewDelegate {
    

    let idioms = [Idiom.pt_br, Idiom.en]
    var words : Dictionary<Int, [String]>! = Dictionary<Int, [String]>()
    let anagram = Anagram()
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var lettersTextField: UITextField!
    
    @IBOutlet weak var tableviewWords: UITableView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var segmentControlIdiom: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        initBannerView(bannerView: bannerView, viewController: self, delegate: self)        
    }

    func reloadWords(letters: String?, idiom: Idiom){
        var newLetters = letters?.trimmingCharacters(in: .whitespaces)
        newLetters = newLetters?.components(separatedBy: .whitespaces).joined()
        newLetters = newLetters?.components(separatedBy: .decimalDigits).joined()
        newLetters = newLetters?.components(separatedBy: .punctuationCharacters).joined()
        
        anagram.stopProcess()
        words = Dictionary<Int, [String]>()
        anagram.idiom = idiom
        tableviewWords.reloadData()
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()


        anagram.findWords(newLetters) { success, words, stillRunning in
            self.words = words
            self.tableviewWords.reloadData()
            
            if (!stillRunning){
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0
            }
        }
        
    }
    
    // DELEGATES
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let letters = textField.text
        let idiom = idioms[segmentControlIdiom.selectedSegmentIndex]
        reloadWords(letters: letters, idiom: idiom)
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var onlyLetters = string
        onlyLetters = onlyLetters.components(separatedBy: .decimalDigits).joined()
        onlyLetters = onlyLetters.components(separatedBy: .controlCharacters).joined()
        onlyLetters = onlyLetters.components(separatedBy: .symbols).joined()
        onlyLetters = onlyLetters.components(separatedBy: .punctuationCharacters).joined()
        onlyLetters = onlyLetters.components(separatedBy: .whitespaces).joined()
        
        if (string.count > onlyLetters.count){
            return false
        }
        
        guard let text = textField.text else {return true}
        let newLength = text.count + string.count - range.length
        return newLength <= 7
    }


    func setUserInputIsEnabled(isEnabled: Bool){
        lettersTextField.resignFirstResponder()
        lettersTextField.isEnabled = isEnabled
        segmentControlIdiom.isEnabled = isEnabled
    }
    
    // TABLEVIEW DATASOURCE
    func numberOfSections(in tableView: UITableView) -> Int {
        if (words == nil) {
            return 1
        }
        return words.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (words == nil) {
            return ""
        }
        let keys = Array(words.keys.sorted())
        return "\(keys[section]) letters"
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        if (words == nil || words.count == 0) {
            return 0
        }
        let keys = Array(words.keys.sorted())
        let currentKey = keys[section]
        let currentWords = words[currentKey]
        return currentWords?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            return cell
        }
        if (words != nil){
            let keys = Array(words.keys.sorted())
            let currentKey = keys[indexPath.section]
            let currentWords = words[currentKey]?.sorted()
            let currentWord = currentWords?[indexPath.row]
            cell.textLabel?.text = currentWord
        }
        return cell
    }
    
    
    @IBAction func segmentControlIdiomValueChanged(_ sender: Any) {
        let letters = lettersTextField.text
        let idiom = idioms[segmentControlIdiom.selectedSegmentIndex]
        reloadWords(letters: letters, idiom: idiom)
        lettersTextField.resignFirstResponder()
    }
    
    
    /**
     BANNER DELEGATE
     */
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
}
