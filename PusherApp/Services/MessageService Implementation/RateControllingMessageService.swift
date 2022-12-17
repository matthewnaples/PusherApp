//
//  RateControllingMessageService2.swift
//  PusherApp
//
//  Created by matt naples on 12/16/22.
//

import Foundation

class RateControllingMessageService: MessageService{
    let messageService: MessageService
    
    var callback: ((Result<Message, ApplicationError>) -> Void)?
    let timedQueue: TimedQueue<Result<Message, ApplicationError>>
    
    init(messageService: MessageService, minimumDurationBetweenMessages: Double = 4.0 ){
        self.messageService = messageService
        self.timedQueue = TimedQueue(minimumDurationBetweenMessages: minimumDurationBetweenMessages)
    }

    func subscribe(onReceive: @escaping (Result<Message, ApplicationError>) -> Void) {
        self.timedQueue.subscribe(onDequeue: onReceive)
        
        messageService.subscribe { [weak self] result in
            self?.timedQueue.enqueue(result)
        }
    }
    func unsubscribe() {
        messageService.unsubscribe()
        self.callback = nil
    }
}


 class TimedQueue<T>{
    let minimumDurationBetweenMessages: Double
    private var messageQueue: [T] = []
    private var timeToNextPop: Double = 0
    var callback: ((T) -> Void)?
    private var timer: Timer?

    init(minimumDurationBetweenMessages: Double){
        self.minimumDurationBetweenMessages = minimumDurationBetweenMessages
    }
     func subscribe(onDequeue: @escaping (T) -> Void ){
         self.callback = onDequeue
     }
     func enqueue(_ result:T) -> Void{
        self.messageQueue.insert(result, at: 0)
        if messageQueue.count == 1 && timeToNextPop == 0{
            callback?(messageQueue.removeLast())
        }
        if timer == nil{
            timeToNextPop = minimumDurationBetweenMessages
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] x in
                guard let self = self else {return }
                self.timeToNextPop -= 1
                if self.timeToNextPop == 0{
                    if self.messageQueue.isEmpty{
                        self.timer?.invalidate()
                        self.timer = nil
                    } else{
                        DispatchQueue.main.async {
                            self.callback?(self.messageQueue.removeLast())
                            self.timeToNextPop = self.minimumDurationBetweenMessages
                        }
                    }
                }
            }
        }
    }

}
