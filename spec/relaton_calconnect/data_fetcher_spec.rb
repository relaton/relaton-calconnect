RSpec.describe RelatonCalconnect::DataFetcher do
  it "initialize" do
    df = RelatonCalconnect::DataFetcher.new "dir", "bibxml"
    expect(df.instance_variable_get(:@output)).to eq "dir"
    expect(df.instance_variable_get(:@etagfile)).to eq "dir/etag.txt"
    expect(df.instance_variable_get(:@format)).to eq "bibxml"
    expect(df.instance_variable_get(:@ext)).to eq "xml"
    expect(df.instance_variable_get(:@files)).to eq []
    expect(df.instance_variable_get(:@index)).to be_instance_of Relaton::Index::Type
  end

  it "::fetch" do
    expect(FileUtils).to receive(:mkdir_p).with("data")
    df = double "data fetcher"
    expect(df).to receive(:fetch)
    expect(described_class).to receive(:new).with("data", "yaml").and_return df
    described_class.fetch
  end

  context "instance methods" do
    subject { described_class.new "data", "yaml" }
    let(:index) { subject.instance_variable_get :@index }
    let(:files) { subject.instance_variable_get :@files }

    it "#fetch" do
      expect(subject).to receive(:etag).and_return nil
      faraday = double "Faraday instance"
      body = File.read "spec/fixtures/data.yaml", encoding: "UTF-8"
      response = double "Faraday response", status: 200, body: body
      expect(response).to receive(:[]).with(:etag).and_return "1234"
      expect(faraday).to receive(:get).with(no_args).and_return response
      expect(Faraday).to receive(:new)
        .with(RelatonCalconnect::DataFetcher::ENDPOINT, headers: { "If-None-Match" => nil })
        .and_return faraday
      expect(subject).to receive(:parse_page).with(kind_of(Hash)).and_return(true).exactly(3).times
      expect(subject).to receive(:etag=).with("1234")
      expect(index).to receive(:save)
      subject.fetch
    end

    context "#parse_page" do
      it do
        expect(RelatonCalconnect::Scrapper).to receive(:parse_page).with(kind_of(Hash)).and_return :bib
        expect(subject).to receive(:write_doc).with("1234", :bib)
        expect(subject.send(:parse_page, { "docid" => { "id" => "1234" } })).to be true
      end

      it "log error" do
        expect(RelatonCalconnect::Scrapper).to receive(:parse_page).and_raise StandardError
        expect { subject.send(:parse_page, { "docid" => { "id" => "1234" } }) }.to output(/Document: 1234/).to_stderr
      end
    end

    context "#write_doc" do
      let(:bib) { double "bibliographic item" }

      context "yaml" do
        before do
          hash = double "hash"
          expect(hash).to receive(:to_yaml).and_return :yaml
          expect(bib).to receive(:to_hash).and_return hash
          expect(index).to receive(:add_or_update).with("1234", "data/1234.yaml")
          expect(File).to receive(:write).with("data/1234.yaml", :yaml, encoding: "UTF-8")
        end

        it do
          subject.send(:write_doc, "1234", bib)
          expect(files).to include "data/1234.yaml"
        end

        it "warn if file exist" do
          files << "data/1234.yaml"
          expect { subject.send(:write_doc, "1234", bib) }.to output(/exist/).to_stderr
        end
      end

      context "xml" do
        before do
          subject.instance_variable_set :@ext, "xml"
          expect(index).to receive(:add_or_update).with("1234", "data/1234.xml")
          expect(File).to receive(:write).with("data/1234.xml", :xml, encoding: "UTF-8")
        end

        it "xml" do
          subject.instance_variable_set :@format, "xml"
          expect(bib).to receive(:to_xml).with(bibdata: true).and_return :xml
          subject.send(:write_doc, "1234", bib)
        end

        it "bibxml" do
          subject.instance_variable_set :@format, "bibxml"
          expect(bib).to receive(:to_bibxml).and_return :xml
          subject.send(:write_doc, "1234", bib)
        end
      end
    end

    context "#etag" do
      it "file exist" do
        expect(File).to receive(:exist?).with("data/etag.txt").and_return true
        expect(File).to receive(:read).with("data/etag.txt", encoding: "UTF-8").and_return "1234"
        expect(subject.send(:etag)).to eq "1234"
      end

      it "file doesn't exist" do
        expect(File).to receive(:exist?).with("data/etag.txt").and_return false
        expect(subject.send(:etag)).to be_nil
      end
    end

    it "#etag=" do
      expect(File).to receive(:write).with("data/etag.txt", "1234", encoding: "UTF-8")
      subject.send(:etag=, "1234")
    end
  end
end
