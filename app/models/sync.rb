class Sync < ApplicationRecord
  after_update_commit -> { broadcast_replace_later_to "list_progress_#{id}", partial: "syncs/list_progress", target: "list_progress_#{id}" }
  after_update_commit -> { broadcast_replace_later_to "list_files_and_bytes_#{id}", partial: "syncs/list_files_and_bytes", target: "list_files_and_bytes_#{id}" }
  after_update_commit -> { broadcast_replace_later_to "detail_progress_#{id}", partial: "syncs/detail_progress", target: "detail_progress_#{id}" }
  after_update_commit -> { broadcast_replace_later_to "detail_files_and_bytes_#{id}", partial: "syncs/detail_files_and_bytes", target: "detail_files_and_bytes_#{id}" }
  broadcasts inserts_by: :prepend

  has_many :sent_files
  belongs_to :sender_payload, class_name: "Sender::Payload"

  scope :ordered, -> { order(created_at: :desc) }

  def start!
    update(started_at: Time.now)
  end

  def finish!
    update(finished_at: Time.now)
  end

  def errored?
    errored_at
  end

  def running?
    started_at && finished_at.blank? && errored_at.blank?
  end

  def succeeded?
    finished_at && errored_at.blank?
  end

  def finished?
    finished_at || errored_at
  end

  def duration
    return 0 if !started_at || !finished_at

    finished_at - started_at
  end
end
