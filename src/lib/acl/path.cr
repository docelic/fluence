class Acl::Path
  getter path : String

  def initialize(@path : String)
  end

  def acl_validates?(other_path : String) : Bool
    return @path == other_path unless @path.includes?("*")
    !!Regex.new(@path.gsub("*", ".*")).match(other_path)
  end
end
