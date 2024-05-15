
import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var greenBoxOutlet: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        greenBoxOutlet.layer.cornerRadius = 10.0
        greenBoxOutlet.layer.borderWidth = 2.0
        greenBoxOutlet.layer.borderColor = UIColor.green.cgColor
    }
}

