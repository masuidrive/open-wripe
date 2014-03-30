module PropExtend
  def [](k)
    prop = where(:key => k).first
    prop ? prop.value : nil
  end
  
  def []=(k, v)
    prop = where(:key => k).first
    if prop
      prop.update_attribute :value, v
    else
      create(key: k, value: v)
    end
  end
end