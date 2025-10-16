
import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    private var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate를 찾을 수 없습니다.")
        }
        return appDelegate.persistentContainer.viewContext
    }
    /* ---------- 킥보드 등록(대여 시작) ---------- */
    func startRental(
        boardNum: String,
        rentalTime: String) {
        let newRental = RentalDatas(context: context)
        let now = Date()
        
        newRental.id = UUID()
        newRental.boardNum = boardNum
        newRental.startTime = now.dateTime
        newRental.rentalTime = rentalTime
        newRental.isReturned = false
        
        // 저장
        do {
            try context.save()
            print("대여 기록 저장 성공.\(newRental.startTime ?? "저장 실패")")
        } catch {
            print("대여 기록 저장 실패 \(error)")
        }
    }
    /* ---------- 킥보드 반납(대여 종료) ---------- */
    func completeRental() {
        let fetchRequest: NSFetchRequest<RentalDatas> = RentalDatas.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isReturned == NO")
        
        do {
            guard let rentalToUpdate = try? context.fetch(fetchRequest).first else {
                print("현재 대여 중인 킥보드가 없습니다")
                return
            }
            
            rentalToUpdate.rentalTime = String()
            rentalToUpdate.isReturned = true
            
            try context.save()
            print("반납 업데이트 성공")
        } catch {
            print("반납 업데이트 실패 \(error)")
        }
    }
    
    /* ---------- 이용 내역 불러오기 ---------- */
    func fetchAllRentHistory() -> [RentalRecord] {
        let fetchRequest: NSFetchRequest<RentalDatas> = RentalDatas.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let historyList = try context.fetch(fetchRequest)
            return historyList.map { rentalDatas in
            RentalRecord(rentalDatas: rentalDatas)
            }
        } catch {
            print("이용 내역 불러오기 실패 \(error)")
            return []
        }
    }
    
    
    /* ---------- 대여 상태 확인 ---------- */
    func isCurrentlyRented() -> Bool {
        let fetchRequest: NSFetchRequest<RentalDatas> = RentalDatas.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isReturned == NO")
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("대여 상태 확인 실패: \(error)")
            return false
        }
    }
}
