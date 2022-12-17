//
//  MessageService.swift
//  PusherApp
//
//  Created by matt naples on 12/10/22.
//

import Foundation
public protocol MessageService{
    func subscribe(onReceive: @escaping (Result<Message,ApplicationError>) -> Void)
    func unsubscribe()
}
