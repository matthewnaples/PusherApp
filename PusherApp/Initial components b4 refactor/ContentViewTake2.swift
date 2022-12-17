//
//  ContentViewTake2.swift
//  PusherApp
//
//  Created by matt naples on 12/10/22.
//

import SwiftUI

struct ContentViewTake2: View {
    @StateObject var messageViewModel: MessageViewModel
    
    @Environment(\.scenePhase) var scenePhase
    @State private var currentMessage: Message?
    
    var body: some View {
        VStack{
            switch messageViewModel.subscriptionState{
            case .unsubscribed:
                Text("empty")
            case .loading:
                ProgressView()
            case .loaded(let message):
                if message == currentMessage && currentMessage != nil{
                MessageView(message: currentMessage!)
                    .transition(.asymmetricFadeAndSlide())
                } else{
                  Text("hi")
                        .transition(.asymmetricFadeAndSlide())
                }

            case .error(let error):
                switch error {
                case .networkConnectionError(let message), .generalError(let message, _):
                    Text(message)
                }
            }
        }
        .onReceive(messageViewModel.$subscriptionState, perform: { newValue in
            if case .loaded(let message) = newValue{
                currentMessage = message
            }
        })
        .onAppear {
            messageViewModel.subscribe()
        }
        .onDisappear {
            
            messageViewModel.unsubscribe()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase{
            case .active:
                    messageViewModel.subscribe()
            default:
                messageViewModel.unsubscribe()
            }
        }
    }
}


struct ContentViewTake2_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewTake2(messageViewModel: MessageViewModel(messageService: PusherMessageService()))
    }
}
extension Animation{
    static let introMessage = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let outroMessage = Animation.spring(response: 0.3, dampingFraction: 0.9)

}

extension AnyTransition{
    static func fadeAndSlide(distance: CGFloat = -200) -> AnyTransition{   .offset(x: distance).animation(.interpolatingSpring(stiffness: 10, damping: 10))
        .combined(with: .opacity.animation(.easeInOut))
    }
    static func asymmetricFadeAndSlide(distanceIn: CGFloat = -200, distanceOut: CGFloat = 200) -> AnyTransition{
        let insertionTransition = AnyTransition.offset(x: distanceIn).animation(.interpolatingSpring(stiffness: 10, damping: 10))
            .combined(with: .opacity.animation(.easeInOut))
        let removalTransition = AnyTransition.offset(x: distanceOut).animation(.interpolatingSpring(stiffness: 10, damping: 10).delay(2))
            .combined(with: .opacity.animation(.easeInOut(duration: 0.15)))
        return .asymmetric(insertion: insertionTransition, removal: removalTransition)
    }
}
