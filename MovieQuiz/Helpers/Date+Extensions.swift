import Foundation

extension Date {
    var dateTimeString: String {
        DateFormatter.defaultDateTime.string(from: self)
    }
}

private extension DateFormatter {
    static let defaultDateTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY HH:mm" // Дата с часами и минутами
        return dateFormatter
    }()
}
