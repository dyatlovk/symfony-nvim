(return_statement
  (member_call_expression
    object: (variable_name) @This
    name: (name) @Render
    (#eq? @This "$this")
    (#eq? @Render "render")
    arguments: (arguments (argument)* @TemplatePath)
  )
)
