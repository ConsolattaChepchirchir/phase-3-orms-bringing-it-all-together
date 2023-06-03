class Dog
    # has a name and a breed
    # has an id that defaults to `nil` on initialization
    attr_accessor :name, :breed, :id

    def initialize(name:,breed:,id:nil)
        @id=id
        @name=name
        @breed=breed
    end

    # creates the dogs table in the database

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTERGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end
    # drops the dogs table from the database

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    # returns an instance of the dog class
    # saves an instance of the dog class to the database and then sets the given dogs `id` attribute

  def save
        sql= <<-SQL
        INSERT INTO dogs (name,breed) 
        VALUES (?, ?)
        SQL
    # insert the dog

        DB[:conn].execute(sql,self.name, self.breed)

        # get the id from database and asave it to ruby instance

      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        # return ruby instance 

        self
    end
    # create a new dog object 
    # returns a new dog object
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end
#     creates an instance with corresponding attribute values

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed:row[2])
  end
#     returns an array of Dog instances for all records in the dogs table

  def self.all
    sql = <<-SQL
    SELECT * 
    FROM dogs
    SQL

    DB[:conn].execute(sql).map do |row|
        self.new_from_db(row)
  end


end
#     returns an instance of dog that matches the name from the DB

def self.find_by_name(name)
    sql=<<-SQL
    SELECT * 
    FROM dogs
    WHERE dogs.name=?
    LIMIT 1;
    SQL

    DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
    end.first
end

#     returns a new dog object by id

def self.find(id)
    sql = <<-SQL
    SELECT * 
    FROM dogs
    WHERE dogs.id=?
    SQL

    DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
    end.first
end


end