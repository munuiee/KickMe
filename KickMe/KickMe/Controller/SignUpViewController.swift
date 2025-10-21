
import UIKit
import SnapKit

class SignUpViewController: UIViewController {
    
    // 상단 좌측 제목 "회원가입"
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        return label
    }()
    
    
    // 이름 라벨
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    
    // 이름 입력 필드
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "성함을 입력해주세요."
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 12)
        textField.textColor = .darkGray
        return textField
    }()
    
    
    // 아이디 라벨
    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    
    // 아이디 입력 필드
    private let idTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "등록하실 아이디를 입력해주세요."
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 12)
        textField.textColor = .darkGray
        return textField
    }()
    
    
    // 비밀번호 라벨
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    
    // 비밀번호 입력 필드
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "영어, 숫자 포함 8자 이상 입력해주세요."
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 12)
        textField.textColor = .darkGray
        textField.isSecureTextEntry = true
        textField.textContentType = .none
        return textField
    }()
    
    
    // 회원가입 버튼
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = UIColor(red: 0x55/255, green: 0x74/255, blue: 0xFF/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    
    // 이름, 아이디, 비밀번호 입력 밑줄
    private let nameUnderLine = UIView()
    private let idUnderLine = UIView()
    private let passwordUnderLine = UIView()
    
    
    // 주어진 문자열 뒤에 빨간색 *을 붙여 필수 입력 표시 만드는 함수
    private func requiredLabel(_ base: String, font: UIFont) -> NSAttributedString {
        let normal = NSAttributedString(string: base + " ", attributes: [.font: font])
        let star   = NSAttributedString(string: "*", attributes: [.font: font, .foregroundColor: UIColor.red])
        let result = NSMutableAttributedString()
        result.append(normal)
        result.append(star)
        return result
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let savedID = UserDefaults.standard.string(forKey: "user_id"),
           let savedPW = UserDefaults.standard.string(forKey: "user_pw") {
            idTextField.text = savedID
            passwordTextField.text = savedPW
        }
        
        
        // 밑줄 색상
        [nameUnderLine, idUnderLine, passwordUnderLine].forEach { $0.backgroundColor = .lightGray
        }
        
        
        
        // 필수 입력 라벨에 빨간 * 적용
        let labelFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.attributedText      = requiredLabel("이름", font: labelFont)
        idLabel.attributedText        = requiredLabel("아이디", font: labelFont)
        passwordLabel.attributedText  = requiredLabel("비밀번호", font: labelFont)
        
        
        
        
        // 수동으로 뒤로가기 화살표 버튼 추가
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        navigationController?.navigationBar.tintColor = .black
        
        
        
        // UI 및 버튼 동작 연결
        setupLayout()
        setupActions()
    }
    
    
    
    @objc private func didTapBack() {
        // 회원가입은 모달 네비게이션으로 열렸으므로 그 컨테이너를 닫음
        navigationController?.dismiss(animated: true)
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = ""          // "Back" 글자 없애기
        navigationController?.navigationBar.tintColor = .black  // 화살표 색상
    }
    
    
    
    /* ---------- UIButton 구현 ---------- */
    private func setupActions() {
        // 회원가입 버튼 눌렀을 때 didTapSignUp 실행
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    
    
    
    // 회원가입 버튼 동작
    @objc private func didTapSignUp() {
        
        // 입력값 가져오기
        let name = nameTextField.text ?? ""
        let id = idTextField.text ?? ""
        let pw = passwordTextField.text ?? ""
        
        
        // 하나라도 안 적으면 알림창 띄우기
        if name.isEmpty || id.isEmpty || pw.isEmpty {
            
            let alert = UIAlertController(title: "입력 오류", message: "모든 항목을 입력해주세요!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        
        // 비밀번호 8자 미만일 때 경고 알림 (추가)
        if pw.count < 8 {
            let alert = UIAlertController(title: "비밀번호 오류", message: "비밀번호는 8자 이상 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        
        // UserDefaults에 회원정보 저장
        UserDefaults.standard.set(name, forKey: "user_name")
        UserDefaults.standard.set(id, forKey: "user_id")
        UserDefaults.standard.set(pw, forKey: "user_pw")
        
        
        // 저장된 값 콘솔로 확인
        print("회원가입 데이터 저장 완료: \(name), \(id), \(pw)")
        
        
        // 모두 입력했을 때 성공 알림
        let successAlert = UIAlertController(title: "회원가입 완료", message: "회원가입이 성공적으로 완료되었습니다!", preferredStyle: .alert)
        
        successAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            // Alert가 내려간 다음에 모달 네비게이션을 닫는다 (충돌 방지)
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true)
            }
        }))
        present(successAlert, animated: true)
    }
    
    
    
    
    /* ---------- UI 오토레이아웃 ---------- */
    private func setupLayout() {
        [
            titleLabel,
            nameLabel, nameTextField, nameUnderLine, idLabel, idTextField, idUnderLine, passwordLabel, passwordTextField,passwordUnderLine, signUpButton
        ].forEach { view.addSubview($0) }
        
        
        
        // 맨 위에 "회원가입"
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        
        
        // "이름"
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(30)
        }
        
        
        
        // "성함을 입력해주세요."
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(35)
        }
        
        
        
        nameUnderLine.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(nameTextField)
            $0.height.equalTo(1)
        }
        
        
        
        // "아이디"
        idLabel.snp.makeConstraints {
            $0.top.equalTo(nameUnderLine.snp.bottom).offset(20)
            $0.leading.equalTo(nameLabel)
        }
        
        
        
        // "등록하실 아이디를 입력해주세요."
        idTextField.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(8)
            $0.leading.trailing.height.equalTo(nameTextField)
        }
        
        
        
        idUnderLine.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(idTextField)
            $0.height.equalTo(1)
        }
        
        
        
        // "비밀번호"
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(idUnderLine.snp.bottom).offset(20)
            $0.leading.equalTo(idLabel)
        }
        
        
        
        // "영어, 숫자 포함 8자 이상 입력해주세요."
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(4)
            $0.leading.trailing.height.equalTo(nameTextField)
        }
        
        
        
        passwordUnderLine.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(passwordTextField)
            $0.height.equalTo(1)
        }
        
        
        
        // 회원가입 버튼
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(passwordUnderLine.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(50)
        }
        
    }
}

