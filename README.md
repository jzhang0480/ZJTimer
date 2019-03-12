最近在同事的代码里看到了一些定时器使用上的问题，发现其实Timer虽然用起来看似很简单，但是稍不注意就会出现问题，造成一些偶发性的崩溃。
下面这个是常见的写法，看似没问题，其实`deinit `方法是不会被调用的，Timer自然不会被销毁。
```swift
class TimerTestViewController: UIViewController {
    @IBOutlet weak var labelText: UILabel!
    var myTimer: Timer!
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerRun), userInfo: nil, repeats: true)
        myTimer.fire()
        // Do any additional setup after loading the view.
    }
    @objc func timerRun() {
        count += 1
        labelText.text = "\(count)"
        print(count)
    }
    deinit {
        myTimer.invalidate()
        myTimer = nil
        print("\(self)已销毁")
    }
}
```

>  A timer maintains a strong reference to its target. This means that as long as a timer remains valid, its target will not be deallocated. As a corollary, this means that it does not make sense for a timer’s target to try to invalidate the timer in its dealloc method—the dealloc method will not be invoked as long as the timer is valid. – [guyarad](https://stackoverflow.com/users/916568/guyarad "826 reputation")

简单解释就是timer保持了对target的强引用，只要timer还有效，那么当前的target（也就是当前的vc）不会被释放，那么vc的dealloc（deinit）方法永远不会被调用，写在里面的停用计时器的方法自然是无效的。也就是说，只有Timer的`invalidate `之后，页面的销毁方法才会调用。

要打破这个过程，可以在`viewWillDisappear`或者`viewDidDisappear`方法里面写`timer.invalidate ()`。这样页面消失之后timer停了，`deinit`方法自然就调用了。

但是这个方法不能解决全部问题，会导致App切换到后台之后计时器就不走了。

进一步的方法就是不把当前vc当作target传入，而是创建一个专门的对象（假设为A）作为target，这样不会影响vc的生命周期，保证`deinit`方法正常调用。但是这种方法需要在A中写定时器调用的方法，会让调用过程更加复杂。

最后我写了个ZJTimer类。直接把最上面代码里的Timer替换成ZJTimer，退出页面时`deinit`方法就会正常调用了，Timer也被销毁。
 ```swift
import UIKit

class ZJTimer: NSObject {
    private(set) var _timer: Timer!
    fileprivate weak var _aTarget: AnyObject!
    fileprivate var _aSelector: Selector!
    var fireDate: Date {
        get{
            return _timer.fireDate
        }
        set{
            _timer.fireDate = newValue
        }
    }
    
    class func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: AnyObject, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> ZJTimer {
        let timer = ZJTimer()
        
        timer._aTarget = aTarget
        timer._aSelector = aSelector
        timer._timer = Timer.scheduledTimer(timeInterval: ti, target: timer, selector: #selector(ZJTimer.zj_timerRun), userInfo: userInfo, repeats: yesOrNo)
        return timer
    }
    
    func fire() {
        _timer.fire()
    }
    
    func invalidate() {
        _timer.invalidate()
    }
    
    @objc func zj_timerRun() {
        //如果崩在这里，说明你没有在使用Timer的VC里面的deinit方法里调用invalidate()方法
        _ = _aTarget.perform(_aSelector)
    }
    
    deinit {
        print("计时器已销毁")
    }
}
```