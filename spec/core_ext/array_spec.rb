require 'spec_helper'

describe Array do
  describe "sum_with_identity" do
    it "should sum the array" do
      [1,2,3].sum_with_identity.should eq(6)
    end

    it "should return 0 when it encounters an empty array" do
      [].sum_with_identity.should eq(0)
    end
  end
end
