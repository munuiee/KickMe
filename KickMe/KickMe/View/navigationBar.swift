// 하단 네비게이션바

import Foundation
import UIKit
import SnapKit

class navigationBar: UIView {
    let bar = UIView()
    let mapButton = UIButton()
    let mainButton = UIButton()
    let myPageButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func configureUI() {
        addSubview(bar)
        [mapButton, mainButton, myPageButton]
            .forEach { bar.addSubview($0) }
        
        bar.backgroundColor = .white
        bar.layer.cornerRadius = 30
        bar.layer.masksToBounds = true
        bar.layer.cornerCurve = .continuous
        bar.clipsToBounds = false   // 대여 버튼 bar 밖으로
        bar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mapButton.setImage(UIImage(
            systemName: "map",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)),
            for: .normal)
        mapButton.tintColor = UIColor(named: "defaultColor")
        mapButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
        }
        
        mainButton.layer.cornerRadius = 45
        mainButton.backgroundColor = UIColor(named: "defaultColor")
        mainButton.setTitle("대여", for: .normal)
        mainButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        mainButton.snp.makeConstraints {
            $0.width.height.equalTo(90)
            $0.centerX.centerY.equalToSuperview()
            
        }
        
        myPageButton.setImage(UIImage(
            systemName: "person",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)),
            for: .normal)
        myPageButton.tintColor = .black
        myPageButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
        }
        

    }
}
