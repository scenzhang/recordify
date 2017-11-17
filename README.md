# Recordify: Object-Relational Mapping
Recordify is a light ORM inspired by ActiveRecord. It provides a base class `SQLObject` that, when extended, sets up a mapping between the model class and an existing table in a SQLite3 database. 
Recordify uses names to automate mapping tables to classes and table columns to class attributes. Table names can be overwrittenwith custom names using `table_name=`.

Edit config.json to specify the SQL file to populate the database, and the db file to save the database to.

To run the example, open a Ruby console and `load lib/sql_object.rb`, then `load composer_example.rb`. 
* Automated mapping between classes and tables, attributes and columns
```
class Composer < SQLObject
end
```
The table might look like this:
```
CREATE TABLE Composers (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  period_id INTEGER
  FOREIGN KEY(owner_id) REFERENCES human(id)
)
```
This would define the accessors `Composer#name`, `Composer#name=`, `Composer#period_id`, and `Composer#period_id=`.

Attributes can be populated either at initialization 
```
Composer.new(name: "Johann Sebastian Bach").save
```
or after
```
c = Composer.new
c.name = "Maurice Ravel"
c.save
```

* Associations

Recordify provides associations between objects through simple class methods. 
```
  class Composer < SQLObject
    belongs_to :period, foreign_key: :period_id
  end
```

```
  class Composer < SQLObject
    has_many :works, foreign_key: :composer_id
  end
 ```   
Simply run `Composer#works` or `Work#composer` to retrieve the associated objects.

Through associations combine two `belongs_to` associations.
```
  class Period < SQLObject
    has_many :composers
  end
  class Composer < SQLObject
    has_many :works, foreign_key: :composer_id
    belongs_to :period
  end
  class Work < SQLObject
    belongs_to :composer
    #usage: has_one_through :name_of_association, :through_class, :source_association
    has_one_through :period, :composer, :period 
  end
```

Then `Work#period` will return the corresponding `Period` object associated with that `Work`'s `Composer`.

* Accessing Data

`SQLObject#all` returns a collection of SQLObjects for each row in the corresponding table.

`SQLObject#where` takes either a hash argument of `{attribute: value}` or a string of raw SQL, and returns a collection of SQLObjects with attributes matching the values.

`Composer.where(name: "Johann Sebastian Bach")` or `Composer.where("name='Johann Sebastian Bach'")` produce the same result.




* Validations

Recordify offers presence, inclusion, length, and uniqueness validations at the model level so faulty data is not propagated to the database.

```
class Composer < SQLObject
  validates :name, presence: true
end

Composer.new.save # throws a ValidationError since name was not provided and does not save
```

```
class Composer < SQLObject
  validates :name, uniqueness: true
end

Composer.new(name: "Bela Bartok").save #saves successfully
Composer.new(name: "Bela Bartok").save #fails uniqueness validation and throws ValidationError.
```

Inclusion and length validations takes an option hash:
```
class Period < SQLObject
  validates :name, inclusion: { in: %w(Baroque Classical Romantic Modern) }
end

Period.new(name: "Baroque").save #saves successfully
Period.new(name: "Rock").save # fails inclusion validation and throws ValidationError
```
Length validations have the following options:
  ```
    class Composer < SQLObject
      validates :name, length: {minimum: 6}
    end
  ```
  ```
    class Composer < SQLObject
      validates :name, length: {maximum: 20}
    end
  ```
  ```
    class Composer < SQLObject
      validates :name, length: {in: (5..20)}
    end
  ```
  ```
    class Composer < SQLObject
      validates :name, length: {is: 8}
    end
  ```



