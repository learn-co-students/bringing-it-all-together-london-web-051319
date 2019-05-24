require 'sqlite3'
require_relative '../lib/helper'
require_relative '../lib/dog'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}


class String
  def weee!(*args)
    DB[:conn].execute(self, *args)
  end
end

class Array
  def has?
    !self.empty?
  end
end
