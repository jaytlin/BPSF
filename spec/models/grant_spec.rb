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
#  image_url          :string(255)
#  school_id          :integer
#  rating_average     :decimal(6, 2)    default(0.0)
#

require "spec_helper"

describe Grant do
  it "is pending after creation" do
    grant = FactoryGirl.create :grant
    grant.should be_pending
  end

  it "cannot be funded after rejection" do
    grant = FactoryGirl.create :grant
    grant.reject
    grant.fund
    grant.should be_rejected
  end

  it "cannot be rejected if it is crowdfunding" do
    grant = FactoryGirl.create :grant
    grant.crowdfund
    grant.reject
    grant.should be_crowdfunding
  end

  it "can be funded if it failed crowdfunding" do
    grant = FactoryGirl.create :grant
    grant.crowdfund
    grant.crowdfunding_failed
    grant.fund
    grant.should be_complete
  end
end
