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

    subject = @council ? "New correction for #{@council.name}" : "New correction submitted"
    mail(to: recipients, subject: subject)
  end
end
