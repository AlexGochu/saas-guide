if Rails.env.development?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
      address: 'smtp.gmail.com',
      port: 587,
      domain: 'saas-guide-gochu.herokuapp.com',
      user_name: 'gochualex@gmail.com',
      password: '321Kirgiz123',
      authentication: 'plain',
      enable_starttls_auto: true}
elsif Rails.env.production?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
      address: 'smtp.sendgrid.net',
      port: 587,
      domain: 'herokuapp.com',
      user_name: ENV['SENDGRID_USERNAME'],
      password: ENV['SENDGRID_PASSWORD'],
      authentication: 'plain',
      enable_starttls_auto: true}
end




