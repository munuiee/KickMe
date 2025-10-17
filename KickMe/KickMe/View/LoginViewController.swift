


import UIKit
import SnapKit

class LoginViewController: UIViewController {
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인"
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .left
        return label
    }()
    
    // ID 라벨
    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "ID"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    // ID 입력 필드
    private let idTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "아이디를 입력하세요."
        textField.borderStyle = .none // 밑줄만 넣기 위해 기본 테두리 제거
        textField.font = .systemFont(ofSize: 14)
        textField.textColor = .darkGray
        return textField
    }()
    
    // Password 라벨
    private let pwLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    // Password 입력 필드
    private let pwTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력하세요."
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 14)
        textField.textColor = .darkGray
        textField.isSecureTextEntry = true // 입력 시 비밀번호 안 보이게 설정
        return textField
    }()
    
    // 언더라인 디자인
    private let idUnderLine = UIView()
    private let pwUnderLine = UIView()
    
    // 로그인 버튼
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.backgroundColor = UIColor(red: 0x55/255, green: 0x74/255, blue: 0xFF/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        return button
    }()
    
    // 회원가입 버튼
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0x55/255, green: 0x74/255, blue: 0xFF/255, alpha: 1.0).cgColor
        button.layer.cornerRadius = 6
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 앱 실행 시 저장된 정보가 있는지 콘솔로 확인(디버깅용)
        // 완성 후 지울 예정
        if let savedID = UserDefaults.standard.string(forKey: "user_id"),
              let savedPW = UserDefaults.standard.string(forKey: "user_pw"),
              let savedName = UserDefaults.standard.string(forKey: "user_name") {
               print(" 저장된 회원정보: 이름=\(savedName), ID=\(savedID), PW=\(savedPW)")
           } else {
               print(" UserDefaults에 저장된 정보가 없습니다.")
           }
        
        // 화면 요소(텍스트 필드, 버튼 등) 배치 메서드 실행
        setupLayout()
        setupActions()
        
    }
    /* ---------- UI 오토레이아웃 ---------- */
    private func setupLayout() {
        [titleLabel, idLabel, idTextField, idUnderLine, pwLabel, pwTextField, pwUnderLine, loginButton, signUpButton].forEach { view.addSubview($0) }
        
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        // "ID"
        idLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(60)
            $0.leading.equalTo(titleLabel)
        }
        
        // "아이디를 입력하세요."
        idTextField.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(8)
            $0.leading.equalTo(idLabel)
            $0.trailing.equalToSuperview().offset(30)
            $0.height.equalTo(30)
        }
        
        
        idUnderLine.backgroundColor = .lightGray
        idUnderLine.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(idTextField)
            $0.trailing.equalTo(idTextField).inset(60)
            $0.height.equalTo(1)
            
        }
        
        // "Password"
        pwLabel.snp.makeConstraints {
            $0.top.equalTo(idUnderLine.snp.bottom).offset(25)
            $0.leading.equalTo(idLabel)
        }
        
        // "비밀번호를 입력하세요."
        pwTextField.snp.makeConstraints {
            $0.top.equalTo(pwLabel.snp.bottom).offset(8)
            $0.leading.trailing.height.equalTo(idTextField)
        }
        
        
        pwUnderLine.backgroundColor = .lightGray
        pwUnderLine.snp.makeConstraints {
            $0.top.equalTo(pwTextField.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(pwTextField)
            $0.trailing.equalTo(pwTextField).inset(60)
            $0.height.equalTo(1)
        }
        
        // 로그인 버튼
        loginButton.snp.makeConstraints {
            $0.top.equalTo(pwUnderLine.snp.bottom).offset(30)
            $0.leading.equalTo(pwUnderLine.snp.leading)
            $0.width.equalTo(155)
            $0.height.equalTo(44)
        }
        
        // 회원가입 버튼
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(pwUnderLine.snp.bottom).offset(30)
            $0.trailing.equalTo(loginButton.snp.trailing).offset(185)
            $0.width.equalTo(155)
            $0.height.equalTo(44)
        }
    }
    
    /* ---------- UIButton 구현 ---------- */
    private func setupActions() {
        // 버튼과 함수 연결
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    // 로그인 버튼 클릭 시 실행
    @objc private func didTapLogin() {
        print("로그인 버튼 눌림")
        // ✨ 나중에 로그인 기능 연결( UserDefaulets 검증 예정)
    }
    
    @objc private func didTapSignUp() {
        print("회원가입 버튼 눌림")
        let signUpVC = SignUpViewController()

        // 네비게이션 컨트롤러가 없는 경우 -> 모달로 네비게이션 포함해서 띄우기
        if navigationController == nil {
            let nav = UINavigationController(rootViewController: signUpVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        } else {
            // 네비게이션 컨트롤러가 있는 경우 -> push로 화면 이동
            // Back 버튼의 글자는 숨기고 화살표만 보이도록 설정
            navigationItem.backButtonTitle = ""
            navigationController?.pushViewController(signUpVC, animated: true)
        }
    }

}

