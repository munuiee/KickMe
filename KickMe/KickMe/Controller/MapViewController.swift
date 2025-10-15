import Foundation
import UIKit
import SnapKit
import KakaoMapsSDK

class MapViewController: UIViewController, MapControllerDelegate {
    
    var mapView: KMViewContainer!
    var controller: KMController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        mapView = KMViewContainer(frame: view.bounds)
        view.addSubview(mapView)
        
        controller = KMController(viewContainer: mapView)
        controller?.delegate = self
        controller?.prepareEngine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controller?.activateEngine()
    }
    
    // 화면 떠날 땐 일시정지
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        controller?.pauseEngine()
    }
    
    // 리소스 해제
    deinit {
        controller?.pauseEngine()
        controller?.resetEngine()
    }
    
    func addViews() {
        // 위도, 경도
        let defaultPosition = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let mapviewInfo = MapviewInfo(
            viewName: "mapView",
            viewInfoName: "map",
            defaultPosition: defaultPosition,
            defaultLevel: 17
        )
        controller?.addView(mapviewInfo)
    }
    
    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("OK") //추가 성공. 성공시 추가적으로 수행할 작업을 진행한다.
    }

    //addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }
    
    /* ---------- 사이즈(레이아웃) 반영 ---------- */
    func containerDidResized(_ size: CGSize) {
        guard let mapView = controller?.getView("mapView") as? KakaoMap else { return }
        mapView.viewRect = CGRect(origin: .zero, size: size)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
        if let kakaoMap = controller?.getView("mapView") as? KakaoMap {
            kakaoMap.viewRect = mapView.bounds
        }
    }
    
}


