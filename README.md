# Recordify: Object-Relational Mapping
Recordify is a light ORM inspired by ActiveRecord. It provides a base class `SQLObject` that, when extended, sets up a mapping between the model class and an existing table in a SQLite3 database. 
Recordify uses names to automate mapping tables to classes and table columns to class attributes. Table names can be overwrittenwith custom names using `table_name=`.
* Automated mapping between classes and tables, attributes and columns
```
class Cat < SQLObject
end
```
The table might look like this:
```
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER
  FOREIGN KEY(owner_id) REFERENCES human(id)
)
```
This would define the accessors `Cat#name` and `Cat#name=`.

Attributes can be populated either at initialization 
```
Cat.new(name: "Mittens").save
```
or after
```
c = Cat.new
c.name = "Mittens"
c.save
```

* Associations

Recordify provides associations between objects through simple class methods. 
```
  class Cat < SQLObject
    belongs_to :human, foreign_key: :owner_id
  end
```

```
  class Human < SQLObject
    has_many :cats, foreign_key: :owner_id
  end
 ```   
Simply run `Human#cats` or `Cat#human` to retrieve the associated objects.

Through associations combine two `belongs_to` associations.
```
  class House < SQLObject
    has_many :humans
  end
  class Human < SQLObject
    has_many :cats, foreign_key: :owner_id
    belongs_to :house
  end
  class Cat < SQLObject
    belongs_to :human, foreign_key: :owner_id
    belongs_to :house, through: :human
  end
```

* Validations
Recordify offers presence, inclusion, length, and uniqueness validations at the model level so faulty data is not propagated to the database.

```
class Cat < SQLObject
  validates :name, presence: true
end

Cat.new.save # throws a ValidationError and does not save
```

```
class Cat < SQLObject
  validates :name, uniqueness: true
end
```

Inclusion and length validations takes an option hash:
```
class Cat < SQLObject
  validates :name, inclusion: { in: %w(Fluffy Whiskers Mittens) }
end
```
Length validations have the following options:
  ```
    class Cat < SQLObject
      validates :name, length: {minimum: 6}
    end
  ```
  ```
    class Cat < SQLObject
      validates :name, length: {maximum: 20}
    end
  ```
  ```
    class Cat < SQLObject
      validates :name, length: {in: (5..20)}
    end
  ```
  ```
    class Cat < SQLObject
      validates :name, length: {is: 8}
    end
  ```



