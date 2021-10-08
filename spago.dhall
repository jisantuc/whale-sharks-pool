{-
Welcome to a Spago project!
You can edit this file as you like.

Need help? See the following resources:
- Spago documentation: https://github.com/purescript/spago
- Dhall language tour: https://docs.dhall-lang.org/tutorials/Language-Tour.html

When creating a new Spago project, you can use
`spago init --no-comments` or `spago init -C`
to generate this file without the comments in this block.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "affjax"
  , "argonaut-codecs"
  , "argonaut-core"
  , "argonaut-generic"
  , "bifunctors"
  , "console"
  , "datetime"
  , "effect"
  , "either"
  , "enums"
  , "exceptions"
  , "foldable-traversable"
  , "foreign-object"
  , "formatters"
  , "functions"
  , "halogen"
  , "lists"
  , "maybe"
  , "newtype"
  , "node-process"
  , "partial"
  , "prelude"
  , "psci-support"
  , "spec"
  , "spec-discovery"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src-ps/**/*.purs", "test/**/*.purs" ]
}
