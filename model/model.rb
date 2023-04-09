def use_db_file_hash()
    @db = SQLite3::Database.new("db/main.db")
    @db.results_as_hash = true
end

def use_db_file()
    @db = SQLite3::Database.new("db/main.db")
end

def make_a_question(title)
    use_db_file_hash()
    @db.execute("INSERT INTO question (value_of_question, title) VALUES (0, ?)",title)
end

def make_new_answers(title, id_from_question, false_or_true)
    use_db_file_hash()
    @db.execute("INSERT INTO answer (value_of_answer, title, question_id, false_or_true) VALUES (0, ?, ?, ?)",title,id_from_question,false_or_true)
end

def set_value_for_a_tabels_column(tabel, attribute_for_tabel, value_of_aft)
    use_db_file_hash()
    @db.execute("INSERT INTO #{tabel} (#{attribute_for_tabel}) VALUES (?)",value_of_aft)
end

def set_two_values_for_a_tabels_column(tabel, attribute_for_tabel, attribute_for_tabel_2, value_of_aft, value_of_aft_2)
    use_db_file_hash()
    @db.execute("INSERT INTO #{tabel} (#{attribute_for_tabel}, #{attribute_for_tabel_2}) VALUES (?, ?)",value_of_aft,value_of_aft_2)
end

def add_values_for_a_tabel(tabel, attribute_for_tabel_1, attribute_for_tabel_2, attribute_for_tabel_3, value_of_aft_1, value_of_aft_2, value_of_aft_3)
    use_db_file()
    @db.execute("INSERT INTO #{tabel} (#{attribute_for_tabel_1},#{attribute_for_tabel_2}, #{attribute_for_tabel_3}) VALUES (?,?,?)",value_of_aft_1,value_of_aft_2,value_of_aft_3)
end

=begin def current_question()
    session[:current_question] = 0
    @current_question = session[:current_question]
end 
=end
=begin 
def make_tabels(tabel, attribute_for_tabel_1, attribute_for_tabel_2, attribute_for_tabel_3, value_of_aft_1, value_of_id)
    db = SQLite3::Database.new("db/main.db")
    db.results_as_hash = true
    db.execute("INSERT INTO #{tabel} (value_of_answer, title, question_id) VALUES (0, ?, ?)",value_for_tabel_1, value_of_id)
end 
=end

def make_answers(value_of_titel, value_of_id, false_or_true_value)
    use_db_file_hash()
    @db.execute("INSERT INTO answer (value_of_answer, title, question_id, false_or_true) VALUES (0, ?, ?, ?)",value_of_titel, value_of_id. false_or_true_value)
end 


=begin def take_the_last_question_id()
    db = SQLite3::Database.new("db/main.db")
    db.results_as_hash = true
    all_questions = select_all_from_a_tabel("question")
    p all_questions
    the_last_id_for_a_question = all_questions[-1]['id']
    p the_last_id_for_a_question
    the_new_id_for_the_new_question = the_last_id_for_a_question + 1
    p the_new_id_for_the_new_question
    return the_new_id_for_the_new_question
end
=end
def select_all_from_a_tabel(tabel)
    use_db_file_hash()
    @db.execute("SELECT * FROM #{tabel}")
end

def select_all_from_a_tabel_alfabetic_order(tabel, attribute_for_tabel, how_to_order_by)
    use_db_file_hash()
    @db.execute("SELECT * FROM #{tabel} ORDER BY #{attribute_for_tabel} #{how_to_order_by}")
end

def delete_a_column_for_a_tabel(tabel, attribute_for_tabel, value_of_aft)
    #aft = attribute_for_tabel
    use_db_file()
    @db.execute("DELETE FROM #{tabel} WHERE #{attribute_for_tabel} = ?",value_of_aft)
end

def update_a_column_for_a_tabel(tabel, attribute_for_tabel_1, id_for_column_tabel, value_of_aft_1, value_of_id_for_column_tabel)
    # aft = attribute_for_tabel
    use_db_file()
    @db.execute("UPDATE #{tabel} SET #{attribute_for_tabel_1} = ? WHERE #{id_for_column_tabel} = ?",value_of_aft_1,value_of_id_for_column_tabel) # Jag måste veta hur många attribute_for_tabel och variabel som jag behöver!
end

def select_one_tabel(tabel, attribute_for_tabel, value_of_aft)
    use_db_file_hash()
    @db.execute("SELECT * FROM #{tabel} WHERE #{attribute_for_tabel} = ?", value_of_aft)
end

def select_specifik_question(tabel, id_tabel, titel, tabel_2)
    use_db_file_hash()
    @db.execute("SELECT * FROM #{tabel} WHERE #{id_tabel} = ?",@id).first
    @db.execute("SELECT #{titel} FROM #{tabel_2} WHERE ArtistId IN (SELECT ArtistId FROM Albums WHERE AlbumId = ?)",id).first
    # Jag vet ej vad jag ska göra med rad 29? Vad borde jag egentligen ha här för att det ska passa databasne som jag gjort med frågor och svar?
end

def select_one_tabel(tabel, id_tabel, variabel)
    use_db_file_hash()
    @db.execute("SELECT * FROM #{tabel} WHERE #{id_tabel} = ?", variabel)
end

def select_all_answers_for_one_question(tabel, condition, condition_value)
    use_db_file_hash()
    @db.execute("SELECT * FROM #{tabel} WHERE #{condition} = ?", condition_value)
end

def get_all_users_from_question(id)
    use_db_file_hash()
    @db.execute("SELECT user.username FROM user INNER JOIN user_question_relation ON user.id = user_question_relation.user_id WHERE user_question_relation.question_id = ?", id)
end