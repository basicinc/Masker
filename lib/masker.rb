require 'yaml'
require 'ffaker'
require 'mongo'

class Masker
  def initialize(config = nil)
    configure config unless config.nil?
  end

  def db
    @db ||= Mongo::Client.new(@config['db_url'] || 'mongodb://mongodb:27017/development')
  end

  def mask(config = nil)
    configure config unless config.nil?
    raise 'Please provide mask' if @config.nil?

    track_time do
      @config['models'].each do |model|
        mask_document model
      end
      puts 'Done!' unless @config['silent']
    end
  end

  def configure(config)
    @config = config.is_a?(String) ? load_from_yaml(config) : config
  end

  private

  def track_time
    start_at = Time.now
    yield
    finish_at = Time.now
    puts "Elapsed time: #{format_time_diff(start_at, finish_at)}" unless @config['silent']
  end

  def format_time_diff(start_at, finish_at)
    output = Time.at(finish_at - start_at).strftime '%H hours %M minutes %S seconds'
    output.gsub(/^0+ hours /, '').gsub(/^0+ minutes /, '')
  end

  def mask_document(model)
    scope = prepair_scope model

    if model['delete']
      delete_documents scope, model
    else
      mask_each_document scope, model
    end
  rescue StandardError => e
    puts "\nCan't mask #{model['name']}" unless @config['silent']
    raise e
  ensure
    puts '' unless @config['silent']
  end

  def delete_documents(scope, model)
    puts "Deleting #{model['name']}"
    scope.delete_many
  end

  def mask_each_document(scope, model)
    total = scope.count()

    scope.each_with_index do |document, index|
      print "Masking #{model['name']} (#{index + 1}/#{total})\r" unless @config['silent']
      mask = create_mask model['fields']

      document.update(mask)
    end
  end

  def prepair_scope(model)
    scope = db[model['name']]
    scope.find(model['condition'] || {})
  end

  def parse_condition condition
    return nil if condition.nil?

    condition.each do |op, value|
      if value.is_a?(String) && value.match?(/^BSON::ObjectId('[A-Za-z0-9]+')$/)
        condition[op] = eval(value)
      elsif value.is_a?(Hash)
        condition[op] = parse_condition value
      end
    end
    condition
  end

  def create_mask(fields)
    mask = {}
    fields.each do |field, value|
      if value.is_a?(Symbol)
        sub_mask = create_mask @config['models'].find{|model| model['name'] == value.to_s}['fields']
        mask[field] = sub_mask
        next
      end

      mask[field] = evalute_field_value(value)
    end
    mask
  end

  def apply_mask(document, mask)
    mask.reject do |field, _value|
      document[field].nil?
    end
  end

  def evalute_field_value(value)
    eval(value)
  rescue StandardError
    raise "Can't eval `#{value}`"
  end

  def load_from_yaml(config_path)
    YAML.load_file config_path
  end
end
