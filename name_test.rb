class NameSplitter
  PREFIXES = %w(De Du Di Le La Van Von O Mc Mac Ni Ua Ui Ó Ní).freeze

  def self.parse(full_name)
    pcs = full_name.strip.split(" ")
    surname = pcs.pop
    
    while pcs.any? && PREFIXES.include?(pcs.last)
      surname = "#{pcs.pop} #{surname}"
    end
    
    given_name = pcs.join(" ")
    
    [given_name, surname]
  end
end

examples = [
  "Hazel De Nortuin",
  "Naoise O Muiri",
  "Briege Mac Oscar",
  "John Smith",
  "Mary Van Der Sar",
  "Patrick O'Brien"
]

examples.each do |name|
  given, family = NameSplitter.parse(name)
  puts "#{name} -> Given: '#{given}', Family: '#{family}', Sort: '#{family}, #{given}'"
end
