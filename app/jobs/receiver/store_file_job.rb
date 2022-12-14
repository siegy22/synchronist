module Receiver
  class StoreFileJob < ApplicationJob
    def perform(file_path)
      storage_folder = Config.get!(:receiver_storage_folder)
      unless File.directory?(storage_folder)
        return Rails.logger.warn("Storage folder is not a valid directory, please check your configuration")
      end

      unless File.file?(Config.get!(:receiver_receive_folder).join(file_path))
        return Rails.logger.info("File #{file_path} gone, assume it's already copied")
      end

      if Config.relay?
        `rsync -Rt #{File.join(Config.get!(:receiver_receive_folder), "/")}.#{File.join("/", file_path)} #{Config.get!(:receiver_relay_folder)}`
      end

      `rsync -Rt --remove-source-files #{File.join(Config.get!(:receiver_receive_folder), "/")}.#{File.join("/", file_path)} #{storage_folder}`
      ReceivedFile.create!(path: file_path, size: File.size(Config.get!(:receiver_storage_folder).join(file_path)))
    end
  end
end
