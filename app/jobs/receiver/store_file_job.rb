module Receiver
  class StoreFileJob < ApplicationJob
    def perform(paths)
      unless File.directory?(storage_folder)
        return Rails.logger.warn("Storage folder is not a valid directory, please check your configuration")
      end

      paths.each do |file_path|
        relative_path, file_size = store_file(file_path)
        ReceivedFile.create!(path: relative_path, size: file_size)
      end
    end

    def store_file(file_path)
      unless File.file?(file_path)
        Rails.logger.info("File #{file_path} gone, assume it's already copied")
        return
      end

      file_size = File.size(file_path)

      # When using rsync to preserve the pathname when storing (or relaying) it, there's a method
      # using the following command: rsync -Rt /tmp/receive/./foo/bar.txt /tmp/storage
      # This properly creates the foo/bar.txt in the storage folder.
      rsync_relative_path = file_path.gsub(receive_folder, "#{receive_folder}./")

      `rsync -Rt #{rsync_relative_path} #{Config.get!(:receiver_relay_folder)}` if Config.relay?

      `rsync -Rt --remove-source-files #{rsync_relative_path} #{storage_folder}`

      [file_path.gsub(receive_folder, ''), file_size]
    end

    def receive_folder
      File.join(Config.get!(:receiver_receive_folder).to_s, '')
    end

    def storage_folder
      Config.get!(:receiver_storage_folder)
    end
  end
end
