# require_relative '04_associatable'
require 'byebug'

module Validatable

  attr_reader :validations


  def validates(*cols, **options)
    
    #instance methods, holds all the validation failures for that instance/resets them
    define_method(:errors) { @errors ||= Hash.new { |h, k| h[k] = [] } }
    define_method(:reset_errors) { @errors = Hash.new { |h, k| h[k] = [] }}
    @validations = options.keys
    # options.each do |validation, opts|
    #
    #   define_method("validate_#{validation}") do
    #     cols.each do |col|
    #       #if predicate on col is false add appropriate message to errors[col] based on validation
    #     end
    #
    #   end
    # end

    if options[:presence]
      # validations << :presence
      define_method(:validate_presence) do
        cols.each do |col|
          if self.send(col).nil? || self.send(col).empty?
            self.send(:errors)[col] << "must be present"
          end
        end
      end
    end



  end
end
