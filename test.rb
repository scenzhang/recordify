require_relative "lib/sql_object"

class Cat < SQLObject 
  validates :name, uniqueness: true
end

Cat.finalize!

c = Cat.new
c.name = "Stray Cat"
c.save