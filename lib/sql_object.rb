require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
require_relative 'validation'
require_relative 'searchable'
require_relative 'associatable'
require_relative 'exceptions'

class SQLObject
  extend Validatable
  extend Searchable
  extend Associatable

  
  def self.columns
    @cols ||= DBConnection.execute2(<<-SQL)
      select * from #{table_name}
    SQL
      .first.map(&:to_sym)


  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) { self.attributes[col] }
      define_method("#{col}=") { |new_val| self.attributes[col] = new_val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      select * from #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |datum| self.new(datum) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id: id)
      select * from #{table_name}
      where id = :id
    SQL
    result.empty? ? nil : self.new(result.first)
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=", val)
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    col_names = self.class.columns.reject { |col| col == :id }.join(",")
    question_marks = (["?"] * col_names.split(",").size).join(",")
    values = attribute_values
    DBConnection.execute(<<-SQL, *values)
      insert into #{self.class.table_name}
        (#{col_names})
      values (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.reject { |col| col == :id }.map do |col|
      "#{col} = ?"
    end.join(",")
    values = attribute_values[1..-1]
    DBConnection.execute(<<-SQL, *values, id)
      update #{self.class.table_name}
      set #{set_line}
      where id = ?
    SQL
  end

  def save
    if self.class.validations
      self.class.validations.each do |validation|
        self.send("validate_#{validation}")
      end
      unless errors.empty?
        errors.each do |col, msgs|
          msgs.each { |msg| puts "#{col} #{msg}" }
        end
        reset_errors
        raise ValidationError.new, "validations failed"
      end
    end
    

    self.id.nil? ? insert : update
  end
end
