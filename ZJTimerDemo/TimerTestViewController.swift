//
//  TimerTestViewController.swift
//  ZJTimerDemo
//
//  Created by Javen on 2019/3/8.
//  Copyright © 2019 Javen. All rights reserved.
//

import UIKit

class TimerTestViewController: UIViewController {
    @IBOutlet weak var labelText: UILabel!
    var count = 0
    var myTimer: ZJTimer!
    override func viewDidLoad() {
        super.viewDidLoad()
        myTimer = ZJTimer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerRun), userInfo: nil, repeats: true)
        //如果希望对Timer做自定义的操作，使用_Timer属性
        RunLoop.current.add(myTimer._timer, forMode: RunLoop.Mode.common)

        myTimer.fire()
    }
    
    @IBAction func actionPause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            myTimer.fireDate = Date.distantFuture
            sender.setTitle("继续", for: .normal)
        }else{
            myTimer.fireDate = Date.distantPast
            sender.setTitle("暂停", for: .normal)
        }
    }
    
    @objc func timerRun() {
        count += 1
        labelText.text = "\(count)"
        print(count)
    }
    
    deinit {
        myTimer.invalidate()
        print("\(self)已销毁")
    }
}
