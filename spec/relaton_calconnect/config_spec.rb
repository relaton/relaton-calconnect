describe RelatonCalconnect do
  after { RelatonCalconnect.instance_variable_set :@configuration, nil }

  it "configure" do
    RelatonCalconnect.configure do |conf|
      conf.logger = :logger
    end
    expect(RelatonCalconnect.configuration.logger).to eq :logger
  end
end
