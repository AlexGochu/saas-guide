class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :async

  validate :email_is_unique, on: :create
  after_create :create_account

  #def confirmation_required?
  #  false
  #end

  private
  # Email should be unique in Account model
  def email_is_unique
    #don't validate email if any error present
    return false unless self.errors[:email].empty?
    unless Account.find_by_email(email).nil?
      errors.add(:email, " is already used")
    end
  end

  def create_account
    account = Account.new(email: email)
    account.save!
  end
  
  # def send_devise_notification(notification, *args)
  #   devise_mailer.send(notification, self, *args).deliver_later
  # end

end

