import Foundation
/* ---------- 킥보드 등록시점 날짜와 시간 기록용 ---------- */
extension Date {
    var dateTime: String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        
        return formatter.string(from: self)
    }
}
