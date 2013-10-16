# == Schema Information
#
# Table name: grants
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  title              :text
#  summary            :text
#  subject_areas      :text
#  grade_level        :text
#  duration           :text
#  num_classes        :integer
#  num_students       :integer
#  total_budget       :integer
#  requested_funds    :integer
#  funds_will_pay_for :text
#  budget_desc        :text
#  purpose            :text
#  methods            :text
#  background         :text
#  n_collaborators    :integer
#  collaborators      :text
#  comments           :text
#  recipient_id       :integer
#  state              :string(255)
#  video              :string(255)
#

class Grant < ActiveRecord::Base
  attr_accessible :title, :organization, :sum, :summary, :subject_areas,
                  :grade_level, :duration, :num_classes, :num_students, :total_budget,
                  :requested_funds, :funds_will_pay_for, :budget_desc, :purpose, :methods,
                  :background, :n_collaborators, :collaborators, :comments, :video
  belongs_to :recipient

  scope :pending_grants, -> {with_state(:pending)}
  scope :complete_grants, -> {with_state(:complete)}
  scope :crowdfunding_grants, -> {with_state(:crowdfunding)}

  state_machine initial: :pending do
    event :reject do
      transition [:pending, :crowdfund_pending] => :rejected
    end

    event :reconsider do
      transition [:rejected, :crowdfund_pending, :crowdfunding, :complete] => :pending
    end

    event :fund do
      transition [:pending, :crowdfund_pending, :crowdfunding] => :complete
    end

    event :crowdfund do
      transition :pending => :crowdfunding
    end

    event :crowdfunding_failed do
      transition :crowdfunding => :crowdfund_pending
    end
  end
end
