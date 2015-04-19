# Changelog

## Development

## v0.3.1

* Handle deprecated `Gemologist::AbstractGemfile#rewrite!`.

## v0.3.0

* Use extracted core gem [gemologist](https://github.com/yujinakayama/gemologist) internally.

## v0.2.0

* Skip modification of dependencies that have `:git`, `:github` or `:path` option.
* Handle depdendencies with prerelease version.

## v0.1.2

* Handle error raised when dependency definition is not found in `Gemfile.lock`.

## v0.1.1

* Fix unaligned help message.

## v0.1.0

* Add `--without` option for skipping arbitrary groups.
* Abort processing if `Gemfile` or `Gemfile.lock` does not exist.

## v0.0.2

* Fix an error when a `Gemfile` includes `bundler` dependency without version specifier.

## v0.0.1

* Initial release.
