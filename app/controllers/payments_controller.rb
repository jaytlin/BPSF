class PaymentsController < ApplicationController

  def create
    if !anyone_signed_in?
      deny_access
    else
      @payment = current_user.payments.build(:amount => params[:amount])
    end
  end

  def destroy
    Payment.find(params[:id]).destroy
    flash[:success] = "Payment cancelled."
    redirect_to root_url
  end
end
