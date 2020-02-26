RSpec.describe RelatonCalconnect::XMLParser do
  it "warn if XML doesn't have bibitem or bibdata element" do
    item = ""
    expect { item = RelatonCalconnect::XMLParser.from_xml "" }.to output(/can't find bibitem/)
      .to_stderr
    expect(item).to be_nil
  end
end
