module Receiver
  class Watcher
    def self.start
      Listen.to(Config.get!(:receiver_receive_folder), relative: true) do |modified, added, removed|
        p "New file received #{added.inspect}"
        Receiver::StoreFileJob.perform_later(added) unless added.empty?
      end.start
      puts "Listening on #{Config.get!(:receiver_receive_folder)}"
      sleep
    end
  end
end
