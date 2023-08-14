struct ChatMessageViewObject {
    let id: Int
    let text: String
    let type: MessageType
    
    enum MessageType: String {
        case outcoming
        case incoming
    }
}
