ParameterType(name: 'is_parent_section',
              regexp: /(this|parent)/,
              type: [TrueClass, FalseClass],
              transformer: ->(value) { value == 'parent' })