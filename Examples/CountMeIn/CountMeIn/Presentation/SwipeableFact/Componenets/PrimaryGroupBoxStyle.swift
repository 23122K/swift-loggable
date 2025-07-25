import SwiftUI

struct PrimaryGroupBoxStyle: GroupBoxStyle {
  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading) {
      configuration.label
        .font(.body)
        .fontWeight(.semibold)
      
      configuration.content
        .font(.callout)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

extension GroupBoxStyle where Self == PrimaryGroupBoxStyle {
  static var primary: Self { PrimaryGroupBoxStyle() }
}

