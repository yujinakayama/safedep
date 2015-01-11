require 'safedep/policy/sem_ver'

module Safedep
  module Policy
    describe SemVer do
      describe '.version_specifiers' do
        subject { SemVer.version_specifiers(version) }

        [
          ['0.0.1',       ['~> 0.0']],
          ['1.2.34',      ['~> 1.2']],
          ['1.2',         ['~> 1.2']],
          ['1',           ['~> 1.0']],
          ['1.2.1.beta1', ['~> 1.2']],
          ['1.2.0.beta1', nil], # TODO
          ['1.2.beta1',   nil], # TODO
          ['1.beta1',     nil], # TODO
        ].each do |version_string, specifiers|
          context "with #{version_string}" do
            let(:version) { Gem::Version.new(version_string) }
            let(:requirement) { Gem::Requirement.new(*specifiers) }

            it { should eq(specifiers) }

            if specifiers
              it 'returns version specifiers satisfied by the passed version' do
                expect(requirement).to be_satisfied_by(version)
              end
            end
          end
        end
      end
    end
  end
end
