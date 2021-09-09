RSpec.describe "Data fetcher" do
  it "fetch with default options" do
    expect(Dir).to receive(:exist?).with("data").and_return true
    expect(File).to receive(:exist?).with("data/etag.txt").and_return false
    allow(File).to receive(:exist?).and_call_original
    body = File.read "spec/fixtures/data.yaml", encoding: "UTF-8"
    resp = double "Faraday response", status: 200, body: body
    expect(resp).to receive(:[]).with(:etag).and_return "1234"
    faraday = double "Faraday instance", get: resp
    expect(Faraday).to receive(:new).and_return faraday
    expect(File).to receive(:write).with("data/CC_ADM_0401_2004.yaml", kind_of(String), encoding: "UTF-8")
    expect(File).to receive(:write).with("data/CC_ADV_0707_2007.yaml", kind_of(String), encoding: "UTF-8")
    expect(File).to receive(:write).with("data/CC_ADM_0812_2008.yaml", kind_of(String), encoding: "UTF-8")
    expect(File).to receive(:write).with("data/etag.txt", "1234", encoding: "UTF-8")
    VCR.use_cassette "fetch_data" do
      RelatonCalconnect::DataFetcher.fetch # output: "dir", format: "xml"
    end
  end

  it "log error" do
    df = RelatonCalconnect::DataFetcher.new "dir", "xml"
    expect(RelatonCalconnect::Scrapper).to receive(:parse_page).and_raise StandardError
    expect { df.send(:parse_page, { "docid" => { "id" => "1234" }}) }.to output(/Document: 1234/).to_stderr
  end
end
