import Foundation

struct PitchTimeCalculator {
    /// 根据拉伸比率（Stretch Ratio %）计算音高变化（半音）
    /// - Parameter stretchRatio: 拉伸比率，例如 84.0 代表时长变为 84%（即加速）
    static func pitchShift(fromStretchRatio stretchRatio: Double) -> Double {
        guard stretchRatio > 0 else { return 0 }
        let speedFactor = 100.0 / stretchRatio
        return 12.0 * log2(speedFactor)
    }

    /// 根据音高变化（半音）计算拉伸比率（Stretch Ratio %）
    /// - Parameter semitones: 半音变化，例如 +3.0
    static func stretchRatio(fromPitchShift semitones: Double) -> Double {
        let speedFactor = pow(2.0, semitones / 12.0)
        guard speedFactor > 0 else { return 100.0 }
        return 100.0 / speedFactor
    }

    /// 根据起止 BPM 计算拉伸比率（Stretch Ratio %）
    static func stretchRatio(fromBPM: Double, toBPM: Double) -> Double {
        guard fromBPM > 0, toBPM > 0 else { return 100.0 }
        return (fromBPM / toBPM) * 100.0
    }

    /// 根据原始 BPM 与拉伸比率计算目标 BPM
    static func targetBPM(fromBPM: Double, stretchRatio: Double) -> Double {
        guard stretchRatio > 0 else { return fromBPM }
        return fromBPM / (stretchRatio / 100.0)
    }
}

extension PitchTimeCalculator {
    /// 解析输入文本（支持 "84.0"、"1/1.2"、"100/120" 等格式），返回百分比值（例如 83.33）
    static func parseRatioExpression(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 包含除号的分数计算
        if trimmed.contains("/") {
            let parts = trimmed.split(separator: "/").map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count == 2,
               let numerator = Double(parts[0]),
               let denominator = Double(parts[1]),
               denominator != 0 {
                let value = numerator / denominator
                // 如果结果小于等于 5.0（例如 1/1.2 = 0.833 或 4/3 = 1.33），视为主倍率，换算为百分比（* 100）
                // 如果用户输入 100/1.2 = 83.33，则保持原百分比
                return value <= 5.0 ? value * 100.0 : value
            }
            return nil
        }
        
        // 普通纯数字
        if let directValue = Double(trimmed) {
            // 如果用户输入 0.833 这种纯小数倍率，自动转为 83.3%
            return directValue <= 5.0 && directValue > 0 ? directValue * 100.0 : directValue
        }
        
        return nil
    }
}
