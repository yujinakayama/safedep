# Safedep

**safedep** automatically writes missing version specifiers for dependencies in your `Gemfile`.

## Installation

```bash
$ gem install safedep
```

## Usage

Run `safedep` command in your project's root directory,
and then you should see the `Gemfile` is modified.

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
$ egrep 'rake|rspec|rubocop ' Gemfile.lock
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
$ cat Gemfile
source 'https://rubygems.org'

group :development, :test do
  gem 'rake', '~> 10.4'
  gem 'rspec', '~> 3.1'
  gem 'rubocop', '~> 0.28'
end
```


## Contributing

1. Fork it ( https://github.com/yujinakayama/safedep/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
