import Foundation
import FirebaseFirestore


enum FirebaseError: Error {
    case noData
    case other(String)
}


protocol FirebaseManagerDescription {
    func loadAllChats(completion: @escaping (Result<[ChatNetworkObject], FirebaseError>) -> Void)
    func loadAllChatMessages(reference: DocumentReference, completion: @escaping (Result<[ChatMessageNetworkObject], FirebaseError>) -> Void)
    func saveChatMessage(chatMessage: ChatMessageNetworkObject, reference: DocumentReference, completion: @escaping (Result<Void, FirebaseError>) -> Void)
}


final class FirebaseManager: FirebaseManagerDescription {
    
    static let shared = FirebaseManager()
    private let database = Firestore.firestore()
    
    private init() {}
    
    func loadAllChats(completion: @escaping (Result<[ChatNetworkObject], FirebaseError>) -> Void) {
        let mainThreadCompletion: ((Result<[ChatNetworkObject], FirebaseError>) -> Void) = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        database.collection("allChats").getDocuments { snapshot, error in
            if let error {
                mainThreadCompletion(.failure(.other(error.localizedDescription)))
                return
            }
            
            guard let documents = snapshot?.documents else {
                mainThreadCompletion(.failure(.noData))
                return
            }
            
            let chats = documents.compactMap { document in
                ChatNetworkObject(data: document.data(), messagesReference: document.reference)
            }
            mainThreadCompletion(.success(chats))
        }
    }
    
    func loadAllChatMessages(reference: DocumentReference, completion: @escaping (Result<[ChatMessageNetworkObject], FirebaseError>) -> Void) {
        let mainThreadCompletion: ((Result<[ChatMessageNetworkObject], FirebaseError>) -> Void) = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        reference.collection("messages").getDocuments { snapshot, error in
            if let error {
                mainThreadCompletion(.failure(.other(error.localizedDescription)))
                return
            }
            
            guard let documents = snapshot?.documents else {
                mainThreadCompletion(.failure(.noData))
                return
            }
            
            let messages = documents.compactMap { document in
                ChatMessageNetworkObject(data: document.data())
            }
            
            mainThreadCompletion(.success(messages))
        }
    }
    
    func saveChatMessage(chatMessage: ChatMessageNetworkObject, reference: DocumentReference, completion: @escaping (Result<Void, FirebaseError>) -> Void) {
        reference.collection("messages").addDocument(data: chatMessage.data()) { error in
            if let error {
                completion(.failure(.other(error.localizedDescription)))
            } else {
                completion(.success(()))
            }
        }
    }
}

