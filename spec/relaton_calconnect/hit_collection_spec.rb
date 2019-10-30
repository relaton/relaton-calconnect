RSpec.describe RelatonCalconnect::HitCollection do
  it "fetch data" do
    if File.exist? RelatonCalconnect::HitCollection::DATAFILE
      File.unlink RelatonCalconnect::HitCollection::DATAFILE
    end
    if File.exist? RelatonCalconnect::HitCollection::ETAGFILE
      File.unlink RelatonCalconnect::HitCollection::ETAGFILE
    end
    expect(File).to receive(:write).with(
      RelatonCalconnect::HitCollection::ETAGFILE, kind_of(String), encoding: "UTF-8"
    )
    expect(File).to receive(:write).with(
      RelatonCalconnect::HitCollection::DATAFILE, kind_of(String), encoding: "UTF-8"
    )
    VCR.use_cassette "data", match_requests_on: [:path] do
      RelatonCalconnect::HitCollection.new "code"
    end
  end
end
