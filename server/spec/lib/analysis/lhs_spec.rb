require 'spec_helper'

describe Analysis::Lhs do
  before :each do
    # need to populate the database with an analysis and datapoints

    # delete all the analyses

    # take static = [{a: 1, b: 2}]
    # with samples = [{c: 3}, {d: 4}]
    # results is [{a:1, b:2, c:3}, {a:1, b:2, d:4}]

    # take p = [{p1: 1}, {p1: 2}]
    # with s = [{a: 1, b: 4}, {a: 2, b: 5}, {a: 3, b: 6}]
    # make s' = [{p1: 1, a: 1, b: 4}, {p1: 2, a: 1, b: 4}, {p1: 1, a: 2, b: 5},  {p1: 2, a: 2, b: 5}]
    @pivots = [{p1: "p1"}, {p1: "p2"}]
    @samples = [{a: 1, b: 2}, {a: 3, b: 4}, {e: 5}]
    @statics = [{s1: "a"}, {s2: true}]
  end

  it "should have the right sizes" do
    @pivots.size.should eq(2)
    @samples.size.should eq(3)
    @statics.size.should eq(2)
  end

  it "static result should return the same length" do
    result = Analysis::Lhs.add_static_variables(@samples, @statics)
    puts "Static hash returned with #{result.inspect}"

    result.size.should eq(3)
    result[0].should eq({a: 1, b: 2, s1: "a", s2: true})
  end

  it "pivot result should have double the length" do
    result = Analysis::Lhs.add_pivots(@samples, @pivots)
    puts "Pivot hash returned with #{result.inspect}"

    result.size.should eq(6)
    result[0].should eq({p1: "p1", a: 1, b: 2})
  end
end