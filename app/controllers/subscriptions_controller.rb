class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @account = Account.find_by_email(current_user.email)
  end

  def new
    @plans = Plan.all.order(:id)
  end

  def edit
    @account = Account.find(params[:id])
    @plans = Plan.all.order(:id)
  end

  def create
    #byebug
    #ap "Inside create in subscription. See params hash"
    #ap params
    token = params[:stripeToken]
    plan = params[:plan][:stripe_id]
    email = current_user ? current_user.email : "a1@test.com"
    current_account = Account.find_by_email(current_user.email)
    customer_id = current_account.customer_id
    current_plan = current_account.stripe_plan_id

    if customer_id.nil?
      #new customer -> Create customer
      @customer = Stripe::Customer.create(
          :source => token,
          :plan => plan,
          :email => email
      )
      subscriptions = @customer.subscriptions
      @subscribed_plan = subscriptions.data.find {|o| o.plan.id == plan}

    else
      #Customer exists
      #Get customer from Stripe
      @customer = Stripe::Customer.retrieve(customer_id)
      @subscribed_plan = create_or_update_subscription(@customer, current_plan, plan)
    end


    #In unix timestamp
    current_period_end = @subscribed_plan.current_period_end
    #Convert to datetime
    active_until = Time.at(current_period_end).to_datetime


    save_account_details(current_account, plan, @customer.id, active_until)

    redirect_to :root, :notice => "Successfully subscribed to a plan #{current_account.stripe_plan_id}"

  rescue => e
    redirect_to :back, :flash => {:error => e.message}
  end

  def cancel_subscription
    email = current_user.email
    current_account = Account.find_by_email(current_user.email)
    customer_id = current_account.customer_id
    current_plan = current_account.stripe_plan_id

    if current_plan.blank?
      raise "No plans found to unsubscribe/cancel"
    end
    #Fetch customer from stripe
    customer = Stripe::Customer.retrieve(customer_id)
    #Get customer's subscriptions
    subscriptions = customer.subscriptions
    #Find subscription that we want to cancel
    current_subscribed_plan = subscriptions.data.find {|o| o.plan.id == current_plan}
    if current_subscribed_plan.blank?
      raise "Subscription not found!!!"
    end
    #Delete it
    current_subscribed_plan.delete
    #Update account model
    save_account_details(current_account, "", customer_id, Time.at(0).to_datetime)
    @message = "Subscription was canceled successfully"
  rescue => e
    redirect_to "/subscriptions", :flash => {:error => e.message}
  end

  def update_card

  end

  def update_card_details
    #take the token given by stripe and set it on customer
    token = params[:stripeToken]
    #Get customer id current_account = Account.find_by_email(current_user.email)
    current_account = Account.find_by_email(current_user.email)
    customer_id = current_account.customer_id
    #Get customer from stripe
    customer = Stripe::Customer.retrieve(customer_id)
    #set new card token
    customer.source = token
    customer.save

    redirect_to "/subscriptions", :notice => "Card updated successfully"
  rescue => e
    redirect_to :action => "update_card", :flash => { :error => e.message }

  end

  def save_account_details(account, plan, customer_id, active_until)
    #Update account with the details
    account.stripe_plan_id = plan
    account.customer_id = customer_id
    account.active_until = active_until
    account.save!
  end

  def create_or_update_subscription(customer, current_plan, new_plan)
    subscriptions = customer.subscriptions
    #Get subscription
    current_subscription = subscriptions.data.find {|o| o.plan.id == current_plan}
    if current_subscription.blank?
      #No current subscription
      #maybe the customer unsubscribed previously or maybe the card was declined
      #So, create new subscription to existing customer
      subscription = customer.subscriptions.create({:plan => new_plan})
    else
      #existing subscriptionn found
      #must be upgrade pr downgrade
      #So update existing subscription with new plan
      current_subscription.plan = new_plan
      subscription = current_subscription.save
    end
    return subscription
  end
end
