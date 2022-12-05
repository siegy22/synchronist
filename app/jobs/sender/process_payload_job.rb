module Sender
  # Puts all the missing and/or outdated files into the send folder.
  # E.g. if the payload says the following:
  #
  # <storage>/foo
  # └── 1.txt
  #
  # But the source currently is:
  # <source>/foo
  # ├── 1.txt
  # └── 2.txt
  #
  # It will put the difference into the send folder:
  #
  # <send>/foo
  # └── 2.txt
  class ProcessPayloadJob < ApplicationJob
    queue_as :default

    PAYLOAD_LOAD_PROGRESS = 10.0
    DIFF_PROGRESS = 40.0
    COPYING_PROGRESS = 50.0

    def perform(payload_io, source_path, target_path, sync = Sync.create)
      sync.start

      payload = Payload.load(payload_io)
      sync.increment(:progress, PAYLOAD_LOAD_PROGRESS)

      Dir.chdir(source_path) do
        source_files = Dir.glob("**/*").select(&File.method(:file?))
        source_files_count = source_files.count
        files_to_copy = source_files.each_with_object([]) do |file, memo|
          sync.increment(:progress, (1.0 / source_files_count * DIFF_PROGRESS))
          memo << file unless payload.include?([file, File.mtime(file).utc.to_s])
          memo
        end

        files_to_copy_count = files_to_copy.count
        files_to_copy.each do |file|
          `rsync -Rt #{file} #{target_path}`
          sync.increment(:bytes_transferred, File.size(file))

          sync.increment(:progress, (1.0 / files_to_copy_count * COPYING_PROGRESS))
        end
      end

      sync.finish
    end
  end
end
