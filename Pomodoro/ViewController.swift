//
//  ViewController.swift
//  Pomodoro
//
//  Created by changhun kim on 2022/03/19.
//

import UIKit
import AudioToolbox

enum TimerStatus {
  case start
  case pause
  case end
}

class ViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var progreesView: UIProgressView!
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  
  var duration = 60 // timer 의 시간을 60s 초기화
  var timerStatus: TimerStatus = .end //초기값 end
  var timer: DispatchSourceTimer?
  var currentSeconds = 0 // 현재 카운트다운 되고 있는 시간을 초 로 저장
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureStartButton()
  }
  
  @IBAction func tapCancelButton(_ sender: UIButton) {
    switch self.timerStatus {
    case .start, .pause:
      self.stopTimer()
      
    default:
      break
    }
  }
  
  @IBAction func tapStartButton(_ sender: UIButton) {
    self.duration = Int(self.datePicker.countDownDuration)
    switch self.timerStatus {
    case .end: // * end 상태 -> start 상태
      self.currentSeconds = self.duration
      self.timerStatus = .start
      UIView.animate(withDuration: 0.5, animations: {
        self.timerLabel.alpha = 1
        self.progreesView.alpha = 1
        self.datePicker.alpha = 0
      })
      
      
      self.startButton.isSelected = true // 버튼 title 이 일시정지 변경
      self.cancelButton.isEnabled = true // cnacel 활성화
      self.startTimer()

      
    case .start: // * start 상태 -> pause 상태
      self.timerStatus = .pause
      self.startButton.isSelected = false
      self.timer?.suspend()
      
    case .pause: // * pause 상태 -> start 상태
      self.timerStatus = .start
      self.startButton.isSelected = true // 버튼 title 이 일시정지 변경
      self.timer?.resume()
      
    default:
      break
    }
  }
  
  func setTimerInfoViewVisble(isHidden: Bool) {
    self.timerLabel.isHidden = isHidden
    self.progreesView.isHidden = isHidden
  }
  
  func configureStartButton() {
    self.startButton.setTitle("시작", for: .normal)
    self.startButton.setTitle("일시정지", for: .selected)
  }
  
  func startTimer() {
    if self.timer == nil {
      //타이머 설정
      self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main) // 어떤 thread 에서 반복할껀지
      self.timer?.schedule(deadline: .now(), repeating: 1) // 어떤 주기로 timer 가 실행 하는지 1초마다 반복
      self.timer?.setEventHandler(handler: { [weak self] in  // 1초 마다 클로저 실행
        guard let self = self else { return }
        self.currentSeconds -= 1
        let hour = self.currentSeconds / 3600
        let minutes = (self.currentSeconds % 3600) / 60
        let seconds = (self.currentSeconds % 3600) % 60
        self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
        self.progreesView.progress = Float(self.currentSeconds) / Float(self.duration)
        
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
          self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
          self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
        })
        
        
        if self.currentSeconds <= 0 {
          // timer 종료
          self.stopTimer()
          AudioServicesPlaySystemSound(1005) // iphonedev.wiki
        }
      })
      self.timer?.resume() // timer 시작
    }
  }
  
  func stopTimer() {
    if self.timerStatus == .pause {
      self.timer?.resume()
    }
    self.timerStatus = .end
    self.cancelButton.isEnabled = false // cancel 비활성화
    UIView.animate(withDuration: 0.5, animations: {
      self.timerLabel.alpha = 0
      self.progreesView.alpha = 0
      self.datePicker.alpha = 1
      self.imageView.transform = .identity
    })
    self.startButton.isSelected = false
    self.timer?.cancel()
    self.timer = nil
  }
  
}

