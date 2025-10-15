
import UIKit
import SnapKit

class HistoryTableViewCell: UITableViewCell {
    // 셀 재사용 id 생성
    static let id = "HistoryTableViewCell"

    private let historyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* ---------- UI 구성 ---------- */
    private func configureUI() {
        [
            historyLabel
        ].forEach { contentView.addSubview($0) }
    }
    
    /* ---------- UI 오토레이아웃 ---------- */
    private func setConstraints() {
        historyLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    /* ---------- 셀 데여터 연결 ---------- */
    func configureCell(with data: String) {
        historyLabel.text = data
    }
    
}
