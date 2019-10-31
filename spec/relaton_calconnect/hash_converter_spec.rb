RSpec.describe RelatonCalconnect::HashConverter do
  it "creates item form YAML file" do
    yaml = YAML.load_file "spec/fixtures/cc_dir_10005_2019.yml"
    hash = RelatonCalconnect::HashConverter.hash_to_bib yaml
    item = RelatonCalconnect::CcBibliographicItem.new hash
    expect(item.to_hash).to eq yaml
  end
end
