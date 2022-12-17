//
//  RandomlyThrowingMessageService.swift
//  PusherApp
//
//  Created by matt naples on 12/17/22.
//

import Foundation

class RandomlyThrowingMessageService: MessageService{
    let messageService: MessageService
    init(messageService: MessageService){
        self.messageService = messageService
    }
    func subscribe(onReceive: @escaping (Result<Message, ApplicationError>) -> Void) {
        self.messageService.subscribe { result in
            if Int.random(in: 1...5) == 1{
                onReceive(.failure(.generalError("An unknown error occurred. Please contact support at someEmail@website.com", NSError())))
                return
            }
            onReceive(result)
        }
    }
    
    func unsubscribe() {
        messageService.unsubscribe()
    }
    
     
}
