abstract class Lockable
  abstract def load!
  abstract def save!

  @lock : Mutex?

  def initialize
    @lock = Mutex.new
  end

  def transaction!
    @lock ||= Mutex.new
    @lock.as(Mutex).synchronize do
      begin
        self.load!
        yield self
      ensure
        self.save!
        return self
      end
    end
  end
end
