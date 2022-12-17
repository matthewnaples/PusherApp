//
//  ContentViewFromLaptop.swift
//  PusherApp
//
//  Created by matt naples on 12/12/22.
//

import SwiftUI


struct ContentViewFinal: View {
    @State private var initialLoad = true
    @State private var message: Message?
    let messageService: MessageService
    var body: some View {
        MessageListenerView(messsageService: self.messageService, onUpdate: handleResult(_:)) {
            VStack{
                Spacer()
                if initialLoad{
                    
                    VStack{
                    ScalingCircleLoadingView()
                    Text("Connecting to message stream...")
                    }
                    
                    .padding()
                    
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous )
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
        }
    }
    private func handleResult(_ newMesage: Message) -> Void {
        DispatchQueue.main.async {
            self.initialLoad = false
            if message != nil{
                DispatchQueue.main.async {
                    withAnimation{
                        self.message = nil
                    }
                }
              
            }
            Task{
                try await Task.sleep(nanoseconds:500_000_000)
                DispatchQueue.main.async {
                    withAnimation{
                        self.message = newMesage
                    }
                }
            }
        }
    }
}

struct ContentViewFromLaptop_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewFinal(messageService: BasicCombineMessageService())
    }
}

extension AnyTransition{
    static func fade(offset: CGFloat = -100) -> AnyTransition { .offset(x: offset).combined(with: .opacity).animation(.easeInOut(duration: 0.3))
    }
}
