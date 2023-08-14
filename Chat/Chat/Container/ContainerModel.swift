import FirebaseFirestore

// MARK: - To ContainerViewController
protocol ContainerModelOutput: AnyObject {
    func didReceiveMessage(in chat: CurrentChat, with text: String)
    func alertError(error: String)
}

// MARK: - ContainerModel
final class ContainerModel {
    private weak var output: ContainerModelOutput?
    
    private var messagesReference: [Int: DocumentReference] = [:]
    
    init(output: ContainerModelOutput?) {
        self.output = output
    }
}

// MARK: - From ContainerViewController
extension ContainerModel: ContainerModelInput {
    func loadAllChats(completion: @escaping (Result<[ChatViewObject], Error>) -> Void) {
        FirebaseManager.shared.loadAllChats { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let chatNetworkObjects):
                chatNetworkObjects.forEach { chatNetworkObject in
                    self?.messagesReference[chatNetworkObject.id] = chatNetworkObject.messagesReference
                }
                
                let chatViewObjects = chatNetworkObjects.sorted { chatNetworkObjectFirst, chatNetworkObjectSecond in
                    chatNetworkObjectFirst.id < chatNetworkObjectSecond.id
                }.compactMap { chatNetworkObject in
                    ChatViewObject(id: chatNetworkObject.id, name: chatNetworkObject.name)
                }
                
                completion(.success(chatViewObjects))
            }
        }
    }
    
    func loadAllChatMessages(for chatID: Int, completion: @escaping (Result<[ChatMessageViewObject], Error>) -> Void) {
        guard let reference = messagesReference[chatID] else {
            fatalError("[DEBUG] Can't find chat id") // completion(.success([]))
        }
        
        FirebaseManager.shared.loadAllChatMessages(reference: reference) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let chatMessageNetworkObjects):
                let chatMessageViewObjects = chatMessageNetworkObjects.sorted { chatMessageNetworkObjectFirst, chatMessageNetworkObjectSecond in
                    chatMessageNetworkObjectFirst.id < chatMessageNetworkObjectSecond.id
                }.compactMap { chatMessageNetworkObject in
                    guard let type = ChatMessageViewObject.MessageType(rawValue: chatMessageNetworkObject.type) else {
                        fatalError("[DEBUG] Can't parse type of message")
                    }
                    
                    return ChatMessageViewObject(id: chatMessageNetworkObject.id, text: chatMessageNetworkObject.text, type: type)
                }
                
                completion(.success(chatMessageViewObjects))
            }
        }
    }
    
    func sendMessage(in chat: CurrentChat, with text: String) {
        NetworkManager.shared.getAnswer(text: text) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.output?.alertError(error: error.localizedDescription)
            case .success(let text):
                self?.output?.didReceiveMessage(in: chat, with: text)
            }
        }
    }
    
    func saveMessage(for chatID: Int, message: ChatMessageViewObject) {
        guard let reference = messagesReference[chatID] else {
            fatalError("[DEBUG] Can't find chat id")
        }
        let chatMessageNetworkObject = ChatMessageNetworkObject(viewObject: message)
        
        FirebaseManager.shared.saveChatMessage(chatMessage: chatMessageNetworkObject, reference: reference) { result in
            switch result {
            case .failure(let error):
                print("[DEBUG] \(error.localizedDescription)")
            case .success(_):
                print("[DEBUG] successfully saved message")
            }
        }
    }
}

