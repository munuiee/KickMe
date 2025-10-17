// 하단 네비게이션바 컨트롤러

import Foundation
import UIKit
import SnapKit
import KakaoMapsSDK

class TabBarController: UITabBarController {
    
    let bar = CustomTabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVC()
        
        // UITabBarController -> CustomTabBar로 갈아끼움
        setValue(bar, forKey: "tabBar")
        
        bar.updateColors(selectedIndex: selectedIndex)
        
        let app = UITabBarAppearance()
        app.configureWithTransparentBackground()
        app.shadowColor = .clear
        tabBar.standardAppearance = app
        tabBar.scrollEdgeAppearance = app
        tabBar.isTranslucent = true
    }
    
    
    
    /* ----------- 버튼 클릭시 페이지 이동 함수 ----------- */
    // 페이지 확인용 임시 코드
    @objc private func openMapVC() {
        selectedIndex = 0
        (viewControllers?[0] as? UINavigationController)?
            .popToRootViewController(animated: false)
        bar.updateColors(selectedIndex: selectedIndex)
    }
    
    // "대여/반납" 버튼
    @objc private func openRegisterVC() {
        let isRented = CoreDataManager.shared.isCurrentlyRented()
        
        if isRented {
            CoreDataManager.shared.completeRental()
            
            self.changeMainButton(to: "대여")
            selectedIndex = 0
            (viewControllers?[0] as? UINavigationController)?
                .popToRootViewController(animated: false)
        } else {
            selectedIndex = 1
            (viewControllers?[1] as? UINavigationController)?
                .popToRootViewController(animated: false)
        }
        bar.updateColors(selectedIndex: selectedIndex)
    }
    
    // 페이지 확인용 임시 코드
    @objc private func openMyPageVC() {
        selectedIndex = 2
        (viewControllers?[2] as? UINavigationController)?
            .popToRootViewController(animated: false)
        bar.updateColors(selectedIndex: selectedIndex)
    }
    
    
    
    /* ---------- 커스텀 버튼에 탭 전환 액션 연결 ---------- */
    // 각 페이지 뷰컨 이곳에 연결해주세요 지금 연결된 뷰컨은 전부 임시로 만들어둔 거예요
    private func addVC() {
        let mapVC = UINavigationController(rootViewController: MapViewController())
        mapVC.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 0)
        
        let registerVC = UINavigationController(rootViewController: RegisterViewController())
        registerVC.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 1)
        
        let myPageVC = UINavigationController(rootViewController: MyPageViewController())
        myPageVC.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 2)
        
        viewControllers = [mapVC, registerVC, myPageVC]
        
        bar.mapButton.addTarget(self, action: #selector(openMapVC), for: .touchUpInside)
        bar.mainButton.addTarget(self, action: #selector(openRegisterVC), for: .touchUpInside)
        bar.myPageButton.addTarget(self, action: #selector(openMyPageVC), for: .touchUpInside)
        
        
    }
    
    
}
/* ---------- "등록하기" 버튼에서 호출할 함수 ---------- */
extension TabBarController {
    func changeMainButton(to title: String) {
        if let customTabBar = self.tabBar as? CustomTabBar {
            customTabBar.setMainButtonTitle(title: title)
        }
    }
}

