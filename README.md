# Kick Me-iOS


## 프로젝트 소개
Kick Me는 공유 킥보드 대여 어플을 재현했습니다.
<img src="https://github.com/user-attachments/assets/1924c6fc-1e89-40e4-8e51-4834c1c02f85" >

### 와이어프레임
<img src="https://github.com/user-attachments/assets/17dc7112-b28b-49e2-9b01-df7ff02a4725" width="50%">

### File structure
```swift
KickMe
├─ Secrets.sample
├─ Secrets.plist
│
├─ 📁 Controller
│     ├─ LoginViewController
│     ├─ MainViewController
│     ├─ MapViewController
│     ├─ MyPageViewController
│     ├─ RegisterViewController
│     ├─ SignUpViewController
│     └─ TabBarController
│
├─ 📁 Supporting Files
│     ├─ CoreDataManager
│     ├─ CoreDataModel
│     ├─ RentalDatas+CoreDataClass
│     └─ RentalDatas+CoreDataProperties
│
├─ 📁 Models
│     ├─ DataExtension
│     ├─ KakaoLocalAPI
│     ├─ mapAPI
│     └─ RentalRecord
│
├─ 📁 Resource
│     ├─ LaunchScreen
│     └─ Assets
│
├─ 📁 Supporting Files
│     ├─ AppDelegate
│     ├─ SceneDelegate
│     └─ Info.plist
│
└─ 📁 View
      ├─ CustomTabBar
      ├─ HistoryTableViewCell
      └─ kickBoardTableViewCell

     
```

## Stacks
### Environment
<img src="https://img.shields.io/badge/Xcode-1575F9.svg?style=for-the-badge&logo=Xcode&logoColor=white"> <img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white"> <img src="https://img.shields.io/badge/git-F05032?style=for-the-badge&logo=git&logoColor=white">

### OS
<img src="https://img.shields.io/badge/iOS-000000.svg?style=for-the-badge&logo=apple&logoColor=white">

### Libraries
[![SnapKit 5.7.1](https://img.shields.io/badge/SnapKit-5.7.1-0A99E2?style=for-the-badge&logo=data:image/svg+xml;base64,여기에인코딩된문자열&logoColor=white)](https://github.com/SnapKit/SnapKit)



## Team APPuccino

| 김리하   | 변지혜       | 박혜연      |
|-------------|--------------|-------------|
| <div align="center">[@RiHA039](https://github.com/RiHA039)</div>  | <div align="center">[@munuiee](https://github.com/munuiee)</div> | <div align="center">[@104hyeon](https://github.com/104hyeon)</div> |

## 프로젝트 기능

### 로그인 페이지
> 회원가입 후 로그인이 필요합니다.  
> 로그인 후 앱을 재실행하면 로그인 정보가 자동으로 입력됩니다.

### 지도 페이지
> 지도는 현 위치를 기반으로 합니다.  
> 주소 검색을 통해 원하는 곳으로 이동이 가능합니다.  
> 해당 위치 반경 500m 내에 대여 가능한 킥보드의 위치가 지도에 표시됩니다.

### 킥보드 대여
> 지도 위 킥보드 마커를 누른 후 대여 기간 선택하면 킥보드 대여가 가능합니다.  
> 

### 마이페이지
> 대여 여부와 이용 내역, 등록한 킥보드 내역은 마이페이지에서 확인 가능합니다.  
> 로그아웃과 회원 탈퇴 기능이 있으며 회원 탈퇴 시 모든 데이터가 삭제됩니다.

## 이슈 내용
- 반납 시 이용 내역과 등록한 킥보드가 사라진 문제 해결되었습니다.
- 로그아웃 후 회원가입 시 뒤로가기 버튼이 클릭되지 않은 문제 해결되었습니다.  
[🚨트러블 슈팅 보러가기](https://github.com/munuiee/KickMe/wiki/%ED%8A%B8%EB%9F%AC%EB%B8%94%EC%8A%88%ED%8C%85)

## 향후 개선 사항
- 이용 및 과금 기능
- 이용 내역과 대여한 킥보드 리스트 수정/삭제 기능
- 킥보드 상태 표시 기능
