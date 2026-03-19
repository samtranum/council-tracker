class CorrectionMailer < ApplicationMailer
  def notify_editors(correction)
    @correction = correction
    @council = correction.council

    recipients = if @council
      editors = @council.users.where(admin: false).pluck(:email_address)
      editors.any? ? editors : User.where(admin: true).pluck(:email_address)
    else
      User.where(admin: true).pluck(:email_address)
    end

    return if recipients.empty?

    council_label = @council ? " for #{@council.name}" : ""
    correction_subject = @correction.subject.presence || "New correction"
    mail(to: recipients, subject: "#{correction_subject}#{council_label}")
  end
end
