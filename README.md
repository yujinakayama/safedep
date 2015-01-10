[![Gem Version](http://img.shields.io/gem/v/safedep.svg?style=flat)](http://badge.fury.io/rb/safedep)
[![Dependency Status](http://img.shields.io/gemnasium/yujinakayama/safedep.svg?style=flat)](https://gemnasium.com/yujinakayama/safedep)
[![Build Status](https://travis-ci.org/yujinakayama/safedep.svg?branch=master&style=flat)](https://travis-ci.org/yujinakayama/safedep)
[![Coverage Status](http://img.shields.io/coveralls/yujinakayama/safedep/master.svg?style=flat)](https://coveralls.io/r/yujinakayama/safedep)
[![Code Climate](https://img.shields.io/codeclimate/github/yujinakayama/safedep.svg?style=flat)](https://codeclimate.com/github/yujinakayama/safedep)

# Safedep

**safedep** automatically writes missing version specifiers for dependencies in your `Gemfile`.

## Example

Here's a `Gemfile` with dependencies without version specifier:

```bash
$ cat Gemfile
source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'rspec'
  gem 'rubocop'
end
```

And they have already been installed via `bundle install`:

```bash
$ egrep '(rake|rspec|rubocop) ' Gemfile.lock
    rake (10.4.2)
    rspec (3.1.0)
    rubocop (0.28.0)
```

Then run `safedep`:

```bash
$ safedep
```

Now the `Gemfile` should have safe version specifiers in the SemVer way:

```bash
$ git diff
diff --git a/Gemfile b/Gemfile
index 5ff2c3c..488dd41 100644
--- a/Gemfile
+++ b/Gemfile
@@ -1,7 +1,7 @@
 source 'https://rubygems.org'

 group :development, :test do
-  gem 'rake'
-  gem 'rspec'
-  gem 'rubocop'
+  gem 'rake', '~> 10.4'
+  gem 'rspec', '~> 3.1'
+  gem 'rubocop', '~> 0.28'
 end
```

## Installation

```bash
$ gem install safedep
```

## Usage

Just run `safedep` command in your project's root directory,
and then you should see the `Gemfile` is modified.

```bash
$ cd your-project
$ safedep
```

## Options

### `--without`

Specify groups to skip modification as comma-separated list.

```bash
$ safedep --without development,test
```

## Compatibility

Tested on MRI 1.9.3, 2.0, 2.1, 2.2 and JRuby in 1.9 mode.

## License

Copyright (c) 2015 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
