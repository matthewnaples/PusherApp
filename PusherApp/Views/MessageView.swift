//
//  MessageView.swift
//  PusherApp
//
//  Created by matt naples on 12/16/22.
//

import SwiftUI
struct MessageView: View{
    let message: Message
    @State private var titleAppeared = false
    @State private var bodyAppeared =  false
    @State private var sizeAppeared =  false
    var body: some View{
        VStack(alignment: .leading){
            Text(message.title.capitalized)
                .font(.title)
                .offset(x: titleAppeared ? 0 : -100)
                .opacity(titleAppeared ? 1 : 0)
                .transition(
                    .offset(x: -100).animation(.interpolatingSpring(stiffness: 10, damping: 10))
                        .combined(with: .opacity)
                )
            Text(message.body)
                .offset(x: bodyAppeared ? 0 : -100)

                .opacity(bodyAppeared ? 1 : 0)

            Text("\(message.size) bytes")
                .offset(x: sizeAppeared ? 0 : -100)
                .opacity(sizeAppeared ? 1 : 0)

        }
        .onAppear(perform: fadeIn)
        .onDisappear(perform: fadeOut)
    }
    func fadeIn() {
        withAnimation(.introMessage.delay(0.2)) {
            titleAppeared = true
        }
        withAnimation(.introMessage.delay(0.4)) {
            bodyAppeared = true
        }
        withAnimation(.introMessage.delay(0.6)) {
            sizeAppeared = true
        }
    }
    
    func fadeOut() {
        withAnimation(.introMessage.delay(0.5)) {
            titleAppeared = false
        }
        withAnimation(.introMessage.delay(1)) {
            bodyAppeared = false
        }
        withAnimation(.introMessage.delay(1.5)) {
            sizeAppeared = false
        }

    }
}
