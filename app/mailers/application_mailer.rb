class ApplicationMailer < ActionMailer::Base
  default from: 'gamma@rism.info'#"#{RISM::DEFAULT_EMAIL_NAME} <#{RISM::DEFAULT_NOREPLY_EMAIL}>"
  layout 'mailer'
end
