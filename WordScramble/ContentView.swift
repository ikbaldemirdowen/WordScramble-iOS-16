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
            .navigationTitle(rootWord)
        }
        .onAppear(perform: startTheGame)
    }
    
    func addNewWord()
    {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 1 else { return }
        
        withAnimation
        {
            usedWords.insert(answer, at: 0)
        }
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
                rootWord = allWords.randomElement() ?? "Error! No word found!"
                return
            }
        }
        fatalError("Couldn't find the source file for words in the system.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
