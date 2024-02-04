//
//  MessageListenerView.swift
//  PusherApp
//
//  Created by matt naples on 12/17/22.
//

import SwiftUI
import Network
struct MessageListenerView<Content: View>: View{
    var content: Content
    let messageService: MessageService
    @State private var errorAlert: ErrorAlert?
    @Environment(\.scenePhase) var scenePhase
    let onUpdate: (Message) -> Void
    init(messsageService: MessageService,onUpdate: @escaping (Message) -> Void, @ViewBuilder content: () -> Content){
        self.content = content()
        self.onUpdate = onUpdate
        self.messageService = messsageService
    }
    var body: some View{
        content
            .onAppear{
                messageService.subscribe(onReceive: handleResult(_:))
            }
            .onDisappear {
                messageService.unsubscribe()
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase{
                case .active:
                    messageService.subscribe(onReceive: handleResult(_:))
                default:
                    messageService.unsubscribe()
                }
            }
            .alert(item: $errorAlert){ alert in
                Alert(title: Text(alert.title), message: alert.message.map(Text.init), dismissButton: .default(Text("Try Again"), action: {
                    messageService.subscribe(onReceive: handleResult(_:))
                }))
            }
    }
    private func handleResult(_ result: Result<Message,ApplicationError>){
        switch result{
        case .failure(let applicationError):
            self.errorAlert = ErrorAlert(applicationError: applicationError)
//            messageService.unsubscribe()
        case .success(let message):
            onUpdate(message)

        }
    }
}

struct ErrorAlert: Equatable, Identifiable{
    let id = UUID()
    init(applicationError: ApplicationError){
        switch applicationError {
        case .networkConnectionError(let errorMessage):
            self.title = "Network Error"
            self.message = errorMessage
        case .generalError(let errorMessage, _):
            self.title = "Unknown Error"
            self.message = errorMessage
        }
    }
    let title: LocalizedStringKey
    let message: String?
    
}
