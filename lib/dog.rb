class Dog
    attr_accessor :name, :id
    attr_reader :breed

    def initialize(name:, breed:, id: nil)
        @name, @breed, @id = name, breed, id
    end

    def self.create_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")

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
            DROP TABLE IF EXISTS dogs;
        SQL

        DB[:conn].execute(sql)
    end

    def save 
        if self.id
            self.update
        else
            sql = <<-SQL 
                INSERT INTO dogs(name, breed)
                VALUES(?,?);
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
            Dog.new(name: self.name, breed: self.breed, id: self.id)
        end

        self
    end

    def self.create(attributes)
        dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
        dog.save
    end

    def self.new_from_db(row)
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * 
            FROM dogs 
            WHERE dogs.id = ?;
        SQL

        dog_record = DB[:conn].execute(sql, id)
        Dog.new(name: dog_record[0][1], breed: dog_record[0][2], id: dog_record[0][0])
    end

    def self.find_or_create_by(attributes)
        sql = <<-SQL
            SELECT * FROM dogs WHERE dogs.name = ? AND dogs.breed = ?;
        SQL

        dog_record = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

        if dog_record.empty?
            dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
            return dog.save
        else 
            return Dog.new(name: dog_record[0][1], breed: dog_record[0][2], id: dog_record[0][0])
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE dogs.name = ?;
        SQL

        dog_record = DB[:conn].execute(sql, name)
        Dog.new(name: dog_record[0][1], breed: dog_record[0][2], id: dog_record[0][0])
    end

    def update
       sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
       SQL

       DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end