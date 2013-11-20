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
  attr_accessible :deadline, :goal, :pledged_total
  has_many :payments
  belongs_to :grant
end
