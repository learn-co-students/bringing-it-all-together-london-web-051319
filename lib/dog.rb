class Dog
 attr_accessor :name, :breed, :id
 #attr_reader :id
 # has a name and a breed
 #   has an id that defaults to `nil` on initialization
 #   accepts key value pairs as arguments to initialize


 def initialize(name: nil, breed: nil, id: nil)
   @name = name
   @breed = breed
   @id = id
 end

 def self.create_table
   DB[:conn].execute("
   create table if not exists dogs(id integer primary key,
                                   name text,
                                   breed, text);
   ")
 end
 # creates the dogs table in the database

 def self.drop_table
   DB[:conn].execute("drop table dogs;")
 end
# drops the dogs table from the database


 def self.find_by_id(id)
   row = DB[:conn].execute("select * from dogs where id = ?;", id)[0]
   dog = self.new_from_db(row)
 end
# returns a new dog object by id

 def save
   if @id
     update
   else
     DB[:conn].execute("""
       insert into dogs (name, breed) values (?, ?)
     """, @name, @breed)
     @id = DB[:conn].execute("select last_insert_rowid() from dogs;")[0][0]
   end
   self
 end
#  returns an instance of the dog class
# saves an instance of the dog class to the database and then sets the given dogs `id` attribute



 def self.create(name:, breed:)
   dog = Dog.new
   dog.name = name
   dog.breed = breed
   dog.save
   dog
 end
 # takes in a hash of attributes and uses metaprogramming to create a new dog object.
 # Then it uses the #save method to save that dog to the database
 #    returns a new dog object


 def self.find_or_create_by(name:, breed:)
   row = DB[:conn].execute("select * from dogs where name = ? and breed = ?;", name, breed)
   if !row.empty?
     data = row[0]
     dog = self.new_from_db(data)
   else
     dog = self.create(name: name, breed: breed)
   end
   dog
 end
 # creates an instance of a dog if it does not already exist
 #   when two dogs have the same name and different breed, it returns the correct dog
 #   when creating a new dog with the same name as persisted dogs, it returns the correct dog



 def self.new_from_db(row)
   dog = self.new
   dog.name = row[1]
   dog.breed = row[2]
   dog.id = row[0]
   dog
 end
# creates an instance with corresponding attribute values


 def self.find_by_name(name)
   row = DB[:conn].execute("select * from dogs where name = ?;", name)[0]
   dog = self.new_from_db(row)
 end
# returns an instance of dog that matches the name from the DB


 def update
   DB[:conn].execute("update dogs set name = ?, breed = ?;", @name, @breed)
 end
# updates the record associated with a given instance


end
