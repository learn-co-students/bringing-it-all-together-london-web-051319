class Dog
  include Helper
  def self.create_table
    "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)".weee!
  end

  def self.drop_table
    "DROP TABLE dogs".weee!
  end

  def save
    "INSERT INTO dogs (name, breed) VALUES (?,?)".weee!(@name, @breed)
    @id = "SELECT last_insert_rowid() FROM dogs".weee![0][0]
    self
  end

  def self.create(*hash)
    new(*hash).save
  end

  def self.find_by_id(id)
    id, name, breed = "SELECT * FROM dogs WHERE id = ?".weee!(id)[0]
    new(id: id, name: name, breed: breed) if !id.nil?
  end

  def self.find_or_create_by(name:, breed: )
    id, name, breed =  "SELECT * FROM dogs WHERE name = ? AND breed = ?".weee!(name, breed)[0]
    id.nil? ? create(name: name, breed: breed) : find_by_id(id)
  end

  def self.new_from_db(row)
    id, name, breed = row
    create(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    id, name, breed = "SELECT * FROM dogs WHERE name = ?".weee!(name)[0]
    new(id: id, name: name, breed: breed)
  end

  def update
    "UPDATE dogs SET name = ?, breed = ? WHERE id = ?".weee!(@name, @breed, @id)
  end

end
