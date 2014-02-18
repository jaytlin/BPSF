# == Schema Information
#
# Table name: crowdfunds
#
#  id            :integer          not null, primary key
#  deadline      :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  goal          :integer
#  pledged_total :integer
#  grant_id      :integer
#

class Crowdfund < ActiveRecord::Base
  attr_accessible :goal, :pledged_total, :grant_id
  has_many :payments
  belongs_to :grant

  def progress
    "#{([self.pledged_total/self.goal.to_f, 1].min * 100).to_i}%"
  end

  def add_payment(amount)
    self.pledged_total = self.pledged_total + amount
    self.save!
  end
end
