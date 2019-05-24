module Helper
  # def self.included(klass)
  #   klass.instance_variable_set(:@all, [])
  #   klass.singleton_class.class_eval{attr_reader(:all)}
  # end

  def initialize(**hash)
    hash[:id] ||= nil
    hash.each do |var, value|
      instance_variable_set("@#{var}", value)
      self.class.class_eval{attr_accessor(var)}
    end

    # self.class.all << self
  end
end
