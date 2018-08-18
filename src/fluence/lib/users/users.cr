require "./user"

# The class `Users` handles a list of `User`, with add, remove, update an find operation.
# An instance of `Users` must be linked with a file which can be read of updated
#
# TODO: mutex on add/remove/update
class Fluence::Users < Lockable
  class AlreadyExists < Exception
  end

  class NotExists < Exception
  end

  # getter file : String
  # getter default : User?
  # @list : Hash(String, User)

  YAML.mapping(
    file: String,
    default: User?,
    list: Hash(String, User)
  )

  def initialize(@file, @default : User? = nil)
    @list = {} of String => User
    # TODO: set UNIX permissions
    ::File.touch(@file)
  end

  # read the users from the file (erase the modifications !)
  def load!
    if ::File.exists?(@file) && (new_users = Users.from_yaml(::File.read(@file)) rescue nil)
      @list = new_users.list
      @default = new_users.default
      # @file = new_users.file
    else
      @list = {} of String => User
    end
    self
  end

  # save the users into the file
  def save!
    ::File.write @file, self.to_yaml
  end

  # add an user to the list
  def add(u : User)
    raise AlreadyExists.new "User #{u.name} already exists" if (@list[u.name]?)
    @list[u.name] = u
    self
  end

  # Removes an user from the list
  # @see #delete(String)
  def delete(u : User)
    delete u.name
    self
  end

  # Remove an user from the list
  def delete(name : String)
    raise NotExists.new "User #{name} is not in the list" if (!@list[name]?)
    @list.delete name
    self
  end

  # replace an entry
  def update(name : String, u : User)
    raise NotExists.new "User #{name} is not in the list" if (!@list[name]?)

    # if the name change
    if name != u.name
      add u # if it fails, remove will fail too
      remove name
    else
      @list[u.name] = u
    end
    self
  end

  # find an user based on its name
  def find(name : String) : User
    user = @list[name]?
    raise NotExists.new "User #{name} is not in the list" unless user
    user
  end

  # find an user based on its name
  def find?(name : String) : User?
    user = @list[name]?
  end

  def [](name : String) : User
    find name
  end

  def []?(name : String) : User?
    find? name
  end

  def each
    @list.each { |_, user| yield user }
  end

  def map
    @list.map { |_, user| yield user }
  end

  def map!
    @list.map! { |name, user| {name, yield user} }
  end

  ##################
  # HIGH LEVEL API #
  ##################

  # No file operation.
  #
  # Finds an user by its name and check the password.
  #
  # Returns nil if it fails
  def auth?(name : String, password : String) : User?
    user = find?(name)
    user && user.password_encrypted == password ? user : nil
  end

  def auth_token?(name : String, token : String) : User?
    user = find?(name)
    user && user.token == token ? user : nil
  end

  # Operation read (erase the internal list).
  #
  # see `#auth?`
  def auth!(name : String, password : String) : User?
    self.load!
    auth?(name, password)
  end

  def auth_token!(name : String, token : String) : User?
    self.load!
    auth_token?(name, token)
  end

  # Operation read and write (erase the internal list and the file)
  #
  # Registers a new user by create a new `User` with `name`, `password` and `groups`
  # and then update the file with the new list of users.
  def register!(name : String, password : String, groups : Array(String) = %w(user))
    user = User.new(name, password, groups).encrypt!
    self.transaction! do |users|
      users.add user
    end
    user
  end
end

# file = "/tmp/users"
# ::File.touch(file)
# include Fluence
# users = Users.new(file)
# users.load!
# pp users
# user = User.new("arthur", "passwd", %w(admin,user)).encrypt
# users.add user
# users.save!
# p users
# pp Crypto::Bcrypt::Password.new(user.password) == "passwd"
# pp users.auth?("arthur", "passwd")
# pp users.auth?("arthur", "passwdx")
# pp users.auth?("arthurx", "passwd") # raise here
