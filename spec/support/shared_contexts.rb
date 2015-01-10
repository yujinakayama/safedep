
shared_context 'isolated environment' do
  around do |example|
    require 'tmpdir'
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        example.run
      end
    end
  end
end
