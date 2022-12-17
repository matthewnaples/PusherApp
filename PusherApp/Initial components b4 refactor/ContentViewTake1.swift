//
//  ContentView.swift
//  PusherApp
//
//  Created by matt naples on 12/9/22.
//

import SwiftUI
import PusherSwift


struct ContentViewTake1: View {
    //MARK: Would not like to have the service here. Rather, we'd like it in a view model....
    let messageService: MessageService
    @State private var title: String?
    @State private var messageBody: String?
    @State private var size: Int?
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        VStack{
            Text(title ?? "no message message title :(.")
            Text(messageBody ?? "no message")
            Text(size == nil ? "no size" : "\(size!)")
        }
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
            switch result{
            case .failure(_):
                //eat the error
                print("error occurred")
            case .success(let message):
                DispatchQueue.main.async {
                    self.title = message.title
                    self.messageBody = message.body
                    self.size = message.size
                }
            }
        
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewTake1(messageService: PusherMessageService())
    }
}
