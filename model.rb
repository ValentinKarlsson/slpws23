def make_questions_and_answeres(title, alt_1, alt_2, alt_3)
    db = SQLite3::Database.new("db/main.db")
    db.results_as_hash = true
    db.execute("INSERT INTO question (value_of_question, title) VALUES (0, ?)",title)
    id_new_question = select_all_from_a_tabel("question").last()['id']

    db.execute("INSERT INTO answer (value_of_answer, title, question_id) VALUES (0, ?, ?)",alt_1,id_new_question)
    db.execute("INSERT INTO answer (value_of_answer, title, question_id) VALUES (0, ?, ?)",alt_2,id_new_question)
    db.execute("INSERT INTO answer (value_of_answer, title, question_id) VALUES (0, ?, ?)",alt_3,id_new_question)
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
    db = SQLite3::Database.new("db/main.db")
    db.results_as_hash = true
    db.execute("SELECT * FROM #{tabel}")
end

def delete_a_column_for_a_tabel(tabel, attribute_for_tabel, variabel)
    db = SQLite3::Database.new("db/main.db")
    db.execute("DELETE FROM #{tabel} WHERE #{attribute_for_tabel} = ?",variabel)
end

def update_a_column_for_a_tabel(tabel, attribute_for_tabel, id_for_column_tabel, variabel)
    db = SQLite3::Database.new("db/main.db")
    db.execute("UPDATE #{tabel} SET #{attribute_for_tabel}=?,#{attribute_for_tabel}=? WHERE #{id_for_column_tabel} = ?",variabel,variabel,variabel) # Jag måste veta hur många attribute_for_tabel och variabel som jag behöver!
end

def select_specifik_question(tabel, id_tabel, titel, tabel_2)
    db = SQLite3::Database.new("db/main.db")
    db.results_as_hash = true
    db.execute("SELECT * FROM #{tabel} WHERE #{id_tabel} = ?",@id).first
    db.execute("SELECT #{titel} FROM #{tabel_2} WHERE ArtistId IN (SELECT ArtistId FROM Albums WHERE AlbumId = ?)",id).first
    # Jag vet ej vad jag ska göra med rad 29? Vad borde jag egentligen ha här för att det ska passa databasne som jag gjort med frågor och svar?
end

def select_one_tabel(tabel, id_tabel, variabel)
    db = SQLite3::Database.new("db/main.db")
    db.results_as_hash = true
    db.execute("SELECT * FROM #{tabel} WHERE #{id_tabel} = ?", variabel)
end

def select_all_answers_for_one_question(tabel, id_tabel, variabel)
    db = SQLite3::Database.new("db/main.db")
    db.results_as_hash = true
    db.execute("SELECT * FROM #{tabel} WHERE #{id_tabel} = ?", variabel)
end

