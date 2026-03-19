class CorrectionMailer < ApplicationMailer
  def notify_editors(correction)
    @correction = correction
    @council = correction.council

    admins = User.where(admin: true).pluck(:email_address)
    recipients = if @council
      editors = @council.users.where(admin: false).pluck(:email_address)
      (editors + admins).uniq
    else
      admins
    end

    return if recipients.empty?

    council_label = @council ? " for #{@council.name}" : ""
    correction_subject = @correction.subject.presence || "New correction"
    mail(to: recipients, subject: "#{correction_subject}#{council_label}")
  end
end
