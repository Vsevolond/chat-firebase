struct ChatMessageNetworkObject {
    let id: Int
    let text: String
    let type: String
    
    init(viewObject: ChatMessageViewObject) {
        self.id = viewObject.id
        self.text = viewObject.text
        self.type = viewObject.type.rawValue
    }

    init?(data: [String: Any]) {
        guard
            let id = data["message_id"] as? Int,
            let text = data["text"] as? String,
            let type = data["type"] as? String
        else {
            return nil
        }

        self.id = id
        self.text = text
        self.type = type
    }
    
    func data() -> [String: Any] {
        return [
            "message_id" : id,
            "text" : text,
            "type" : type
        ]
    }
}
