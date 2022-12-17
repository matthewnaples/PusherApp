//
//  Message.swift
//  PusherApp
//
//  Created by matt naples on 12/9/22.
//

import Foundation


public struct Message: Codable{
    let title: String
    let body: String
    let size: Int
}
extension Message: Equatable{}
//MARK: todo - make this map.
