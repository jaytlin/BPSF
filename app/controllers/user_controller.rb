# Handles showing and updating users
class UserController < ApplicationController
  load_and_authorize_resource

  def show
    @user = User.find params[:id]
    @payments = @user.payments.includes(:crowdfund)
    @payments = @payments.paginate :page => params[:page], :per_page => 6
    @profile = @user.profile
  end

  def edit
    @user = User.find params[:id]
    @payments = Payment.find_by_user_id @user
    @profile = @user.profile
  end

  def update
    if @user.update_attributes params[:user]
      flash[:success] = 'Profile updated!'
      if params[:stripe_token]
        create_customer!
      end
      redirect_to user_path @user
    else
      if params[:stripe_token]
        create_customer!
      end
      render 'edit'
    end
  end

  def approve
    user = User.find params[:id]
    user.approved = true
    @pending_users = User.where approved: false
    if user.save!
      flash[:success] = "#{user.name} Approved!"
      ApproveAdminJob.new.async.perform(user)
    end
    respond_to do |format|
      format.html { redirect_to admin_dashboard_path }
      format.js { render "update_pending_users" }
    end
  end

  def reject
    user = User.find params[:id]
    user.destroy
    @pending_users = User.where approved: false
    flash[:success] = 'User rejected.'
    respond_to do |format|
      format.html { redirect_to admin_dashboard_path }
      format.js
      format.html { redirect_to admin_dashboard_path }
      format.js { render "update_pending_users" }
    end
  end

  def credit_card
    if current_user.default_card
      @card_number = "XXXX XXXX XXXX #{current_user.last4}"
      @year = current_user.default_card.exp_year
      @month = current_user.default_card.exp_month
    end
  end

  private
  def create_customer!
    customer = Stripe::Customer.create email: current_user.email,
                                       card: params[:stripe_token],
                                       description: "Donor"
    current_user.stripe_token = customer.id
    current_user.save!
  end

  def use_https?
    true
  end
end
