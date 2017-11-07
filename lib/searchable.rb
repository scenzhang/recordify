require_relative 'db_connection'

module Searchable
  def where(params)
    conditions =
      if params.is_a?(Hash)
        params.map do |k, v|
          if v.is_a?(Fixnum)
            "#{k} = #{v}"
          else
            "#{k} = '#{v}'"
          end
        end.join(' AND ')
      elsif params.is_a?(String)
        params
      else
        raise ArgumentError, "parameters must be either hash or string"
      end

    data = DBConnection.instance.execute(<<-SQL)
        SELECT *
        FROM #{self.table_name}
        WHERE #{conditions}
    SQL
    data.map {|datum| self.new(datum)}
  end

end
