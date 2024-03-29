module Sender
  class Payload < ApplicationRecord
    self.table_name_prefix = "sender_"

    has_one :sync
    has_one_attached :file
    broadcasts inserts_by: :prepend

    validates :uid, :received_at, :mtime, presence: true

    scope :ordered, -> { order(received_at: :desc) }

    def self.receive!(path)
      uid = Marshal.load(File.read(path))[:uid]
      created = create!(received_at: Time.now, mtime: File.mtime(path), uid: uid)
      created.file.attach(io: File.open(path), filename: File.basename(path))
      Sync.create!(sender_payload: created)
    end

    def load
      Marshal.load(self.file.download)
    end
  end
end
