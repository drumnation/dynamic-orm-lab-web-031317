require_relative "../config/environment.rb"

class InteractiveRecord

  def initialize(options={})
    options.each {|property, value| send("#{property}=", value)}
    # dynamically assign properties
  end

  # class finder methods

  def self.find_by(arg)
    value, column = arg.values.first, arg.keys.first
    sql = "SELECT * FROM #{table_name} WHERE #{column} = '#{value}'"
    DB[:conn].execute(sql)
    # take a has as an argument sets the first value to value, and key to key
    # Select everything from table_name Where the column name matches the value
    # execute sql
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = '#{name}'")
    # selects all from table where name argument matches
  end

  # table related methods

  def self.table_name
    self.to_s.downcase.pluralize
    # convert table name to string, downcase and make plural
    # used in self.column_names method
  end

  def table_name_for_insert
    self.class.table_name
    # points to table name, used in save method
  end

  # column methods

  def self.column_names
    table_info = DB[:conn].execute("PRAGMA table_info(#{table_name})")
    column_names = []
    table_info.each { |col| column_names << col["name"] }
    column_names.compact
    # sql - query table for the names of its columns + execute
    # iterate through column names and add to column_names array
    # return column_names array without nil values (compact)
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    # need .self when calling .class
  end

  # inserting and saving methods

  def values_for_insert
    names = []
    self.class.column_names.each do |col_name|
      names << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    names.join(", ")
    # fills names array with 'send(column)' commands unles nil
    # used in save function
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    # sql insert into table - column names VALUES values_for_insert
    # execute sql
    # set @id to the id the database gave the last row added
  end

end
