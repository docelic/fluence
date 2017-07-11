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
        # puts "#{self.inspect} LOAD!"
        self.load!
        yield self
      ensure
        # puts "#{self.inspect} SAVE!"
        self.save!
        return self
      end
    end
  end
end
