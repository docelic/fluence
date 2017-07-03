require "./user"

# The class `Users` handles a list of `User`, with add, remove, update an find operation.
# An instance of `Users` must be linked with a file which can be read of updated
#
# TODO: mutex on add/remove/update
class Wikicr::Users
  class AlreadyExist < Exception
  end

  class NotExist < Exception
  end

  getter file : String
  @list : Hash(String, User)

  def initialize(@file)
    @list = {} of String => User
    # TODO: set UNIX permissions
    File.touch(@file)
  end

  # read the users from the file (erase the modifications !)
  def read!
    @list = File.read(@file).split("\n")
                            .select { |line| !line.empty? }
                            .map { |line| u = User.new(line); {u.name, u} }.to_h
    self
  end

  # save the users into the file
  def save!
    File.open(@file, "w") do |fd|
      @list.each { |name, user| user.to_s(fd) }
    end
    self
  end

  # add an user to the list
  def add(u : User)
    raise AlreadyExist.new "User #{u.name} already exists" if (@list[u.name]?)
    @list[u.name] = u
    self
  end

  # remove an user from the list
  # @see .remove(String)
  def remove(u : User)
    remove u.name
    self
  end

  # remove an user from the list
  def remove(name : String)
    raise NotExist.new "User #{name} is not in the list" if (!@list[name]?)
    @list.remove(name)
    self
  end

  # replace an entry
  def update(name : String, u : User)
    raise NotExist.new "User #{name} is not in the list" if (!@list[name]?)

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
    raise NotExist.new "User #{name} is not in the list" if (!@list[name]?)
    @list[name]
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
    user = find(name)
    user.password_encrypted == password ? user : nil
  end

  # Operation read (erase the internal list).
  #
  # see `#auth?`
  def auth!(name : String, password : String) : User?
    self.read!
    auth?(name, password)
  end

  # Operation read and write (erase the internal list and the file)
  #
  # Registers a new user by create a new `User` with `name`, `password` and `groups`
  # and then update the file with the new list of users.
  def register!(name : String, password : String, groups : Array(String) = %w(user))
    user = User.new(name, password, groups).encrypt!
    self.read!
    self.add(user)
    self.save!
    user
  end
end

# file = "/tmp/users"
# File.touch(file)
# include Wikicr
# users = Users.new(file)
# users.read!
# pp users
# user = User.new("arthur", "passwd", %w(admin,user)).encrypt
# users.add user
# users.save!
# p users
# pp Crypto::Bcrypt::Password.new(user.password) == "passwd"
# pp users.auth?("arthur", "passwd")
# pp users.auth?("arthur", "passwdx")
# pp users.auth?("arthurx", "passwd") # raise here
