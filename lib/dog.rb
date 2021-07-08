require "pry"
class Dog
  def initialize(hash)
    hash.each {|k,v| instance_variable_set("@#{k}", v)}
  end

  attr_accessor :id, :name, :breed

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]

    Dog.new({id: self.id, name: self.name, breed: self.breed})
  end

  def self.create(hash)
    doge = Dog.new(hash)
    doge.save
  end

  def self.find_by_id(num)
    sql = "SELECT * FROM dogs WHERE id = ?"

    arr = DB[:conn].execute(sql, num).flatten
    Dog.new(id: arr[0], name: arr[1], breed: arr[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    arr = DB[:conn].execute(sql, name, breed).flatten

    dog = arr
    if !arr.empty?
      dog = Dog.new(id: arr[0], name: arr[1], breed: arr[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"

    arr = DB[:conn].execute(sql, name).flatten
    Dog.new(id: arr[0], name: arr[1], breed: arr[2])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
