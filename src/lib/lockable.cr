abstract class Lockable
  abstract def load!
  abstract def save!

  @lock : Mutex?

  def initialize
    @lock = Mutex.new
  end

  def transaction!(read = false, write = true)
    @lock ||= Mutex.new
    @lock.as(Mutex).synchronize do
      begin
        self.load! if read == true
        yield self
      ensure
        self.save! if write == true
        return self
      end
    end
  end
end
