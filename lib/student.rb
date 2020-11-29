require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade
  

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  # creates student table within database
  # columns match attributes of individual Student instances
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
      )
    SQL

    DB[:conn].execute(sql)
  end

  # is responsible for dropping the students table from database
  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end


  # instance method that inserts a new row into database using the attributes of the object
  # responsible for assigning 'id' attribute to the object once the row has been inserted/saved into database
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end

  end

  # creates a student with two attributes, name and grade --> #save it into the students table
  def self.create(name, grade)
    song = Student.new(name, grade)
    song.save
    song 
  end

  # updates the record associated with the given instance
  def update
    sql = <<-SQL
      UPDATE students 
      SET name = ?, grade = ? 
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  # takes argument of array 'row'
  # creates new Student instance with attributes returned from row
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  # returns Student instance of first row that meets requirements of databse query
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end


end
