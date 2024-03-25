describe RelatonCalconnect::DocumentType do
  it "warns if invalid doctype" do
    expect do
      RelatonCalconnect::DocumentType.new type: "invalid"
    end.to output(/\[relaton-calconnect\] WARN: Invalid doctype: `invalid`/).to_stderr_from_any_process
  end
end
