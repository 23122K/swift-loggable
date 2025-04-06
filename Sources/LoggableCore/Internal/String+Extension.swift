
extension String {
  static func _parameterRawValue(_ name: String) -> String { #"_parameter_\(name)"# }
  static func _tagRawValue(_ name: String) -> String { #"_tag_\(name)"# }
  static let _parametersRawValue = #"_parameters"#
  static let _resultRawValue = #"_result"#
}
