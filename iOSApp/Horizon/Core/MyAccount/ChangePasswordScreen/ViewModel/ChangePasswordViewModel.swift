//  Created by Timofey Privalov MobileDesk
import Foundation
import Combine

final class ChangePasswordViewModel: ObservableObject {
    
    // MARK: - Private properties
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Private properties
    private let networkManager = NetworkManager.standard
    
    // MARK: - Published properties
    @Published private(set) var passUpdateIsLoading: Bool = false
    @Published var showSuccesPassChanged: Bool = false
    
    func changePass(_ pass: String) {
        
    }
}
