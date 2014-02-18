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
#  image              :string(255)
#  school_id          :integer
#  rating_average     :decimal(6, 2)    default(0.0)
#  school_name        :string(255)
#  teacher_name       :string(255)
#  type               :string(255)
#

class DraftGrant < Grant
  validates :title, presence: true, length: { maximum: 40 }
  validates :recipient_id, :school_id, presence: true, if: 'type.nil?'
  validates :summary, length: { maximum: 200 }
  validate :grade_format
  validates :purpose, :methods, :background, :comments, length: { maximum: 1200 }
  validates :n_collaborators, allow_blank: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :collaborators, length: { maximum: 1200 },
            if: 'n_collaborators && n_collaborators > 0'

  before_create :set_deadline

  def set_deadline
    self.deadline = Date.today
  end

  def has_collaborators?
    n_collaborators && n_collaborators > 0
  end

  def has_comments?
    comments
  end

  def submit_and_destroy
    if transfer_attributes_to_new_grant
      GrantSubmittedJob.new.async.perform(self)
      admins = Admin.all + SuperUser.all
      admins.each do |admin|
        AdminGrantsubmittedJob.new.async.perform(self, admin)
      end
      destroy
    end
  end

  private
    ATTRS_TO_COPY = ['subject_areas', 'funds_will_pay_for', 'image']
    def transfer_attributes_to_new_grant
      temp = dup.becomes Grant
      ATTRS_TO_COPY.map { |a| temp.send("#{a}=", attributes[a]) }
      temp.type = nil

      if temp.valid? then temp.save else get_errors_and_destroy(temp) end
    end

    def get_errors_and_destroy(temp)
      temp.errors.messages.each { |attr, e| errors.add(attr, e[0]) }
      false
    end
end
