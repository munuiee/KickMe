
import Foundation

struct RentalRecord {
    let id: UUID
    let boardNum: String
    let startTime: String
    let rentalTime: String
    let isReturned: Bool
   
    init(rentalDatas: RentalDatas) {
        self.id = rentalDatas.id ?? UUID()
        self.boardNum = rentalDatas.boardNum ?? "00번"
        self.startTime = rentalDatas.startTime ?? ""
        self.rentalTime = rentalDatas.rentalTime ?? "0시간"
        self.isReturned = rentalDatas.isReturned
    }
    
}
