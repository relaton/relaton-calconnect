describe RelatonCalconnect::DocumentType do
  it "warns if invalid doctype" do
    expect do
      RelatonCalconnect::DocumentType.new type: "invalid"
    end.to output(/\[relaton-calconnect\] WARNING: invalid doctype: `invalid`/).to_stderr
  end
end
