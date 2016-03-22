//
//  NSTimer+Extension+ZKJS.swift
//  SVIP
//
//  Created by Qin Yejun on 3/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

final class TimerBlock<T> {
  let f : T
  init (_ f: T) { self.f = f }
}

extension NSTimer {
  static func scheduledTimerWithTimeInterval(ti: NSTimeInterval, block: ()->(), repeats: Bool) -> NSTimer {
    return self.scheduledTimerWithTimeInterval(ti, target:
      self, selector: "blcokInvoke:", userInfo: TimerBlock(block), repeats: repeats)
  }
  
  static func blcokInvoke(timer: NSTimer) {
    if let block = timer.userInfo as? TimerBlock<()->()> {
      block.f()
    }
  }
}