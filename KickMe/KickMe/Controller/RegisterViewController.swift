
import Foundation
import UIKit


class RegisterViewController: UIViewController {
    private let kickNumber: String?
    var onRegistered: (() -> Void)?
    // 픽커뷰에 들어갈 시간 배열
    var hour: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    
    init(kickNumber: String? = nil) {
        self.kickNumber = kickNumber ?? ""
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private var kickBoardLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "킥보드 번호"
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    private let kickBoardTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "킥보드 모델번호를 입력하세요"
        return textField
    }()
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "대여 기간"
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    private let timeTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "대여 기간을 선택하세요"
        return textField
    }()
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "MainColor")
        button.setTitle("대여하기", for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTappedRegister), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
        createPickerView()
        
        if let kickNumber {
            kickBoardTextField.text = kickNumber
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    /* ---------- UI 구성 ---------- */
    func configureUI() {
        view.backgroundColor = .white
        [
            kickBoardLabel,
            kickBoardTextField,
            timeLabel,
            timeTextField,
            registerButton,
        ].forEach { view.addSubview($0) }
    }
    /* ---------- UI 오토레이아웃 ---------- */
    func setConstraints() {
        
        kickBoardLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(170)
            $0.leading.equalToSuperview().inset(24)
        }
        kickBoardTextField.snp.makeConstraints {
            $0.top.equalTo(kickBoardLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(kickBoardTextField.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(24)
        }
        timeTextField.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        registerButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(35)
            $0.top.equalTo(timeTextField.snp.bottom).offset(15)
        }
    }
    
    /* ---------- 픽커뷰 생성 ---------- */
    private func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 텍스트필드에 픽커뷰 연결
        timeTextField.inputView = pickerView
        
        // 툴바 설정
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        // 툴바에 "완료"버튼 추가
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(donePicker))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        // 텍스트필드에 툴바 연결
        timeTextField.inputAccessoryView = toolBar

    }
    /* ---------- 픽커뷰 툴바 "완료"버튼 클릭 시 실행 ---------- */
    @objc
    private func donePicker() {
        if timeTextField.text == "0시간" {
            return
        } else {
            timeTextField.resignFirstResponder()
        }
    }
    
    /* ---------- "등록하기" 버튼 클릭 시 실행 ---------- */
    @objc
    private func didTappedRegister() {
        guard let boardNum = kickBoardTextField.text, !boardNum.isEmpty else { return }
        guard let timeText = timeTextField.text, !timeText.isEmpty else { return }
        
        CoreDataManager.shared.startRental(
            boardNum: boardNum,
            rentalTime: timeText)
        
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.changeMainButton(to: "반납")
        }
        
        // 킥보드 번호 데이터 전달
        if let tabBarController = self.tabBarController,
           let viewControllers = tabBarController.viewControllers,
           viewControllers.count > 2,
           
           let myPageNav = viewControllers[2] as? UINavigationController,
           let myPageVC = myPageNav.viewControllers.first(where: { $0 is MyPageViewController }) as? MyPageViewController {
            myPageVC.updateBordNum()
           }

        // 버튼 누르면 텍스트필드 비워짐
        kickBoardTextField.text = ""
        timeTextField.text = ""
        self.tabBarController?.selectedIndex = 0
        
        onRegistered?()
    }
}

/* ---------- 픽커뷰 관련 ---------- */
extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        hour.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return "\(hour[row])시간"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        return timeTextField.text = "\(hour[row])시간"
        
    }
    
}
