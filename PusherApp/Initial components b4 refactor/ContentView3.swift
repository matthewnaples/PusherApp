//
//  ContentView3.swift
//  PusherApp
//
//  Created by matt naples on 8/2/23.
//

import SwiftUI

struct ContentView3: View {
    var messageService: MessageService
    @State private var message: Message?
    @State private var initialLoad = true
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
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
        .onAppear {
            messageService.subscribe(onReceive: handleMessage(result:))
        }
        .onDisappear {
            messageService.unsubscribe()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase{
            case .active:
                messageService.subscribe(onReceive: handleMessage(result:))
            default:
                messageService.unsubscribe()
            }
        }
    }
    

    private func handleMessage(result: Result<Message, ApplicationError>){
     
        DispatchQueue.main.async {
            withAnimation {
                self.initialLoad = false
                switch result{
                case .failure(_):
                    //eat the error
                    print("error occurred")
                case .success(let message):
                        self.message = message
                }
            }
        }
    }
}

