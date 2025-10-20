
import UIKit
import SnapKit
import KakaoMapsSDK

class MyPageViewController: UIViewController {
    // CoreData에서 가져온 이용 내역
    private var rentalHistory: [RentalRecord] = []
    // 킥보드 번호
    var kickBoardDatas: [String] = []
    
    /* ---------- UI 요소 ---------- */
    private let myPageLabel: UILabel = {
        let label = UILabel()
        label.text = "마이 페이지"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 25)
        return label
    }()
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "User Name"    // 임시
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    private let useOrNotLabel: UILabel = {
       let label = UILabel()
        label.text = "대여 중"
        label.textColor = UIColor(named: "MainColor")
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    private let usageHistoryLabel: UILabel = {
        let label = UILabel()
        label.text = "이용 내역"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    // 이용 내역 테이블뷰
    private lazy var historyTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.id)
        return tableView
    }()
    
    private let kickBoardLabel: UILabel = {
        let label = UILabel()
        label.text = "내가 등록한 킥보드"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    // 등록한 킥보드 테이블뷰
    private lazy var kickBoardTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(KickBoardTableViewCell.self, forCellReuseIdentifier: KickBoardTableViewCell.id)
        return tableView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "MainColor")?.cgColor
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(UIColor(named: "MainColor"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(didTappedLogout), for: .touchUpInside)
       return button
    }()
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("회원 탈퇴", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(didTappedSignOut), for: .touchUpInside)
       return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()

    }
    /* ---------- CoreData 최신 데이터 불러오기 ---------- */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHistoryData()
        historyTableView.reloadData()
        kickBoardTableView.reloadData()
        updateUseOrNot()
        loadUserData()

    }
    
    /* ---------- UI 구성 ---------- */
    func configureUI() {
        view.backgroundColor = .white
        [
            myPageLabel,
            userNameLabel,
            useOrNotLabel,
            usageHistoryLabel,
            historyTableView,
            kickBoardLabel,
            kickBoardTableView,
            logoutButton,
            signOutButton
        ].forEach { view.addSubview($0) }
        
    }
    
    /* ---------- UI 오토레이아웃 ---------- */
    func setConstraints() {
        myPageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(70)
            $0.leading.equalToSuperview().inset(30)
        }
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(myPageLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(35)
        }
        useOrNotLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(userNameLabel.snp.bottom).offset(8)
            $0.height.equalTo(80)
        }
        usageHistoryLabel.snp.makeConstraints {
            $0.top.equalTo(useOrNotLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(35)
        }
        historyTableView.snp.makeConstraints {
            $0.top.equalTo(usageHistoryLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(35)
            $0.height.equalTo(150)
        }
        kickBoardLabel.snp.makeConstraints {
            $0.top.equalTo(historyTableView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(35)
        }
        kickBoardTableView.snp.makeConstraints {
            $0.top.equalTo(kickBoardLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(35)
            $0.height.equalTo(150)
        }
        logoutButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(35)
            $0.height.equalTo(35)
            $0.top.equalToSuperview().inset(660)
        }
        signOutButton.snp.makeConstraints {
            $0.top.equalTo(logoutButton.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(35)
        }
    }
    
    /* ---------- "로그아웃" 버튼 클릭 시 실행(임시) ---------- */
    @objc
    private func didTappedLogout() {
        print("로그아웃 클릭 됨")
        logOutAlrert()

    }
    
    /* ---------- "회원탈퇴" 버튼 클릭 시 실행(임시) ---------- */
    @objc
    private func didTappedSignOut() {
        print("회원탈퇴 클릭 됨")
        signOutAlrert()
    }
}
/* ---------- Core 데이터 관련 ---------- */
extension MyPageViewController {
    // 데이터 로드
    private func loadHistoryData() {
        rentalHistory = CoreDataManager.shared.fetchAllRentHistory()
        kickBoardDatas = rentalHistory.map { $0.boardNum }

    }
    // 대여 상태 레이블 업데이트
    private func updateUseOrNot() {
        let isRented = CoreDataManager.shared.isCurrentlyRented()
        useOrNotLabel.text = isRented ? "대여 중" : "대여 가능"
        useOrNotLabel.textColor = isRented ? UIColor(named: "MainColor") : .gray
    }
    
    // 데이터 삭제
    private func deleteAllData() {
        CoreDataManager.shared.deleteAll()
        
        UserDefaults.standard.removeObject(forKey: "user_name")
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "user_pw")
        
        print("모든 데이터 삭제 성공")
    }
}

extension MyPageViewController {
    /* ---------- 킥보드 테이블뷰 업데이트 ---------- */
    func loadUserData() {
        if let userName = UserDefaults.standard.string(forKey: "user_name") {
            userNameLabel.text = "\(userName)님"
        } else {
            userNameLabel.text = "Guest님"
        }
    }
    
    
    /* ---------- 킥보드 테이블뷰 업데이트 ---------- */
    func updateBordNum() {
        loadHistoryData()
        kickBoardTableView.reloadData()
    }
}

/* ---------- 이용내역/등록한 킥보드 테이블 뷰 관련 ---------- */
extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    // 셀 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    /* ---------- 각 테이블 뷰의 행 개수 ---------- */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == historyTableView {
            return rentalHistory.count
        } else if tableView == kickBoardTableView {
            return kickBoardDatas.count
        }
        return 0
    }
    /* ---------- 각 테이블 뷰 셀 데이터 연결 ---------- */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 이용 내역 테이블뷰 데이터
        let record = rentalHistory[indexPath.row]
        
        if tableView == historyTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.id, for: indexPath) as?    HistoryTableViewCell else {
                return UITableViewCell()
            }
            // 대여 중 / 반납 완료 시 이용 내역 분기
            
            let duration = record.rentalTime
            
            let usageText = record.isReturned ? "이용 종료" : "이용 중"
            
            let usageData = "\(record.startTime) / \(duration) / \(usageText)"
            
            cell.configureCell(with: usageData)
            return cell
            
        // 킥보드 번호 테이블뷰 데이터
        } else if tableView == kickBoardTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: KickBoardTableViewCell.id, for: indexPath) as?    KickBoardTableViewCell else {
                return UITableViewCell()
            }
            
            let boardData = kickBoardDatas[indexPath.row]
            cell.configureCell(with: boardData)
            return cell
        }
               
        return UITableViewCell()
    }
}

/* ---------- 알럿기능 추가 ---------- */
extension MyPageViewController {
    func makeAlert(title: String,
                   message: String,
                   cancleAction: ((UIAlertAction) -> Void)? = nil,
                   checkAction: ((UIAlertAction) -> Void)? = nil,
                   completion: (() -> Void)? = nil) {
        let alretVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "취소", style: .default, handler: cancleAction)
        alretVC.addAction(cancleAction)
        let checkAction = UIAlertAction(title: "확인", style: .default, handler: checkAction)
        alretVC.addAction(checkAction)
        
        self.present(alretVC, animated: true)
    }
    /* ---------- 로그아웃 알럿 ---------- */
    func logOutAlrert() {
        self.makeAlert(title: "로그아웃", message: "로그아웃 하시겠습니까?", cancleAction: { _ in
            }, checkAction: { _ in
            // "확인" 클릭 시 로그인 화면으로 이동
            let loginVC = LoginViewController()
            let rootVC = UINavigationController(rootViewController: loginVC)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            window.rootViewController = rootVC
        })
    }
    /* ---------- 회원탈퇴 알럿 ---------- */
    func signOutAlrert() {
        self.makeAlert(title: "회원 탈퇴", message: "모든 기록이 삭제됩니다. 탈퇴 하시겠습니까?", cancleAction: { _ in
            }, checkAction: { [weak self]_ in
                guard let self = self else { return }
                           
                self.deleteAllData()
                
            // "확인" 클릭 시 로그인 화면으로 이동
            let loginVC = LoginViewController()
            let rootVC = UINavigationController(rootViewController: loginVC)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            window.rootViewController = rootVC
        })
    }
}

