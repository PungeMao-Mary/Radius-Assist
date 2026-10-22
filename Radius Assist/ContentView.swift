import SwiftUI

@Observable
final class TimePitchSyncViewModel {
    var stretchRatio: Double = 84.0
    var pitchShift: Double = 3.0
    var fromBPM: Double = 120.0
    var toBPM: Double = 142.86
    var ratioText: String = "84.00"

    private var isUpdating: Bool = false

    func updateByStretchRatio(_ newRatio: Double) {
        guard !isUpdating else { return }
        isUpdating = true
        stretchRatio = newRatio
        ratioText = String(format: "%.2f", newRatio)
        pitchShift = PitchTimeCalculator.pitchShift(fromStretchRatio: newRatio)
        toBPM = PitchTimeCalculator.targetBPM(fromBPM: fromBPM, stretchRatio: newRatio)
        isUpdating = false
    }

    // 新增由文本提交触发的更新方法：
    func commitRatioText() {
        if let parsedRatio = PitchTimeCalculator.parseRatioExpression(ratioText) {
            updateByStretchRatio(parsedRatio)
        } else {
            // 解析失败时回滚显示
            ratioText = String(format: "%.2f", stretchRatio)
        }
    }

    func updateByPitchShift(_ newPitch: Double) {
        guard !isUpdating else { return }
        ratioText = String(format: "%.2f", stretchRatio)
        isUpdating = true
        pitchShift = newPitch
        let newRatio = PitchTimeCalculator.stretchRatio(fromPitchShift: newPitch)
        stretchRatio = newRatio
        toBPM = PitchTimeCalculator.targetBPM(fromBPM: fromBPM, stretchRatio: newRatio)
        isUpdating = false
    }

    func updateByToBPM(_ newToBPM: Double) {
        guard !isUpdating, newToBPM > 0 else { return }
        ratioText = String(format: "%.2f", stretchRatio)
        isUpdating = true
        toBPM = newToBPM
        let newRatio = PitchTimeCalculator.stretchRatio(fromBPM: fromBPM, toBPM: newToBPM)
        stretchRatio = newRatio
        pitchShift = PitchTimeCalculator.pitchShift(fromStretchRatio: newRatio)
        isUpdating = false
    }

    func updateByFromBPM(_ newFromBPM: Double) {
        guard !isUpdating, newFromBPM > 0 else { return }
        isUpdating = true
        fromBPM = newFromBPM
        toBPM = PitchTimeCalculator.targetBPM(fromBPM: newFromBPM, stretchRatio: stretchRatio)
        isUpdating = false
    }
}

struct ContentView: View {
    @State private var viewModel = TimePitchSyncViewModel()

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Radius Time & Pitch Calculator")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            // Stretch Ratio & BPM Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Stretch ratio [%]")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    TextField("Ratio", text: $viewModel.ratioText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 90)
                        .multilineTextAlignment(.trailing)
                        .onSubmit {
                            viewModel.commitRatioText()
                        }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .multilineTextAlignment(.trailing)
                }

                Slider(
                    value: Binding(
                        get: { viewModel.stretchRatio },
                        set: { viewModel.updateByStretchRatio($0) }
                    ),
                    in: 25.0...200.0,
                    step: 0.1
                )
                .tint(.blue)

                // BPM Row
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("From BPM")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("From", value: Binding(
                            get: { viewModel.fromBPM },
                            set: { viewModel.updateByFromBPM($0) }
                        ), format: .number.precision(.fractionLength(2)))
                        .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("To BPM")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("To", value: Binding(
                            get: { viewModel.toBPM },
                            set: { viewModel.updateByToBPM($0) }
                        ), format: .number.precision(.fractionLength(2)))
                        .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(8)

            // Pitch Shift Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Pitch shift [semitones]")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    TextField("Semitones", value: Binding(
                        get: { viewModel.pitchShift },
                        set: { viewModel.updateByPitchShift($0) }
                    ), format: .number.precision(.fractionLength(1...2)))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .multilineTextAlignment(.trailing)
                }

                Slider(
                    value: Binding(
                        get: { viewModel.pitchShift },
                        set: { viewModel.updateByPitchShift($0) }
                    ),
                    in: -24.0...24.0,
                    step: 0.01
                )
                .tint(.blue)
            }
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(8)

            Spacer()
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 380)
        .background(Color(white: 0.1))
        .preferredColorScheme(.dark)
    }
}
