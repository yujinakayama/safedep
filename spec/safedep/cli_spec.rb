require 'safedep/cli'

module Safedep
  describe CLI do
    include FileHelper
    include_context 'isolated environment'

    subject(:cli) { CLI.new }

    describe '#run' do
      subject(:run) { cli.run(args) }
      let(:args) { [] }

      context 'when run successfully', :gemfile, :lockfile do
        it 'returns true' do
          allow(cli).to receive(:puts)
          expect(run).to be true
        end
      end

      context 'when there is no Gemfile.lock' do
        it 'warns of it' do
          expect { run }.to output(/Gemfile.lock/).to_stderr
        end

        it 'aborts processing' do
          allow(cli).to receive(:warn)
          expect { run }.not_to output.to_stdout
        end

        it 'returns false' do
          allow(cli).to receive(:warn)
          expect(run).to be false
        end
      end

      context 'when unknown error is raised' do
        before do
          allow(Runner).to receive(:run).and_raise('foo')
        end

        it 'does not rescue the error' do
          expect { run }.to raise_error('foo')
        end
      end
    end
  end
end
