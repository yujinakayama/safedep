[![Gem Version](https://badge.fury.io/rb/safedep.svg)](http://badge.fury.io/rb/safedep)
[![Build Status](https://travis-ci.org/yujinakayama/safedep.svg?branch=master&style=flat)](https://travis-ci.org/yujinakayama/safedep)
[![Coverage Status](https://coveralls.io/repos/yujinakayama/safedep/badge.svg?branch=master&service=github)](https://coveralls.io/github/yujinakayama/safedep?branch=master)
[![Code Climate](https://codeclimate.com/github/yujinakayama/safedep/badges/gpa.svg)](https://codeclimate.com/github/yujinakayama/safedep)

# Safedep

**safedep** automatically writes missing version specifiers for dependencies in your `Gemfile`.

* [Using >= Considered Harmful (or, What’s Wrong With >=) « Katz Got Your Tongue?](http://yehudakatz.com/2010/08/21/using-considered-harmful-or-whats-wrong-with/)

Version specifier with `>=` is considered harmful, then dependencies without version specifier must be super harmful. :)

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

Tested on MRI 2.2, 2.3, 2.4, 2.5 and JRuby 9000.

## License

Copyright (c) 2015 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
