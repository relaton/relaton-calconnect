RSpec.describe RelatonCalconnect::HashConverter do
  it "creates item form YAML file" do
    yaml = YAML.load_file "spec/fixtures/cc_dir_10005_2019.yml"
    item = RelatonCalconnect::CcBibliographicItem.from_hash yaml
    expect(item.to_h).to eq yaml
  end
end
