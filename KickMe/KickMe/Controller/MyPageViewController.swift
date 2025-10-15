import UIKit
import SnapKit

class MyPageViewController: UIViewController {
    /* ---------- 테이블뷰 테스트용 임시 데이터 ---------- */
    var usageDatas: [String] = ["2025.10.01", "2025.10.03", "2025.10.10"]
    var kickBoardDatas: [String] = ["01번", "02번", "03번"]
    
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
            $0.top.equalToSuperview().inset(700)
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
    }
    
    /* ---------- "회원탈퇴" 버튼 클릭 시 실행(임시) ---------- */
    @objc
    private func didTappedSignOut() {
        print("회원탈퇴 클릭 됨")
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
            return usageDatas.count
        } else if tableView == kickBoardTableView {
            return kickBoardDatas.count
        }
        return 0
    }
    /* ---------- 각 테이블 뷰 셀 데이터 연결 ---------- */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == historyTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.id, for: indexPath) as?    HistoryTableViewCell else {
                return UITableViewCell()
            }
            let usageData = usageDatas[indexPath.row]
            cell.configureCell(with: usageData)
            return cell
        } else if tableView == kickBoardTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: KickBoardTableViewCell.id, for: indexPath) as?    KickBoardTableViewCell else {
                return UITableViewCell()
            }
            let kickBoardData = kickBoardDatas[indexPath.row]
            cell.configureCell(with: kickBoardData)
            return cell
        }
        return UITableViewCell()
    }
    
}

