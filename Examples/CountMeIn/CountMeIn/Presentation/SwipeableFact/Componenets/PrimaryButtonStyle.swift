import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
  let color: Color
  
  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .center) {
      configuration.label
        .font(.body)
        .fontWeight(.semibold)
        .foregroundStyle(Color.white)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.primary)
    .background(self.color)
    .cornerRadius(.primary)
    .opacity(configuration.isPressed ? 0.8 : 1)
  }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
  static func primary(_ color: Color) -> Self {
    PrimaryButtonStyle(color: color)
  }
}
