Rails.application.config.filter_parameters += %w[
  passw secret token _key crypt salt certificate otp ssn
]
