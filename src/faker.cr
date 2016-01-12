require "./data.cr"
require "./faker/*"

module Faker
  def self.numerify(number_string)
    number_string = number_string as String
    number_string.sub(/#/) { (rand(9) + 1).to_s }.gsub(/#/) { rand(10).to_s }
  end

  def self.letterify(letter_string)
    letter_string.gsub(/\?/) { ("A".."Z").to_a.sample }
  end

  def self.bothify(string)
    self.letterify(self.numerify(string))
  end

  def self.regexify(re)
    re.gsub(/^\/?\^?/, "").gsub(/\$?\/?$/, "")                                                                                              # Ditch the anchors
.gsub(/\{(\d+)\}/, "{\1,\1}").gsub(/\?/, "{0,1}")                                                                                           # All {2} become {2,2} and ? become {0,1}
.gsub(/(\[[^\]]+\])\{(\d+),(\d+)\}/) { |match| $1 * ($2.to_i..$3.to_i).to_a.sample }                                                        # [12]{1,2} becomes [12] or [12][12]
.gsub(/(\([^\)]+\))\{(\d+),(\d+)\}/) { |match| $1 * ($2.to_i..$3.to_i).to_a.sample }                                                        # (12|34){1,2} becomes (12|34) or (12|34)(12|34)
.gsub(/(\\?.)\{(\d+),(\d+)\}/) { |match| $1 * ($2.to_i..$3.to_i).to_a.sample }                                                              # A{1,2} becomes A or AA or \d{3} becomes \d\d\d
.gsub(/\((.*?)\)/) { |match| match.gsub(/[\(\)]/, "").split("|").sample }                                                                   # (this|that) becomes "this" or "that"
.gsub(/\[([^\]]+)\]/) { |match| match.gsub(/(\w\-\w)/) { |range| ((0..range.size).map { |i| range[i] }).join("").split("-").to_a.sample } } # All A-Z inside of [] become C (or X, or whatever)
.gsub(/\[([^\]]+)\]/) { |match| $1.split("").sample }                                                                                       # All [ABC] become B (or A or C)
.gsub("\d") { |match| (0..9).to_a.sample }
.gsub("\w") { |match| (("A".."Z").to_a + (0..9).to_a).sample }
  end

  def self.fetch(data)
    data = data as Array
    fetched = data.sample as String
    if fetched.match(/^\//) && fetched.match(/\/$/) # A regex
      fetched = Faker.regexify(fetched)
    end

    Faker.parse(fetched) as String
  end

  def self.parse(st)
    st.gsub(/%\{([^\}]+)\}/) do |str, matches|
      # find_fn([Name.name, Name.first_name], $1)
      find_fnx($1)
    end
  end

  # macro find_fn(list, fn)
  #   case {{fn}}
  #     {% for l in list %}
  #       when "{{l}}"
  #         {{l}}
  #     {% end %}
  #   else
  #     "Hoaydaaa"
  #   end
  # end

  macro find_fnx(fn)
    case {{fn}}
    when "Address.building_number"
      Address.building_number
    when "Address.city_prefix"
      Address.city_prefix
    when "Address.city_suffix"
      Address.city_suffix
    when "Address.state"
      Address.state
    when "Address.street_name"
      Address.street_name
    when "Address.street_suffix"
      Address.street_suffix
    when "Company.name"
      Company.name
    when "Company.suffix"
      Company.suffix
    when "Name.first_name"
      Name.first_name
    when "Name.last_name"
      Name.last_name
    when "Name.name"
      Name.name
    when "Name.prefix"
      Name.prefix
    when "Name.suffix"
      Name.suffix
    else
      "Hoaydaaa"
    end
  end
end
