require_relative "../config/environment.rb"

class Student < InteractiveRecord

  self.column_names.each {|column| attr_accessor column.to_sym }

end
