require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative 'model/model.rb'
enable :sessions

include Model

# A function that looks if there is an account. 
#
def check_if_there_is_a_account()
    if session[:id] == nil
        redirect('/')
    end
end

# A helpers function that is a function that can be used in slim-files. 
# In the help function there is another function that looks if an account is not admin.
#
helpers do

    # Looks if an accounts ID is not admin.
    #    
    def check_if_an_account_is_not_admin()
        if session[:id] != 1
            redirect("/")
        end
    end

    # Samma dokumentation som i model? Fråga Emil! Svar:
    # Looks if an account/user does not own a particular question
    #
    # @param [Integer] question_id, The question ID
    #
    # @return [Boolean] True if the user owns the specifik question
    #
    # @see Model#select_one_tabel
    def check_if_an_account_does_not_own_the_question_when_editing_it(question_id)
        the_question = select_one_tabel("question", "id", question_id)
        #the_question_in_an_array = []
        #the_question_in_an_array << the_question
        puts the_question
        #puts the_question_in_an_array
        if the_question == nil
            return false
        end
        p session[:id]
        p the_question.first()["user_id"]
        return the_question.first()["user_id"] == session[:id]
        
    end

end  

# Display register forms
# 
get('/') do
    @id_of_user = session[:id]
    @error_no_string = session[:error_no_string]
    @error_same_name = session[:error_same_name]
    @error_register = session[:error_register]
    @error_no_space = session[:error_no_space]
    session[:error_register] = false
    session[:error_same_name] = false
    session[:error_no_string] = false
    session[:error_no_space] = false
    slim(:register)    
end

# A before-block that makes the coldown happen. You have to wait a certain time before you can login again.
#
before('/showlogin') do
    if session[:last_time] != nil
        p Time.now.to_i - session[:last_time]
        if Time.now.to_i - session[:last_time] < 15
            session[:cooldown] = true
            redirect("/access_denied")
        end
    end
end


# Display login form
#
get('/showlogin') do
    @error_no_string = session[:error_no_string]
    @error_login = session[:error_login]
    session[:error_login] = false
    session[:error_no_string] = false
    slim(:login)
end

# Display site that shows an error message
#
get('/access_denied') do
    @cooldown = session[:cooldown]
    @wrong_user = session[:wrong_user]
    session[:wrong_user] = false
    @wrong_like_for_your_own_question = session[:error_liking_your_question]
    session[:error_liking_your_question] = false
    session[:cooldown] = false
    slim(:access_denied)
end

# Logs out the user from the account they are using.
#
post("/logout") do
    session[:id] = nil
    redirect("/showlogin")
end

# Attempts login and updates sessions. The post-route either redirects to '/showlogin' or '/meny'
# 
# @param [String] username, The username
# @param [String] password, The username
# @see Model#if_a_variable_is_an_empty_string
# @see Model#select_one_tabel
# @see Model#if_two_values_are_the_same
# @see Model#if_two_values_are_not_the_same
post('/login') do
    time = 15
    session[:cooldown] = false
    session[:error_no_string] = false
    session[:error_login] = false
    username = params[:username]
    password = params[:password]
    
    if (session[:attemps_array] == nil)
        session[:attemps_array] = []
    end

    all_times_for_failed_attempt = session[:attemps_array]

    if (all_times_for_failed_attempt.length) >= 3
        p all_times_for_failed_attempt[1]
        if ((all_times_for_failed_attempt[1] - all_times_for_failed_attempt[0]) < time) || ((all_times_for_failed_attempt[2] - all_times_for_failed_attempt[1])) < time
            p all_times_for_failed_attempt
            p all_times_for_failed_attempt[2]
            session[:last_time] = all_times_for_failed_attempt[2]
            session[:attemps_array] = []
            session[:cooldown] = true
            redirect('/access_denied')
        end
    end

    if if_a_variable_is_an_empty_string(username) || if_a_variable_is_an_empty_string(password)
        error_attempt = Time.now.to_i
        all_times_for_failed_attempt << error_attempt
        session[:error_no_string] = true
        redirect('/showlogin')
    end

    user = select_one_tabel("user", "username", username).first
    if user == nil # Behöver jag göra en funktion här? Fråga Leo! Svar:  Funktion ska användas.
        error_attempt = Time.now.to_i
        all_times_for_failed_attempt << error_attempt
        session[:error_login] = true
        redirect('/showlogin')
    end
    user_username = user["username"]
    if if_two_values_are_not_the_same(user_username, username)
        session[:error_login] = true
        error_attempt = Time.now.to_i
        all_times_for_failed_attempt << error_attempt
        session[:error_login] = true
        redirect('/showlogin')
    elsif if_two_values_are_the_same(user_username, username)
        pwdigest = user["password_digest"]
        id = user["id"]        
        if if_two_values_are_the_same(BCrypt::Password.new(pwdigest), password) # Behöver jag göra en funktion här? Fråga Leo! Svar: Funktion ska användas.
            session[:id] = id
            redirect('/meny')
        else
            error_attempt = Time.now.to_i
            all_times_for_failed_attempt << error_attempt
            session[:error_login] = true
            redirect("/showlogin")
        end
    end 
end

# Makes a new user that redirect to '/'
#
# @param [String] username, The username
# @param [String] password, The password
# @param [String] password_confirm, The password typed again
# @see Model#if_a_variable_is_an_empty_string
# @see Model#select_all_from_a_tabel
# @see Model#if_two_values_are_the_same
# @see Model#add_values_for_a_tabel
post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    session[:error_register] = false
    session[:error_same_name] = false
    session[:error_no_space] = false
    session[:error_no_string] = false

    if check_if_a_variabel_has_a_space(username)
        session[:error_no_space] = true
        redirect('/')
    end

    if check_if_a_variabel_has_a_space(password)
        session[:error_no_space] = true
        redirect('/')
    end

    if check_if_a_variabel_has_a_space(password_confirm)
        session[:error_no_space] = true
        redirect('/')
    end

    all_users_content = select_all_from_a_tabel("user")
    p all_users_content
    p all_users_content.length
    i = 0
    while i < all_users_content.length
        a_users_name = all_users_content[i]["username"]
        if if_two_values_are_the_same(username, a_users_name)
            session[:error_same_name] = true
            redirect('/')
        end
        i += 1
    end

    if if_two_values_are_the_same(password, password_confirm) # Gör en funktion som kollar på detta påstående. Generellt: Gör en funktion i model.rb om man kollar på en variabels värde som är en input av en användare.
      #Lägg till användare
        if if_a_variable_is_an_empty_string(password) || password == nil
            session[:error_no_string] = true
            redirect('/')
        elsif if_a_variable_is_an_empty_string(password_confirm) || password_confirm == nil
            session[:error_no_string] = true
            redirect('/')
        end
      ecological_footprint_value = 0
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/todo2022.db')
      add_values_for_a_tabel("user", "username", "password_digest", "ecological_footprint_value", username, password_digest, ecological_footprint_value)
      redirect('/showlogin')
    else
        session[:error_register] = true
        #Felhantering
        redirect('/')
        #Lägg till en länk eller knapp som gör att du kan välja att gå tillbaka för att registrera dig.
        # Hur lägger man till en slags knapp i en post_route?
    end
end
  
# Function that makes session[:calc_index] alsways starts from the value 0.
#
before do
    if session[:calc_index] == nil
        session[:calc_index] = 0
    end
end

# A route that looks if the quiz is done or not and it looks on which question you are while you are answering questions.
# @see Model#check_if_there_is_a_account
# @see Model#select_all_from_a_tabel
# @see Model#select_one_tabel
get("/calculator") do
    # reset_quiz = params[:reset_quiz]
    # if reset_quiz
    #     update_a_column_for_a_tabel("user", "ecological_footprint_value", "id", 0, session[:id])   
    # end
    #update_a_column_for_a_tabel("user", "ecological_footprint_value", "id", 0, session[:id]) <-- # Var ska denna kod befinna sig? Det går inte att ha den här, då det för varje gång man svarar på en fråga ändrar värdet till 0, vilket gör att man alltid kommer att ha värdet 0 oavsett vad man svarar efter att man gjort färdigt hela quizet.

    #p select_one_tabel("user", "id", session[:id]).first()["ecological_footprint_value"]
    #select_one_tabel("user", "id", session[:id]).first()["ecological_footprint_value"] = 0 # Vill jag updata värdet eller inserta ett värde? Fråga Leo! Svar: Använd UPDATE för att uppdatera värdet
    check_if_there_is_a_account()
    all_questions = select_all_from_a_tabel("question")# hämta alla frågor. Typ: "SELECT * FROM question"

    # Kolla om session[:calc_index] är ett giltigt index, alltså session[:calc_index] < questions.length
    if session[:calc_index] >= all_questions.length
        @quiz_done = false
    else
        @quiz_done = true
    end
    @current_question = all_questions[session[:calc_index]]
    if @current_question != nil
        @answers = select_one_tabel("answer", "question_id", @current_question["id"])
    end
    # hämta alla answers som tillhör frågan. Typ: "SELECT * FROM answers WHERE question_id = ?", @current_question["id"]
    all_users = select_all_from_a_tabel("user")
    p all_users
    p session[:id]
    position_of_user = 0
    while position_of_user < all_users.length
        if all_users[position_of_user]["id"] == session[:id]
            break
        end
        position_of_user += 1
    end
    #Problem här; Rad 227: Error_meddelandet nämner att "ecological_footprint_value" är nil.
    p all_users[position_of_user]['ecological_footprint_value']
    @value_of_ecological_footprints = all_users[position_of_user]['ecological_footprint_value']
    p @value_of_ecological_footprints
    slim(:calculator)
end

# A route that resets your quiz and the variables that change when you are using the quiz.
# @see Model#check_if_there_is_a_account
# @see Model#select_one_tabel
# @see Model#update_a_column_for_a_tabel
post("/restart_quiz") do
    check_if_there_is_a_account()
    session[:calc_index] = 0
    ecological_footprint_value = select_one_tabel("user", "id", session[:id]).first()["ecological_footprint_value"]
    ecological_footprint_value = 0
    update_a_column_for_a_tabel("user", "ecological_footprint_value", "id", ecological_footprint_value, session[:id])  
    redirect("/calculator")
end

# Typ 1 och 2 har samma route (se slim fil):

# A route that changes your ecological_footprint_value when you answer each question.
#
# params[String] user_answer, The answers the user has to chose. 
# @see Model#check_if_there_is_a_account
# @see Model#select_all_from_a_tabel
# @see Model#select_one_tabel
# @see Model#update_a_column_for_a_tabel
post("/manage_question") do
    check_if_there_is_a_account()
    user_answer = params[:answer].to_i
    # OBS: tre raderna nedan är samma som i get routen
    all_questions = select_all_from_a_tabel("question")# hämta alla frågor. Typ: "SELECT * FROM question"
    @current_question = all_questions[session[:calc_index]]
    @answers = select_one_tabel("answer", "question_id", @current_question["id"])# hämta alla answers som tillhör frågan. Typ: "SELECT * FROM answers WHERE question_id = ?", @current_question["id"]

    if @answers[user_answer]["false_or_true"] == "true" #Borde jag använda en funktion här? Fråga Leo! Svar: 
        # hämta ecological_footprint_value från databas. Spara det i en variabel. Vi kallar variabeln: Fisk
        # Öka Fisk med 1
        # Uppdatera ecological_footprint_value till Fisk i databasen med UPDATE
        ecological_footprint_value = select_one_tabel("user", "id", session[:id]).first()["ecological_footprint_value"]
        p ecological_footprint_value
        p select_one_tabel("user", "id", session[:id])
        ecological_footprint_value -= 1 
        update_a_column_for_a_tabel("user", "ecological_footprint_value", "id", ecological_footprint_value, session[:id])
        # vad händer om man väljer *rätt* svarsalternativ?      
    else
        ecological_footprint_value = select_one_tabel("user", "id", session[:id]).first()["ecological_footprint_value"]
        ecological_footprint_value += 1 
        update_a_column_for_a_tabel("user", "ecological_footprint_value", "id", ecological_footprint_value, session[:id])
        # vad händer om man väljer *fel* svarsalternativ?
    end

    session[:calc_index] += 1
    redirect("/calculator")
end

# A route that shows all sites on my webb. 
# @see Model#check_if_there_is_a_account
get("/meny") do
    check_if_there_is_a_account()
    @id_of_user = session[:id]
    slim(:startsida)
end

# A route that shows all the question that would be used for the quiz.
# @see Model#check_if_there_is_a_account
# @see Model#select_all_from_a_tabel_alfabetic_order
get("/questions") do
    check_if_there_is_a_account()
    @id_of_user = session[:id]
    #id = params[:id].to_i
    #p id
    @result = select_all_from_a_tabel_alfabetic_order("question", "title", "ASC")
    p @result
    slim(:"questions/index")
end

# A route that shows you a form when you are making a new question.
#
get('/questions/new') do
    slim(:"questions/new")
end

# A route that makes a question
#
# params[String] title, The question
# params[String] answer_1, The first answer out of three answers
# params[String] answer_2, The second answer out of three answers
# params[String] answer_3, The third answer out of three answers
# params[String] selected_true, The answer that you selected to be the right one.
# @see Model#check_if_there_is_a_account
# @see Model#make_a_question
# @see Model#select_all_from_a_tabel
# @see Model#select_one_tabel
# @see Model#make_new_answers
post("/questions") do
    check_if_there_is_a_account()
    #Gör en funktion för att lägga till värdet på kolumnen "false_or_true" för svarsalternativen då jag upprepar detta även i routen där jag lägger till en fråga med svarsalternativ.
    title = params[:question]
    answer_1 = params[:alt_1]
    answer_2 = params[:alt_2]
    answer_3 = params[:alt_3]
    selected_true = params[:selected_true]
    p selected_true
    make_a_question(title, session[:id])
    id_new_question = select_all_from_a_tabel("question").last()['id']
    #make_new_answers(answer_2, id_new_question, "")
    #make_new_answers(answer_3, id_new_question, "")
    all_selected_options = ["option_1", "option_2", "option_3"]
    all_answers_for_new_question = select_one_tabel("answer", "question_id", id_new_question)
    all_answers = [answer_1, answer_2, answer_3]
    p all_answers_for_new_question
    i = 0
    #set_two_values_for_a_tabels_column("user_question_relation", "user_id", "question_id", session[:id], id_new_question) # Rätt eller inte? Fråga Leo för jag är inte säker om jag ska använda variabeln id_new_question för att lägga till question_id. 
    while i < all_selected_options.length
        if all_selected_options[i] == selected_true
            # Villkoret fungerar inte!
            #all_answers_for_new_question[i]['false_or_true'] += "true"
            #p all_answers_for_new_question[i]['false_or_true']
            make_new_answers(all_answers[i], id_new_question, "true")
            #make_new_answers(all_answers_for_new_question[i]['title'], #id_new_question, all_answers_for_new_question[i]['false_or_true'])
            #delete_a_column_for_a_tabel("answer", "false_or_true", "")
            # Jag behöver uppdatera detta värde genom att använda SQL-språket till databasen!
            # Här ska jag göra så att värdet på detta svarets kolumn "false_or_true" får "true"
            # Använd UPDATE istället för att lägga till nya svarsalternativ för en fråga igen! Använd UPDATE formeln som finnsi "model.rb"
        else
            #all_answers_for_new_question[i]['false_or_true'] += "false"
            #p all_answers_for_new_question[i]['false_or_true']
            make_new_answers(all_answers[i], id_new_question, "false")
            #make_new_answers(all_answers_for_new_question[i]['title'], #id_new_question, all_answers_for_new_question[i]['false_or_true'])
            #delete_a_column_for_a_tabel("answer", "false_or_true", "")
            # Jag behöver uppdatera detta värde genom att använda SQL-språket till databasen!
            # Här ska jag göra så att värdet på detta svarets kolumn "false_or_true" får "false"
        end
        i += 1
    end
    redirect('/questions')
end

# A route that deletes all information from a question that is related in the database.
#
# params[Integer] id, The number/id of a specifik question
# @see Model#check_if_an_account_is_not_admin
# @see Model#delete_a_column_for_a_tabel
post('/questions/:id/delete') do
    check_if_an_account_is_not_admin()
    id = params[:id].to_i
    delete_a_column_for_a_tabel("question", "id", id)
    delete_a_column_for_a_tabel("answer", "question_id", id)
    delete_a_column_for_a_tabel("user_question_relation", "question_id", id)
    redirect('/questions')
end  

# A route that enables to change a questions title, answer or the correct answer.
#
# params[Integer] id, The number/id of a specifik question
# params[String] title, The question
# params[String] answer_1, First answer out of three answers
# params[String] answer_2, Second answer out of three answers
# params[String] answer_3, First answer out of three answers
# @see Model#check_if_there_is_a_account
# @see Model#check_if_an_account_does_not_own_the_question_when_editing_it
# @see Model#update_a_column_for_a_tabel
# @see Model#delete_a_column_for_a_tabel
# @see Model#make_new_answers
post("/questions/:id/update") do
    session[:wrong_user] = false
    check_if_there_is_a_account()
    #Gör en funktion för att lägga till värdet på kolumnen "false_or_true" för svarsalternativen då jag upprepar detta även i routen där jag lägger till en fråga med svarsalternativ.
    id = params[:id].to_i
    title = params[:question]
    answer_1 = params[:alt_1]
    answer_2 = params[:alt_2]
    answer_3 = params[:alt_3]
    selected_true = params[:selected_true]
    all_selected_options = ["option_1", "option_2", "option_3"]
    all_answers = [answer_1, answer_2, answer_3]

    if !check_if_an_account_does_not_own_the_question_when_editing_it(id)
        session[:wrong_user] = true
        redirect('/access_denied')
    end

    update_a_column_for_a_tabel("question", "title", "id", title, id)
    #update_a_column_for_a_tabel("answer", "title", "question_id", answer_1, id)
    #update_a_column_for_a_tabel("answer", "title", "question_id", answer_2, id)
    #update_a_column_for_a_tabel("answer", "title", "question_id", answer_3, id)
    #Jag hade en delete funktion här för att försöka ta bort alla svarsalternativen för en fråga, då den använder question_id, som är en främmande nyckel.
    delete_a_column_for_a_tabel("answer", "question_id", id)
    i = 0
    while i < all_selected_options.length
        if all_selected_options[i] == selected_true #Borde jag använda en funktion här? Fråga Leo! Svar: 
            make_new_answers(all_answers[i], id, "true")
        else
            make_new_answers(all_answers[i], id, "false")
        end
        i += 1
    end
    # Kollar om det är en ny användare som redigerar en fråga. Om det är en ny ska det visas på hemsidan. Om det är en en användare som redan har redigerat frågan ska den inte visas flera gånger. 

    #@all_users_that_changed = select_one_tabel("user_question_relation", )

    #@which_question =

    #Hur ska jag göra för att lägga till svarsalternativen för en fråga när jag ska uppdatera en fråga?
    
    redirect("/questions")
end

# A route that shows what you could edit on a question
#
# params[Integer] id, The number/id of a specifik question
# @see Model#check_if_there_is_a_account
# @see Model#select_one_tabel
get("/questions/:id/edit") do
    check_if_there_is_a_account()
    id = params[:id].to_i
    @question = select_one_tabel("question", "id", id).first()
    @answers = select_one_tabel("answer", "question_id", id)
    @all_users_that_changed_a_question = "" 
    #p "Result är #{result}"
    p @question
    p @answers

    slim(:"/questions/edit")
end

# A route that shows the answers of a question
#
# params[Integer] id, The number/id of a specifik question
# @see Model#check_if_there_is_a_account
# @see Model#select_one_tabel
# @see Model#get_all_users_from_question
get("/questions/:id") do
    check_if_there_is_a_account()
    fråga_id = params[:id].to_i
    p fråga_id
    # alla information från en fråga från db --> Gjort!
    # hämta all information för alla frågor som har question_id = fråga_id, från db --> Gjort!
    @one_questions = select_one_tabel("question", "id", fråga_id).first()
    @all_answers_for_one_question = select_one_tabel("answer", "question_id", fråga_id)
    @all_users = get_all_users_from_question(fråga_id)
    p @one_questions
    p @all_answers_for_one_question
    slim(:"questions/show")
end

# A route that makes a relation between a question and a user through their id.
#
# params[Integer] id, The specifik number/id from a question.
# @see Model#check_if_there_is_a_account
# @see Model#select_one_tabel
# @see Model#select_two_values_for_a_tabels_column
post("/process_of_a_like/:id") do
    id = params[:id]
    check_if_there_is_a_account()
    session[:error_liking_your_question] = false
    new_editor = true
    all_relations = select_one_tabel("user_question_relation", "question_id", id)
    if all_relations != nil
        all_relations.each do |relation|
            if relation["user_id"] == session[:id]
                new_editor = false
                break
            end
        end
    end

    # Kolla quetions user_id

    the_question = select_one_tabel("question", "id", id)

    if the_question.first()["user_id"] == session[:id]
        new_editor = false
        session[:error_liking_your_question] = true
        redirect("/access_denied")
    end

    if new_editor
        set_two_values_for_a_tabels_column("user_question_relation", "user_id", "question_id", session[:id], id)
    end
    redirect("/questions")
end

# Shows all the users accounts that have been made for this website.
# @see Model#select_all_from_a_tabel
get("/all_users") do
    @id_of_user = session[:id]
    check_if_there_is_a_account()
    @all_users = select_all_from_a_tabel("user")
    slim(:all_users)
end

# A route that gets rid of users_accounts. Only admin has the ability to do so.
#
# params[Integer] id, The number/id from a user.
# @see Model#check_if_an_account_is_not_admin
# @see Model#select_one_tabel
# @see Model#delete_a_column_for_a_tabel
post("/user/:id/delete") do
    check_if_an_account_is_not_admin()
    id = params[:id].to_i
    the_questions = select_one_tabel("question", "user_id", id)
    # Kolla om det finns en user.
    if the_questions != nil
        the_questions.each do |question|
            p the_questions
            delete_a_column_for_a_tabel("answer", "question_id", question["id"])
            delete_a_column_for_a_tabel("user_question_relation", "question_id", question["id"])
        end
    end
    
    delete_a_column_for_a_tabel("user_question_relation", "user_id", id)
    delete_a_column_for_a_tabel("question", "user_id", id)
    delete_a_column_for_a_tabel("user", "id", id)

    redirect("/all_users")
end