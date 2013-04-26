class BizCompany < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  validates_presence_of :company_name
  validates_presence_of :title
  validates_presence_of :phone
  validates_presence_of :manager
end
