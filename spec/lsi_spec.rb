require 'spec_helper'

describe Reclassifier::LSI do
  before do
	  # we repeat principle words to help weight them.
	  # This test is rather delicate, since this system is mostly noise.
    @str1 = "This text deals with dogs. Dogs."
	  @str2 = "This text involves dogs too. Dogs! "
	  @str3 = "This text revolves around cats. Cats."
	  @str4 = "This text also involves cats. Cats!"
	  @str5 = "This text involves birds. Birds."
  end

  it "should do basic indexing" do
    [@str1, @str2, @str3, @str4, @str5].each { |x| subject << x }
	  subject.needs_rebuild?.should be(false)

  	# note that the closest match to str1 is str2, even though it is not
    # the closest text match.
    subject.find_related(@str1, 3).should eq([@str2, @str5, @str3])
  end

  it "should not auto rebuild when it's specified as false" do
	 subject = described_class.new(:auto_rebuild => false)

	 subject.add_item @str1, "Dog"
	 subject.add_item @str2, "Dog"

	 subject.needs_rebuild?.should be(true)

	 subject.build_index

	 subject.needs_rebuild?.should be(false)
  end

  it "should do basic classifying" do
	  subject.add_item(@str2, "Dog")
	  subject.add_item(@str3, "Cat")
	  subject.add_item(@str4, "Cat")
	  subject.add_item(@str5, "Bird")

	  subject.classify(@str1).should eq("Dog")
	  subject.classify(@str3).should eq("Cat")
    subject.classify(@str5).should eq("Bird")
  end

  it "should perform better than Bayes" do
	  bayes = Reclassifier::Bayes.new([:dog, :cat, :bird])

    [[@str1, "Dog"],
 		 [@str2, "Dog"],
		 [@str3, "Cat"],
		 [@str4, "Cat"],
		 [@str5, "Bird"]].each do |str, classification|
      subject.add_item(str, classification)

      bayes.train(classification.downcase.to_sym, str)
    end

	  # We're talking about dogs. Even though the text matches the corpus on
	  # cats better.  Dogs have more semantic weight than cats. So bayes
	  # will fail here, but the LSI recognizes content.
	  tricky_case = "This text revolves around dogs."
	  subject.classify(tricky_case).should eq("Dog")
	  bayes.classify(tricky_case).should eq(:dog)
  end

  it "should recategorize as needed" do
	  subject.add_item(@str1, "Dog")
	  subject.add_item(@str2, "Dog")
	  subject.add_item(@str3, "Cat")
	  subject.add_item(@str4, "Cat")
	  subject.add_item(@str5, "Bird")

	  tricky_case = "This text revolves around dogs."
	  subject.classify(tricky_case).should eq("Dog")

	  # Recategorize as needed.
	  subject.categories_for(@str1).clear.push("Cow")
	  subject.categories_for(@str2).clear.push("Cow")

	  subject.needs_rebuild?.should be(false)
	  subject.classify(tricky_case).should eq("Cow")
  end

  it "should search correctly" do
	  [@str1, @str2, @str3, @str4, @str5].each { |x| subject << x }

	  # Searching by content and text, note that @str2 comes up first, because
	  # both "dog" and "involve" are present. But, the next match is @str1 instead
	  # of @str4, because "dog" carries more weight than involves.
    subject.search("dog involves", 100).should eq([@str2, @str1, @str4, @str5, @str3])

	  # Keyword search shows how the space is mapped out in relation to
	  # dog when magnitude is remove. Note the relations. We move from dog
	  # through involve and then finally to other words.
    subject.search("dog", 5).should eq([@str1, @str2, @str4, @str5, @str3])
  end

  it "should serialize correctly" do
	  [@str1, @str2, @str3, @str4, @str5].each { |x| subject << x }

	  subject_md = Marshal.dump(subject)
	  subject_m = Marshal.load(subject_md)

	  subject_m.search("cat", 3).should eq(subject.search("cat", 3))
	  subject_m.find_related(@str1, 3).should eq(subject.find_related(@str1, 3))
  end

  it "should keyword search correctly" do
	  subject.add_item(@str1, "Dog")
	  subject.add_item(@str2, "Dog")
	  subject.add_item(@str3, "Cat")
	  subject.add_item(@str4, "Cat")
	  subject.add_item(@str5, "Bird")

    subject.highest_ranked_stems(@str1).should eq([:dog, :text, :deal])
  end

  it "should summarize correctly" do
    [@str1, @str2, @str3, @str4, @str5].join.summary(2).should eq("This text involves dogs too [...] This text also involves cats")
  end
end
