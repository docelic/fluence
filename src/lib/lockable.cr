abstract class Lockable
  abstract def load!
  abstract def save!

  @lock : Mutex = Mutex.new

  def transaction!(read = false, write = true)
    @lock.synchronize do
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
