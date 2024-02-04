//
//  ContentView4.swift
//  PusherApp
//
//  Created by matt naples on 8/2/23.
//

import SwiftUI

struct ContentView4: View {
    var messageService: MessageService
    @State private var message: Message?
    @State private var initialLoad = true
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        MessageListenerView(messsageService: self.messageService, onUpdate: handleMessage(_:)) {
            VStack{
                Spacer()
                if initialLoad{
                    VStack{
                        ScalingCircleLoadingView()
                        Text("Connecting to message stream...")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .background(.ultraThinMaterial))
                } else{
                    if let message = message {
                        MessageView(message: message)
                            .transition(.asymmetric(insertion: .fade(offset: -200), removal: .fade(offset: 200)))
                    }
                }
                Spacer()
            }
            .padding()
        }
    }

    private func handleMessage(_ result: Message){
        DispatchQueue.main.async {
            withAnimation {
                self.initialLoad = false
                self.message = message
            
            }
        }
    }
}

