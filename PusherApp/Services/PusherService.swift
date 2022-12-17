//
//  PusherService.swift
//  PusherApp
//
//  Created by matt naples on 12/9/22.
//

import Foundation
import PusherSwift

struct PusherInfo{
    static let app_id = "780628"
    static let key = "5d3657875c763e1b0282"
    static let cluster = "us3"
    static let channel = "sample"
    static let event = "sampleMessage"
}
class TransparentPusherService: PusherDelegate{
    static let shared = TransparentPusherService()
    let pusher: Pusher
    var channel: PusherChannel?
    private init(){
        let options = PusherClientOptions(
            host: .cluster(PusherInfo.cluster)
        )
        self.pusher = Pusher(key: PusherInfo.key, options: options)
//        pusher.connect()
        pusher.delegate = self
    }
 
    
//    private func connect(){
//        pusher.connect()
//    }
    func connect(){
        pusher.connect()
    }
    func disconnect(){
        pusher.disconnect()
    }
    func subscribe() {

        channel = pusher.subscribe(channelName: PusherInfo.channel)
    }
    func unsubscribe(){
        pusher.unsubscribe(PusherInfo.channel)
    }
    func globalBind(callback: @escaping (PusherEvent) -> Void){
        pusher.bind(eventCallback: { event in
            callback(event)
        })
    }
    func bind(callback: @escaping (PusherEvent) -> Void){
        channel?.bind(eventName: PusherInfo.event, eventCallback: { event in
            callback(event)
            
        })
        
    }
    func unbind(){
        channel?.unbindAll()
    }
    func subscribe(callback: @escaping (PusherEvent) -> Void) {
        channel = pusher.subscribe(channelName: PusherInfo.channel)
        guard let channel = channel else {
            return
        }
        channel.bind(eventName: PusherInfo.event, eventCallback: { event in
            callback(event)
            
        })
    }
//    func unsubscribe(){
//        if let channel = channel {
//            channel.unbindAll()
//            pusher.unsubscribe(channel.name)
//        }
//    }
    func subscribeToConnection(){
        
    }
    
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        print("old state \(old.stringValue())")
        print("new state \(new.stringValue())")
    }
    func subscribedToChannel(name: String) {
        print("pusher subscribed to channel: \(name)")
    }
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        print("pushed failed to subscribe to channel with name: \(name)")
    }
    func debugLog(message: String) {
        print(message)
    }
    func receivedError(error: PusherError) {
        print("pusher received an error \(error.message)")
    }
    func failedToDecryptEvent(eventName: String, channelName: String, data: String?) {
        // do nothing but just in case you need it.
    }
}
