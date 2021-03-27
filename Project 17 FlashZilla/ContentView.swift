//
//  ContentView.swift
//  Project 17 FlashZilla
//
//  Created by Артем Волков on 19.03.2021.
//

import SwiftUI

extension View{
    func stacked(at position: Int, in total: Int )-> some View{
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

struct ContentView: View {
    @State private var cards = [Card]()
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentatiateWithColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    
    @State private var timerRemaining = 10
    @State private var isActive = true
    
    @State private var isShowingEditScreen = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack{
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                Text("Time: \(self.timerRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(Capsule()
                                    .fill(Color.black)
                                    .opacity(0.75))
                ZStack{
                    ForEach(0..<cards.count, id:\.self){ index in
                        CardView(card: self.cards[index]){
                            withAnimation {
                                self.removeCard(at: index)
                            }
                        }
                        .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                        .stacked(at: index, in: cards.count)
                    }
                }
                .allowsHitTesting(timerRemaining > 0)
                
                
                if cards.isEmpty || timerRemaining == 0{
                    Button("Start again", action: resetCard)
                        .padding()
                        .foregroundColor(.white)
                        .background(Capsule()
                                        .fill(Color.black)
                                        .opacity(0.75))
                }
            }
            
            VStack{
                HStack{
                    Spacer()
                    
                    Button(action: { self.isShowingEditScreen = true }){
                        Image(systemName: "plus.circle")
                            .padding()
                            .font(.largeTitle)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding()
            
            if differentatiateWithColor || accessibilityEnabled {
                VStack{
                    Spacer()
                    HStack {
                        Button(action:{
                            withAnimation(){
                                removeCard(at: self.cards.count - 1)
                            }
                        }){
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                            
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as uncorrect"))
                        Spacer()
                        Button(action:{
                            withAnimation(){
                                removeCard(at: self.cards.count - 1)
                            }
                        }){
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding()
                    }
                    .accessibility(label: Text("Correct"))
                    .accessibility(hint: Text("Mark your answer as correct"))
                }
            }
        }
        .onReceive(timer){ time in
            guard self.isActive else { return }
            if self.timerRemaining > 0 {
                self.timerRemaining -= 1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)){ _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)){ _ in
            if self.cards.isEmpty == false{
                self.isActive = true
            } 
        }
        .sheet(isPresented: $isShowingEditScreen, onDismiss: resetCard){
            EditView()
        }
        .onAppear(perform: resetCard)
    }

    
    func removeCard(at index: Int){
        guard index >= 0 else { return }
        cards.remove(at: index)
        
        if cards.isEmpty{
            isActive = false
        }
    }
    
    func resetCard(){
        self.timerRemaining = 10
        isActive = true
        loadData()
    }
    
    func loadData(){
        if let data = UserDefaults.standard.data(forKey: "Cards"){
            if let decoded = try? JSONDecoder().decode([Card].self, from: data){
                self.cards = decoded
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
