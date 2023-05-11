module Model   
    # Checks if a string is empty
    #
    # @param [String] variable The string
    #
    # @return [Boolean] True if variable is an empty string
    def if_a_variable_is_an_empty_string(variable)
        return variable == ""
    end

    # Checks if two values of the same type are equal to one another
    # @param [String] first_value A value
    # @param [String] first_value Another value
    # @option params [Integer] first_value A value
    # @option params [Integer] first_value Another value
    #
    # @return [Boolean] True if both values are the same
    def if_two_values_are_the_same(first_value, second_value)
        return first_value == second_value # Är detta rätt sätt att göra detta? Fråga Leo! Svar: Så här ska det se ut från ovanför.
    end
    
    # Checks if two values of the same type are not the same
    # @param [String] first_value A value
    # @param [String] first_value Another value
    # @option params [Integer] first_value A value
    # @option params [Integer] first_value Another value
    #
    # @return [Boolean] True if both values are not the same
    def if_two_values_are_not_the_same(first_value, second_value)
        return first_value != second_value # Är detta rätt sätt att göra detta? Fråga Leo! Svar: Så här ska det se ut från ovanför.
    end


    # Connects an @-variabel to a database using hash
    #
    def use_db_file_hash()
        @db = SQLite3::Database.new("db/main.db")
        @db.results_as_hash = true
    end

    # Connects an @-variabel to a database
    #
    def use_db_file()
        @db = SQLite3::Database.new("db/main.db")
    end

    # Makes a question
    #
    # @param [String] title The question
    # @param [String] user_id The ID of a user
    def make_a_question(title, user_id)
        use_db_file_hash()
        @db.execute("INSERT INTO question (value_of_question, title, user_id) VALUES (0, ?, ?)",title, user_id)
    end

    # Makes an answer for a question
    #
    # @param [String] title The answer
    # @param [String] id_from_question The question ID connected to the answer
    # @param [String] false_or_true A boolean either false or true
    def make_new_answers(title, id_from_question, false_or_true)
        use_db_file_hash()
        @db.execute("INSERT INTO answer (value_of_answer, title, question_id, false_or_true) VALUES (0, ?, ?, ?)",title,id_from_question,false_or_true)
    end

    # Inserts value for a named tabel, condition and the value for the condition
    #
    # @param [String] tabel The name of a tabel in a database
    # @param [String] attribute_for_tabel The condition
    # @param [String] value_of_aft The value of the condition
    def set_value_for_a_tabels_column(tabel, attribute_for_tabel, value_of_aft)
        use_db_file_hash()
        @db.execute("INSERT INTO #{tabel} (#{attribute_for_tabel}) VALUES (?)",value_of_aft)
    end


    # Inserts value for a tabels two columns.
    #
    # @param [String] tabel The name of a tabel in a database
    # @param [String] attribute_for_tabel The condition
    # @param [String] value_of_aft The value of the condition
    # @param [String] attribute_for_tabel_2 The second condition
    # @param [String] value_of_aft_2 The value of the second condition
    def set_two_values_for_a_tabels_column(tabel, attribute_for_tabel, attribute_for_tabel_2, value_of_aft, value_of_aft_2)
        use_db_file_hash()
        @db.execute("INSERT INTO #{tabel} (#{attribute_for_tabel}, #{attribute_for_tabel_2}) VALUES (?, ?)",value_of_aft,value_of_aft_2)
    end

    # Inserts value for a tabels three columns
    #
    # @param [String] tabel The name of a tabel in a database
    # @param [String] attribute_for_tabel_1 The first condition
    # @param [String] value_of_aft_1 The value of the first condition
    # @param [String] attribute_for_tabel_2 The second condition
    # @param [String] value_of_aft_2 The value of the second condition
    # @param [String] attribute_for_tabel_3 The third condition
    # @param [String] value_of_aft_3 The value of the third condition
    def add_values_for_a_tabel(tabel, attribute_for_tabel_1, attribute_for_tabel_2, attribute_for_tabel_3, value_of_aft_1, value_of_aft_2, value_of_aft_3)
        use_db_file()
        @db.execute("INSERT INTO #{tabel} (#{attribute_for_tabel_1},#{attribute_for_tabel_2}, #{attribute_for_tabel_3}) VALUES (?,?,?)",value_of_aft_1,value_of_aft_2,value_of_aft_3)
    end


    # Makes answers
    #
    # @param [String] value_of_titel The answer
    # @param [String] value_of_id The question ID connected to the answer
    # @param [String] false_or_true_value A boolean either false or true
    def make_answers(value_of_titel, value_of_id, false_or_true_value)
        use_db_file_hash()
        @db.execute("INSERT INTO answer (value_of_answer, title, question_id, false_or_true) VALUES (0, ?, ?, ?)",value_of_titel, value_of_id. false_or_true_value)
    end 


    # Select everything from a tabel
    #
    # @param [String] tabel The name of a tabel in a database
    def select_all_from_a_tabel(tabel)
        use_db_file_hash()
        @db.execute("SELECT * FROM #{tabel}")
    end


    # Select everything from a tabel in an alfabetic order
    # @param [String] tabel The name of a tabel in a database
    # @param [String] attribute_for_tabel The condition is a column from the given tabel
    # @param [String] how_to_order_by The value of the condition
    def select_all_from_a_tabel_alfabetic_order(tabel, attribute_for_tabel, how_to_order_by)
        use_db_file_hash()
        @db.execute("SELECT * FROM #{tabel} ORDER BY #{attribute_for_tabel} #{how_to_order_by}")
    end

    # Deletes a tabel in a database with a condition
    # @param [String] tabel The name of a tabel in a database
    # @param [String] attribute_for_tabel The condition
    # @param [String] value_of_aft The value of the condition
    def delete_a_column_for_a_tabel(tabel, attribute_for_tabel, value_of_aft)
        #aft = attribute_for_tabel
        use_db_file()
        @db.execute("DELETE FROM #{tabel} WHERE #{attribute_for_tabel} = ?",value_of_aft)
    end

    # Updates a tabel from a database with a condition
    # @param [String] tabel The name of a tabel in a database
    # @param [String] attribute_for_tabel_1 The column for the tabel
    # @param [String] value_of_aft_1 The value which is changes to for the column of the tabel
    # @param [String] id_for_a_column_tabel The condition
    # @param [String] value_of_aft The value of the condition
    def update_a_column_for_a_tabel(tabel, attribute_for_tabel_1, id_for_column_tabel, value_of_aft_1, value_of_id_for_column_tabel)
        # aft = attribute_for_tabel
        use_db_file()
        @db.execute("UPDATE #{tabel} SET #{attribute_for_tabel_1} = ? WHERE #{id_for_column_tabel} = ?",value_of_aft_1,value_of_id_for_column_tabel) # Jag måste veta hur många attribute_for_tabel och variabel som jag behöver!
    end


    # Selects everything from a tabel with a condition
    # @param [String] tabel The name of a tabel in a database
    # @param [String] attribute_for_tabel The condition
    # @param [String] value_of_aft The value of the condition
    def select_one_tabel(tabel, attribute_for_tabel, value_of_aft)
        use_db_file_hash()
        @db.execute("SELECT * FROM #{tabel} WHERE #{attribute_for_tabel} = ?", value_of_aft)
    end

    # Gets every user that is connected with a specifik question ID.
    #
    # @param [String] id The questions ID.
    def get_all_users_from_question(id)
        use_db_file_hash()
        @db.execute("SELECT user.username FROM user INNER JOIN user_question_relation ON user.id = user_question_relation.user_id WHERE user_question_relation.question_id = ?", id)
    end

    # Checks if a variabel has a space in one of the strings character.
    #
    # @param [String] variabel A string
    # @return [Boolean] If a string has a space in one character it is true
    def check_if_a_variabel_has_a_space(string)
        i = 0
        while i < string.length
            if string[i] == " "
                return true
            end 
            i += 1
        end
        return false
    end
end