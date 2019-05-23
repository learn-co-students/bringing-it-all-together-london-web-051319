require "pry"
class Dog

  attr_accessor :id, :name, :breed

  def initialize(data={})
    @name = data[:name]
    @breed = data[:breed]
    @id = data[:id]
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(data={})
    dog = Dog.new(data)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    dog = Dog.new
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    dog
  end

  def self.find_or_create_by(data={})
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", data[:name], data[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new
      dog.id = dog_data[0]
      dog.name = dog_data[1]
      dog.breed = dog_data[2]
    else
      dog = self.create(data)
    end
    dog
  end
end
