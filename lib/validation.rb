# require_relative '04_associatable'
require 'byebug'
require_relative 'sql_object'

module Validatable
  attr_reader :validations
  
  def self.presence_pred(result, options={}, _)
    (result.nil? || result.empty?) ? "must be present" : nil
  end

  def self.length_pred(result, options, _)
    invalid = false
    message = ""
    if options.key?(:minimum) 
      invalid = result.length < options[:minimum]
      message = "too short (min #{options[:minimum]})"
    end
    if options.key?(:maximum)
      invalid = result.length > options[:maximum]
      message = "too long (max #{options[:maximum]})"
      
    end
    if options.key?(:in)
      invalid = !options[:in].include?(result.length)
      message = "must be in range #{options[:in]}"
    end
    if options.key?(:is)
      invalid = result.length != options[:is]
      message = "must have length #{options[:is]}"
    end
    invalid ? message : nil
  end

  def self.inclusion_pred(result, options, _)
    options[:in].include?(result) ? nil : "must be one of #{options[:in].join(",")}"
  end

  def self.unique_pred(result, options, pred_opts) 
    pred_opts[:class].where(pred_opts[:col] => result).empty? ? nil : "must be unique"
  end

  def validates(*cols, **options)
    validation_predicates = {
      presence: :presence_pred,
      length: :length_pred,
      inclusion: :inclusion_pred,
      uniqueness: :unique_pred
    }
  
    #instance methods, holds all the validation failures for that instance/resets them
    define_method(:errors) { @errors ||= Hash.new { |h, k| h[k] = [] } }
    define_method(:reset_errors) { @errors = Hash.new { |h, k| h[k] = [] }}
    @validations = options.keys
    options.each do |validation, opts|
      predicate = validation_predicates[validation]
      define_method("validate_#{validation}") do
        cols.each do |col|
          
          message = Validatable.send(predicate, self.send(col), options[validation], {col: col, class: self.class})
          if message 
            self.send(:errors)[col] << message
          end
         end
        end
    
      end
    end






end
