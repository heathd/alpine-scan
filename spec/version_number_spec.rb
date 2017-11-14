require 'version_number'

RSpec.describe VersionNumber do
  it "can be initialised with string" do
    v = VersionNumber.new("2.5.27-r3")
    expect(v.major).to eq(2)
    expect(v.minor).to eq(5)
    expect(v.patch).to eq(27)
    expect(v.release).to eq(3)
  end

  it "can be initialised shorter string" do
    v = VersionNumber.new("2.5-r3")
    expect(v.major).to eq(2)
    expect(v.minor).to eq(5)
    expect(v.patch).to eq(nil)
    expect(v.release).to eq(3)
  end

  it "can be compared" do
    expect(VersionNumber.new("2.5.27-r3")).to eq VersionNumber.new("2.5.27-r3")
    expect(VersionNumber.new("2.5.27-r3")).to be < VersionNumber.new("2.5.27-r4")
    expect(VersionNumber.new("2.5.27-r3")).to be < VersionNumber.new("2.5.28-r0")
    expect(VersionNumber.new("2.5.27-r3")).to be < VersionNumber.new("2.7.0-r0")
    expect(VersionNumber.new("2.5.27-r3")).to be < VersionNumber.new("3.0.0-r0")
    expect(VersionNumber.new("2.5.27-r3")).to be > VersionNumber.new("2.5.27-r2")
    expect(VersionNumber.new("2.5.27-r3")).to be > VersionNumber.new("2.5.26-r9")
    expect(VersionNumber.new("2.5.27-r3")).to be > VersionNumber.new("2.4.99-r9")
    expect(VersionNumber.new("2.5.27-r3")).to be > VersionNumber.new("1.9.99-r9")
  end

  it "can't compare different lengths" do
    v1 = VersionNumber.new("2.5-r3")
    v2 = VersionNumber.new("2.5.3-r3")
    expect { v1 < v2 }.to raise_error /different lengths/
  end
end
