# == Schema Information
#
# Table name: user_profiles
#
#  id           :integer          not null, primary key
#  address      :text
#  city         :text
#  zipcode      :integer
#  phone        :text
#  relationship :text
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class UserProfile < ActiveRecord::Base
  RELATIONSHIPS = ['Parent of Student','Parent of Alum', 'Alum',
                   'Grandparent of Student', 'Grandparent of Alum']
  attr_accessible :address, :city, :zipcode, :phone, :relationship, :user_id

  belongs_to :user

  before_save :format_phone_numbers

  extend Enumerize
  enumerize :relationship, in: RELATIONSHIPS

  private
    def format_phone_numbers
      self.work_phone = number_to_phone(self.work_phone, area_code: true)
      self.home_phone = number_to_phone(self.home_phone, area_code: true)
    end
end
