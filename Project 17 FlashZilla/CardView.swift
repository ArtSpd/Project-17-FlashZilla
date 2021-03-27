//
//  CardView.swift
//  Project 17 FlashZilla
//
//  Created by Артем Волков on 19.03.2021.
//

import SwiftUI

struct CardView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithColors
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    let card: Card
    var removal: (() -> Void)? = nil
    
    
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    
    @State private var feedback = UINotificationFeedbackGenerator()
    
    
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .fill(
                    differentiateWithColors ?
                        Color.white :
                        Color.white
                        .opacity(1 - Double(abs(self.offset.width / 50))))
                .background(
                    differentiateWithColors ? nil :
                        RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .fill(self.offset.width > 0 ? Color.green : Color.red))
                
                .shadow(radius: 10)
            VStack{
                if accessibilityEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                    if isShowingAnswer{
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 3, y: 0)
        .accessibilityAddTraits(.isButton)
        .opacity(2 - Double(abs(offset.width / 50)))
        .gesture(
            DragGesture()
                .onChanged{ gesture in
                    self.offset = gesture.translation
                    self.feedback.prepare() 
                }
                .onEnded{ _ in
                    if abs(self.offset.width) > 100{
                        if self.offset.width > 0 {
                            self.feedback.notificationOccurred(.success)
                        } else {
                            self.feedback.notificationOccurred(.error)
                        }
                        self.removal?()
                        
                    } else{
                        self.offset = .zero
                    }
                    
                }
        )
        .onTapGesture{
            self.isShowingAnswer.toggle() 
        }
        .animation(.spring() )
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example )
    }
}
