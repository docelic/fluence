class Acl::Path
  getter value : String

  def initialize(@value : String)
  end

  def acl_match?(other_path : String) : Bool
    return @value == other_path unless @value.includes?("*")
    !!Regex.new(@value.gsub("*", ".*")).match(other_path)
  end
end
