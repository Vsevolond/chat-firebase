import FirebaseFirestore


struct ChatNetworkObject {
    let id: Int
    let name: String
    let messagesReference: DocumentReference
    
    init?(data: [String: Any], messagesReference: DocumentReference) {
        guard
            let id = data["chat_id"] as? Int,
            let name = data["name"] as? String
        else {
            return nil
        }

        self.id = id
        self.name = name
        self.messagesReference = messagesReference
    }
    
    func data() -> [String: Any] {
        return [
            "chat_id" : id,
            "name" : name
        ]
    }
}
