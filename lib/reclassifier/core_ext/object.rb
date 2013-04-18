class Object
	def prepare_category_name; to_s.gsub("_"," ").capitalize.intern end
end
