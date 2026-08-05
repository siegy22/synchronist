module Sender
  class Watcher
    def self.start
      Listen.to(Config.get!(:sender_payload_path)) do |added, modified|
        Sender::ProcessPayloadJob.perform_later(
          Sender::Payload.receive!((added + modified).uniq.first),
          Config.get!(:sender_source_folder).to_s,
          Config.get!(:sender_send_folder).to_s,
        )
      end.start
      sleep
    end
  end
end
