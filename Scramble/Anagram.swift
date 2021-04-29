//
//  Anagram.swift
//  ScrambleSolver
//
//  Created by Ricardo Varjão on 21/02/21.
//

import Foundation

enum Idiom {
    case pt_br, en
}



class Anagram : ObservableObject{
    
    var letters : String = ""
    var idiom : Idiom = Idiom.pt_br
    
    var words : [Int : [String]]! = [:]
    private var _isRunning = false
    var isRunning : Bool{
        get{
            return _isRunning
        }
    }
    var _shouldStopProccess = false;
    
    func findWords (_ _letters : String?, completion: @escaping(_ success:Bool, [Int : [String]]?, Bool) -> Void) -> Void{
        self._shouldStopProccess = false
        
        if (_letters != nil){
            letters = _letters!.trimmingCharacters(in: .whitespaces)
        }
        if (letters.count < 3)  {
            completion(false, nil, false)
            return
        }
        if (letters.count > 7)  {
            completion(false, nil, false)
            return
        }
        let lowerLetters = letters.lowercased()
        let allAnagrams = Anagram.permute(letters: lowerLetters)
        let filesNames = [Idiom.en : "words-en", Idiom.pt_br : "words-pt_br"]
        let globalQueue = DispatchQueue.global()
        let lock = NSLock()
        var words = Dictionary<Int, [String]>()
        _isRunning = true
        for len in 3 ... self.letters.count{
            globalQueue.async {
                let filename = "\(filesNames[self.idiom] ?? "")-\(len)"
                if let path = Bundle.main.path(forResource: filename, ofType: "txt"){
                    do {
                        let wordsFile = try String.init(contentsOf: URL(fileURLWithPath: path), encoding: .ascii)
                        let wordBank = wordsFile.components(separatedBy: "\n")
                        var currentWords : [String] = []
                        let anagrams = Array(allAnagrams.map{anagram in String(anagram.prefix(len))})
                        let uniqAnagrams = Array<String>(Set(anagrams))

                        for word in uniqAnagrams{
                            if (self._shouldStopProccess){
                                self._isRunning = false
                                completion(true, self.words, false)
                                break
                            }
                            
                            if (wordBank.contains(word)){
                                currentWords.append(word)
                            }
                        }
                        lock.lock()
                        words[len] = currentWords
                        lock.unlock()
                        }
                    catch{
                        print(error)
                        print("Erro ao abrir arquivo")
                        DispatchQueue.main.async {
                            self._isRunning = false
                            completion(true, self.words, false)
                            return
                        }
                    }
                    lock.lock()
                    self.words = words
                    lock.unlock()
                    DispatchQueue.main.async {
                        let minimumWordsLength = 3
                        completion(true, self.words, (self.words.count < (self.letters.count - (minimumWordsLength - 1))))
                        return
                    }
                }else{
                    print("Erro ao abrir arquivo")
                    DispatchQueue.main.async {
                        self._isRunning = false
                        completion(true, self.words, self._isRunning)
                        return
                    }
                    return
                }
            }
        }
    }

    func stopProcess(){
        if (isRunning){
            _shouldStopProccess = true
        }
    }
    
    static private func swap(arr: inout [Character], from: Int, to: Int){
        let t = arr[from]
        arr[from] = arr[to]
        arr[to] = t
    }
    
    static func factorial (n: Int) -> Int{
        if (n == 0) {
            return 1
        }
        return n * factorial(n: n - 1)
    }

    private static func permute (letters: String) -> [String]{
        var arrLetters = Array(letters)
        var anagrams = [String]()
        return _permute(letters: &arrLetters, anagrams: &anagrams)
    }


    private static func _permute (letters: inout [Character], anagrams: inout [String], i : Int = 0) -> [String]{
        if (i == letters.count){
            anagrams.append(letters.reduce("", {acc, letter in acc + "\(letter)"}))
        }else{
            let n = letters.count
            for j in i..<n{
                swap(arr: &letters, from: i, to: j)
                let _ = _permute(letters: &letters, anagrams: &anagrams, i: i + 1)
                swap(arr: &letters, from: i, to: j)
            }
        }
        return anagrams
    }

    
}
