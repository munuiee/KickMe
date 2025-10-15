// 하단 네비게이션바

import Foundation
import UIKit
import SnapKit

class CustomTabBar: UITabBar {
    
    let mapButton = UIButton() // 지도
    let mainButton = UIButton() // 대여
    let myPageButton = UIButton() // 마이페이지
    let customView = UIView()
    let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupButtons()
        setupStack()
        clipsToBounds = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /* ---------- 버튼 레이아웃 ---------- */
    private func setupButtons() {
        addSubview(mainButton)
        mainButton.layer.cornerRadius = 40
        mainButton.layer.masksToBounds = true
        mainButton.clipsToBounds = false
        mainButton.backgroundColor = UIColor(named: "MainColor")
        mainButton.titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
        mainButton.setTitle("대여", for: .normal)
        mainButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
            $0.centerY.equalTo(customView)
        }
        
        
        [mapButton, myPageButton]
            .forEach { customView.addSubview($0) }
        
        mapButton.setImage(UIImage(
            systemName: "map",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)),
                           for: .normal)
        mapButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.greaterThanOrEqualTo(44)
        }
        
        
        myPageButton.setImage(UIImage(
            systemName: "person",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)),
                              for: .normal)
        myPageButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.greaterThanOrEqualTo(44)
        }
    }
    
    
    // 버튼 클릭시 색상 변경
    func updateColors(selectedIndex: Int) {
        let on = UIColor(named: "MainColor") ?? .systemBlue
        let off = UIColor.label.withAlphaComponent(0.5)
        
        mapButton.tintColor = (selectedIndex == 0) ? on : off
        myPageButton.tintColor = (selectedIndex == 2) ? on : off
        
        // 등록페이지, 마이페이지 외곽선 추가
        if selectedIndex == 1 || selectedIndex == 2 {
            customView.layer.borderWidth = 1.5
            customView.layer.borderColor = (UIColor(named: "tabBarBorder") ?? .systemGray6).cgColor
        } else {
            customView.layer.borderWidth = 0
        }
    }
    
    
    private func setupView() {
        addSubview(customView)
        customView.backgroundColor = .white
        customView.layer.cornerRadius = 25
        customView.layer.masksToBounds = true
        customView.clipsToBounds = true
        customView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(10)
            $0.width.equalTo(250)
            $0.height.equalTo(50)
            
        }
    }
    
    private func setupStack() {
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.isUserInteractionEnabled = false
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
            
        }
    }
    
    
    // 터치 이벤트 받을 뷰를 찾는 hitTest
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0.01, isUserInteractionEnabled else { return  nil }
        
        // map
        let mapPage = mapButton.convert(point, from: self)
        if mapButton.bounds.contains(mapPage) { return mapButton }
        
        // myPage
        let myPage = myPageButton.convert(point, from: self)
        if myPageButton.bounds.contains(myPage) { return myPageButton }
        
        // registerPage
        let registerPage = mainButton.convert(point, from: self)
        if mainButton.bounds.contains(registerPage) { return mainButton }
        
        return super.hitTest(point, with: event)
    }
}
