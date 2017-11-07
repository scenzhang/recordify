require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || name.capitalize.to_s
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] ||  "#{self_class_name.downcase}_id".to_sym
    @class_name = options[:class_name] || name.to_s.singularize.capitalize
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name.to_sym) do
      fk_val = self.send(options.foreign_key)
      target_class = options.model_class
      target_class.where(options.primary_key => fk_val).first
    end
    assoc_options[name] = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name.to_sym) do
      fk_val = self.send(options.primary_key)
      target_class = options.model_class
      target_class.where(options.foreign_key => fk_val)
    end
  end

  def assoc_options
    @options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      thru_opts = self.class.assoc_options[through_name]
      src_opts = thru_opts.model_class.assoc_options[source_name]
      thru_tbl = thru_opts.table_name
      src_tbl = src_opts.table_name
      results = DBConnection.execute(<<-SQL)
        select #{src_tbl}.*
        from #{thru_tbl}
        join #{src_tbl}
        on #{thru_tbl}.#{src_opts.foreign_key} = #{src_tbl}.#{src_opts.primary_key}
        where #{thru_tbl}.#{thru_opts.primary_key} = #{self.send(thru_opts.foreign_key)}
      SQL
      src_opts.model_class.parse_all(results).first
    end
  end

end
