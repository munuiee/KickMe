import UIKit

class MapViewController: UIViewController {
    private let customBar = navigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        configureBarUI()
    }
    
    func configureBarUI() {
        view.addSubview(customBar)
        customBar.snp.makeConstraints {
            $0.width.equalTo(250)
            $0.height.equalTo(60)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20) // 안전 영역 기준으로 하단 고정
        }
    }


}

