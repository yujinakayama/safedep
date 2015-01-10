
# This group allows to skip running RuboCop if RSpec failed,
# like Red > Green (RSpec) > Refactor (RuboCop).
group :red_green_refactor, halt_on_fail: true do
  guard :rspec, cmd: 'bundle exec rspec --format Fuubar' do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})        { |m| "spec/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')     { 'spec' }
    watch(%r{^spec/support/.+\.rb$}) { 'spec' }
  end

  guard :rubocop, all_on_start: false, cli: '--format fuubar' do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end
