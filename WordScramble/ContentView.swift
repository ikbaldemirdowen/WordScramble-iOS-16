//
//  ContentView.swift
//  WordScramble
//
//  Created by Ikbal Demirdoven on 2023-01-19.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var newGamePressed = false
    @State private var newGameAlertTitle = ""
    @State private var newGameAlertMessage = ""
    @State private var allWordss = [String]()
    @State private var score = 0
    
    var body: some View {
        NavigationStack
        {
            List
            {
                Section
                {
                    TextField("Enter your word here.", text: $newWord)
                        .autocapitalization(.none)
                        .onSubmit {
                            addNewWord()
                        }
                }
                Section("Used words")
                {
                    ForEach(usedWords, id: \.self)
                    { word in
                        HStack
                        {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .toolbar()
            {
                Button("New Game", action: newGame)
            }
            .alert(newGameAlertTitle, isPresented: $newGamePressed)
            {
                Button("OK") {}
            } message: {
                Text(newGameAlertMessage)
            }
            .navigationTitle(rootWord)
            Text("Score \(score)")
                .font(.largeTitle)
        }
        .onAppear(perform: startTheGame)
        .alert(errorTitle, isPresented: $showingError)
        {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    func addNewWord()
    {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //checking the words validity before proceeding
        guard answer.count >= 3 || answer != rootWord else { return }
        guard isOriginal(word: answer) else
        {
            wordError(title: "Not original", message: "You already used \(answer).")
            return
        }
        
        guard isPossible(word: answer) else
        {
            wordError(title: "Not applicable", message: "You can't spell \(answer) from \(rootWord).")
            return
        }
        
        guard isReal(word: answer) else
        {
            wordError(title: "Unknown word.", message: "I don't know what \(answer) is.")
            return
        }
        
        withAnimation
        {
            usedWords.insert(answer, at: 0)
        }
        increaseScore()
        newWord = ""
        
    }
    
    func startTheGame()
    {
        //finding the file
        if let file = Bundle.main.url(forResource: "start", withExtension: "txt")
        {
            //parsing the content of the file to a string
            if let content = try? String(contentsOf: file)
            {
                let allWords = content.components(separatedBy: "\n")
                allWordss = allWords
                rootWord = allWords.randomElement() ?? "Error! No word found!"
                return
            }
        }
        fatalError("Couldn't find the source file for words in the bundle.")
    }
    
    func isOriginal(word : String) -> Bool
    {
        if usedWords.contains(word)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func isPossible(word : String) -> Bool
    {
        var tempWord = rootWord
        for letter in word
        {
            if let pos = tempWord.firstIndex(of: letter)
            {
                tempWord.remove(at: pos)
            }
            else
            {
                return false
            }
        }
        return true
    }
    
    func isReal(word : String) -> Bool
    {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if misspelledRange.location == NSNotFound
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func wordError(title : String, message : String)
    {
        errorMessage = message
        errorTitle = title
        showingError = true
    }
    
    func newGame()
    {
        newGamePressed = true
        newGameAlertTitle = "New game started."
        newGameAlertMessage = "Word has changed. Score resetted."
        rootWord = allWordss.randomElement() ?? "Error! No word found!"
        usedWords = [String]()
        score = 0
    }
    
    func increaseScore()
    {
        score += newWord.count
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
