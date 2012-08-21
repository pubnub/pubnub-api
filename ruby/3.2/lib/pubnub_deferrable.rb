class PubnubDeferrable < EM::Protocols::HttpClient2

  include EM::Deferrable

  attr_accessor :start_time, :end_time, :elapsed_time

  def connection_completed
    @start_time = Time.now
    puts("\n--- #{@start_time}: Connected.")
    super
  end

  def unbind
    @end_time = Time.now
    puts("-- #{@end_time}: Disconnected.")
    puts("--- Elapsed connection time: #{@end_time - @start_time}s")
    super
  end


end