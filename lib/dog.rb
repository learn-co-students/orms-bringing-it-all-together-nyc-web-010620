require "pry"

class Dog

    attr_accessor :id, :name, :breed

    def initialize(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
        @breed = attributes[:breed]
    end 

    def self.create_table 
        sql = <<-SQL 
            CREATE TABLE dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table 
        sql = <<-SQL 
           DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end 

    def save
        if self.id 
            self.update
        else 
            sql = <<-SQL 
                INSERT INTO dogs(name,breed) VALUES (?,?)
            SQL
            DB[:conn].execute(sql,self.name,self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        return self  
    end 

    def update 
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed,self.id)
    end 

    def self.create(hash)
        d1 = Dog.new(hash)
        d1.save 
        d1
    end 

    def self.new_from_db(row)
        attributes = {id: row[0], name: row[1], breed: row[2]}
        Dog.new(attributes)
    end 

    def self.find_by_id(id)
        sql = <<-SQL 
            SELECT * FROM dogs WHERE id = ? 
        SQL
        d1 = DB[:conn].execute(sql, id)[0]
        self.new_from_db(d1)
    end 

    def self.find_or_create_by(dog_hash)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
            LIMIT 1
        SQL
        
        d1 = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])[0]
        
        if d1 == nil || d1.empty?
          self.create(dog_hash)
        else
          self.new_from_db(d1)
        end
    end 

    def self.find_by_name(name) 
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
        d1 = DB[:conn].execute(sql,name)[0]
        self.new_from_db(d1)
    end
end 