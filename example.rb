require_relative "lib/sql_object"
require "byebug"

class Composer < SQLObject 
  belongs_to :period
  has_many :works
  finalize!
end

class Work < SQLObject
  belongs_to :composer
  has_one_through :period, :composer, :period
  finalize!
end

class Period < SQLObject
  has_many :composers
  finalize!
end
