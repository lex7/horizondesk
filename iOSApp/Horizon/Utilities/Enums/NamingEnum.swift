//  Created by Timofey Privalov MobileDesk
import Foundation

enum NamingEnum: String {
    case noTransactions
    case noDebts
    
    var name: String {
        switch self {
        case .noTransactions:
            return "Список Пуст"
        case .noDebts:
            return "Список Пуст"
        }
    }
}

enum NamingTextEnum: String {
    case emptyScreenTransaction
    case emptyScreenDebtsDone
    case emptyScreenDebtsNeedAction
    case emptyScreenDebts
    var name: String {
        switch self {
        case .emptyScreenTransaction:
            return "Новых заданий нет."
        case .emptyScreenDebtsDone:
            return "Исполненных заявок нет"
        case .emptyScreenDebtsNeedAction:
            return "Отклоненных заявок нет."
        case .emptyScreenDebts:
            return "В работе заявок нет."
        }
    }
}

enum NamingDescription: String {

    case noteChange
    
    var txt: String {
        switch self {
        case .noteChange:
            return "Информация автоматически отображается из вашего личного кабинета. Для изменения обратитесь в отдел кадров."
        }
    }
}
