//
//  KillViewController.swift
//  ZJTimerDemo
//
//  Created by Javen on 2019/3/18.
//  Copyright © 2019 Javen. All rights reserved.
//

import UIKit

class KillViewController: UIViewController {
    @IBOutlet weak var labelText: UILabel!
    var killTimer:ZJKillTimer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //seconds根据实际计算（活动结束时间减去当前时间得出的秒数）
        killTimer = ZJKillTimer(seconds: 43200, callBack: {[weak self] (text) in
            self?.labelText.text = text
        })
        
    }
    
}
