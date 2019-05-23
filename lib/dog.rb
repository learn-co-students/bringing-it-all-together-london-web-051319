class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?;
  SQL

  DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES(?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").first[0]
    self
  end

  def self.create(attr = {})
    dog = Dog.new(attr)
    dog.save
    dog
  end

  def self.find_or_create_by(attr={})
    sql = <<-SQL
      SELECT * 
      FROM dogs 
      WHERE name = ? AND breed = ?;
    SQL
    
    dog = DB[:conn].execute(sql, attr[:name], attr[:breed]).first
  
    if !dog
      return Dog.create(attr)
    else
      return Dog.new_from_db(dog)
    end
  end

  def self.new_from_db(db_dog)
    Dog.new(id: db_dog[0], name: db_dog[1], breed: db_dog[2])
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", name).first
    Dog.new_from_db(dog)
  end

  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id).first
    Dog.new_from_db(dog)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end
end