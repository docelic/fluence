require "crypto/bcrypt/password"
require "./acl/entity"

class Wikicr::User
  class Invalid < Exception
  end

  SEP = ':'

  getter name : String
  getter password : String
  getter groups : Array(String)

  def initialize(@name, @password, @groups = [] of String)
    raise "Invalid name #{@name}" if !@name =~ /^[A-Za-z0-9 _.-]+$/ # Security: Avoid escaping and injection of code
  end

  def initialize(line : String)
    split = line.split SEP
    raise Invalid.new("Cannot parse this line (split.size = #{split.size}, should be 3)") if split.size != 3
    @name = split[0]
    @password = split[1]
    @groups = split[2].split(",")
  end

  def encrypt!
    @password = Crypto::Bcrypt::Password.create(@password).to_s
    self
  end

  def password_encrypted
    Crypto::Bcrypt::Password.new(@password)
  end

  def to_s
    "#{name}#{SEP}#{password}#{SEP}#{groups.join(",")}"
  end

  def to_s(io : IO)
    io << name << SEP
    io << password << SEP
    groups.each { |g| io << g; io << ',' if g != groups.last }
    io << '\n'
  end

  #########################
  # Implement ACL::Entity #
  #########################
  include ACL::Entity

  # getter groups : Array(String)

  def has_group?(group : String) : Bool
    @groups.includes?(group)
  end
end
