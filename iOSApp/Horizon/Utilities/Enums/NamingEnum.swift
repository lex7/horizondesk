//  Created by Timofey Privalov MobileDesk
import Foundation

enum NamingEnum: String {
    case noTasks
    case noRequests
    case noReview
    case noLogsFound
    
    var name: String {
        switch self {
        case .noTasks:
            return "Список Пуст"
        case .noRequests:
            return "Список Пуст"
        case .noReview:
            return "Запросов на рассмотрение нет."
        case .noLogsFound:
            return "Логи по данному запросу не найдены."
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
            return "Мы пришлем уведомление."
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
