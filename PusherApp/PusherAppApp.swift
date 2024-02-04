//
//  PusherAppApp.swift
//  PusherApp
//
//  Created by matt naples on 12/9/22.
//

import SwiftUI

@main
struct PusherAppApp: App {
    let messageService = RateControllingMessageService(messageService:  PusherMessageService(), minimumDurationBetweenMessages: 5)
    @State private var toggle = false
    var body: some Scene {
        WindowGroup {
//            ContentViewFinal(messageService: messageService)
//            ContentViewFinal(messageService: messageService)
//            TinkeringWithPusher()
            ContentView1()
        }
    }
}


struct MyView: View {
    @State private var rectIsVisible = false
    
    var body: some View {
        VStack {
            if rectIsVisible {
                Rectangle()
                    .frame(width: 100, height: 100)
                    .transition(.slide)
            }
            
            Button(action: {
                withAnimation{ self.rectIsVisible.toggle()}
            }) {
                Text("Toggle Rectangle")
            }
        }
    }
}
