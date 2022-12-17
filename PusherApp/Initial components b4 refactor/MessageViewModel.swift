//
//  MessageViewModel.swift
//  PusherApp
//
//  Created by matt naples on 12/10/22.
//

import Foundation
import SwiftUI
public enum ApplicationError: Error{
    ///any general problem with the network that provides additional info
    case networkConnectionError(String)
    /// an error that contains a user friendly message and an underlying error
    case generalError(String, Error)
}

enum SubscriptionState{
    case unsubscribed
    case loading
    case loaded(Message)
    case error(ApplicationError)
    func isInSameStateAs(_ otherState: SubscriptionState) -> Bool{
        if case .loaded(_) = self, case .loaded(_) = otherState{
            return true
        }
        if case .loading = self, case .loading = otherState{
            return true
        }
        if case .unsubscribed = self, case .unsubscribed = otherState{
            return true
        }
        if case .error(_) = self, case .error(_) = otherState{
            return true
        }
        return false
    }
}
class MessageViewModel: ObservableObject{
    let messageService: MessageService
    init(messageService: MessageService){
        self.messageService = messageService
    }
    @Published  private(set) var subscriptionState: SubscriptionState = .unsubscribed
    @MainActor
    func subscribe(){
        guard case .unsubscribed = self.subscriptionState else{
            return // ensures we can't double subscribe.
        }
        messageService.subscribe { result in
            withAnimation {
                switch result{
                case .success(let message):
                    DispatchQueue.main.async {
                        self.subscriptionState = .loaded(message)
                    }
               
                case .failure(let error):
                    self.subscriptionState = .error(error)
                }
                }
            }
         
        
    }
    func unsubscribe(){
        messageService.unsubscribe()
        self.subscriptionState = .unsubscribed
    }
}
