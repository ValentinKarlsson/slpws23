require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative "./model.rb"
enable :sessions

get('/') do
    slim(:register)
end
  
get('/showlogin') do
    slim(:login)
end

post("/logout") do
    session[:id] = nil
    redirect("/showlogin")
end
  
post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/todo2022.db')
    db.results_as_hash = true
    user = select_one_tabel("user", "username", username).first
    pwdigest = user["password_digest"]
    id = user["id"]
  
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/meny')
    else
        "FEL LÖSENORD!"
        #Lägg till en länk eller knapp som gör att du kan välja att gå tillbaka för att registrera dig.
        # Hur lägger man till en slags knapp i en post_route?
    end
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm)
      #Lägg till användare
      ecological_footprint_value = 0
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/todo2022.db')
      add_values_for_a_tabel("user", "username", "password_digest", "ecological_footprint_value", username, password_digest, ecological_footprint_value)
      redirect('/')
    else
      #Felhantering
        "Lösenorden matchade inte!"
        #Lägg till en länk eller knapp som gör att du kan välja att gå tillbaka för att registrera dig.
        # Hur lägger man till en slags knapp i en post_route?
    end
  
end
  

before do
    if session[:calc_index] == nil
        session[:calc_index] = 0
    end
end

get("/calculator") do
    all_questions = select_all_from_a_tabel("question")# hämta alla frågor. Typ: "SELECT * FROM question"

    # Kolla om session[:calc_index] är ett giltigt index, alltså session[:calc_index] < questions.length
    if session[:calc_index] >= all_questions.length
        @quiz_done = false
    else
        @quiz_done = true
    end
    @current_question = all_questions[session[:calc_index]]
    @answers = select_all_answers_for_one_question("answer", "question_id", @current_question["id"])# hämta alla answers som tillhör frågan. Typ: "SELECT * FROM answers WHERE question_id = ?", @current_question["id"]

    slim(:calculator)
end

post("/restart_quiz") do
    session[:calc_index] = 0
    ecological_footprint_value = select_one_tabel("user", "id", session[:id]).first()["ecological_footprint_value"]
    ecological_footprint_value = 0
    update_a_column_for_a_tabel("user", "ecological_footprint_value", "id", ecological_footprint_value, session[:id])  
    redirect("/calculator")
end

# Typ 1 och 2 har samma route (se slim fil):
post("/manage_question") do
    user_answer = params[:answer].to_i
    # OBS: tre raderna nedan är samma som i get routen
    all_questions = select_all_from_a_tabel("question")# hämta alla frågor. Typ: "SELECT * FROM question"
    @current_question = all_questions[session[:calc_index]]
    @answers = select_all_answers_for_one_question("answer", "question_id", @current_question["id"])# hämta alla answers som tillhör frågan. Typ: "SELECT * FROM answers WHERE question_id = ?", @current_question["id"]

    if @answers[user_answer]["false_or_true"] == "true"
        # hämta ecological_footprint_value från databas. Spara det i en variabel. Vi kallar variabeln: Fisk
        # Öka Fisk med 1
        # Uppdatera ecological_footprint_value till Fisk i databasen med UPDATE
        ecological_footprint_value = select_one_tabel("user", "id", session[:id]).first()["ecological_footprint_value"]
        p ecological_footprint_value
        p select_one_tabel("user", "id", session[:id])
        ecological_footprint_value += 1 
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

#post-routes ska inte vara slim-filer, utan ska vara en slags funktion till en slim-fil.

=begin
get("/before_meny") do 

end
=end
=begin
    1. Jag behöver lägga en knapp för att kunna lägga till en ny fråga. 
    2. Jag behöver även länkar som går tillbaka till sidan man kom ifrån. 
=end
get("/meny") do
    if session[:id] == nil
        redirect('/')
    end
    slim(:startsida)
end

get("/questions") do
    id = params[:id].to_i
    p id
    @result = select_all_from_a_tabel_alfabetic_order("question", "title", "ASC")
    p @result
    slim(:"questions/index")
end

=begin get("/calculator") do
    @all_questions = select_all_from_a_tabel("question")
    @all_answers = select_all_from_a_tabel("answer")
    current_question()
    #Jag ska på något sätt spara en tabells olika värden i en array här!
    # En knapp för att reseta session.
    # Varje gång man väljer en svarsalternativ ökar man sessions värde med 1.
    # Session är en slags variabel. 
    # Session är ett sätt att lagra data och som kan framkallas senare i koden. 
    slim(:calculator)
end 
=end



=begin 
post("/calculator/all_values") do
    @all_questions = select_all_from_a_tabel("question")
    @all_answers = select_all_from_a_tabel("answer")
    redirect('/calculator')
end 
=end

get('/questions/new') do
    slim(:"questions/new")
end

post("/questions") do
    title = params[:question]
    answer_1 = params[:alt_1]
    answer_2 = params[:alt_2]
    answer_3 = params[:alt_3]
    selected_true = params[:selected_true]
    p selected_true
    make_a_question(title)
    id_new_question = select_all_from_a_tabel("question").last()['id']
    make_new_answers(answer_1, id_new_question, "")
    make_new_answers(answer_2, id_new_question, "")
    make_new_answers(answer_3, id_new_question, "")
    all_selected_options = ["option_1", "option_2", "option_3"]
    all_answers_for_new_question = select_one_tabel("answer", "question_id", id_new_question)
    p all_answers_for_new_question
    i = 0
    while i < all_selected_options.length
        if all_selected_options[i] == selected_true
            # Villkoret fungerar inte!
            all_answers_for_new_question[i]['false_or_true'] += "true"
            p all_answers_for_new_question[i]['false_or_true']
            make_new_answers(all_answers_for_new_question[i]['title'], id_new_question, all_answers_for_new_question[i]['false_or_true'])
            delete_a_column_for_a_tabel("answer", "false_or_true", "")
            # Jag behöver uppdatera detta värde genom att använda SQL-språket till databasen!
            # Här ska jag göra så att värdet på detta svarets kolumn "false_or_true" får "true"
        else
            all_answers_for_new_question[i]['false_or_true'] += "false"
            p all_answers_for_new_question[i]['false_or_true']
            make_new_answers(all_answers_for_new_question[i]['title'], id_new_question, all_answers_for_new_question[i]['false_or_true'])
            delete_a_column_for_a_tabel("answer", "false_or_true", "")
            # Jag behöver uppdatera detta värde genom att använda SQL-språket till databasen!
            # Här ska jag göra så att värdet på detta svarets kolumn "false_or_true" får "false"
        end
        i += 1
    end
    redirect('/questions')
end

post('/questions/:id/delete') do
    id = params[:id].to_i
    delete_a_column_for_a_tabel("question", "id", id)
    delete_a_column_for_a_tabel("answer", "question_id", id)
    redirect('/questions')
end  

post("/questions/:id/update") do
    id = params[:id].to_i
    title = params[:question]
    answer_1 = params[:alt_1]
    answer_2 = params[:alt_2]
    answer_3 = params[:alt_3]
    update_a_column_for_a_tabel("question", "title", "id", title, id)
    #update_a_column_for_a_tabel("answer", "title", "question_id", answer_1, id)
    #update_a_column_for_a_tabel("answer", "title", "question_id", answer_2, id)
    #update_a_column_for_a_tabel("answer", "title", "question_id", answer_3, id)
    #Jag hade en delete funktion här för att försöka ta bort alla svarsalternativen för en fråga, då den använder question_id, som är en främmande nyckel.
    delete_a_column_for_a_tabel("answer", "question_id", id)
    make_answers(answer_1, id)
    make_answers(answer_2, id)
    make_answers(answer_3, id)
    #Hur ska jag göra för att lägga till svarsalternativen för en fråga när jag ska uppdatera en fråga?
    
    redirect("/questions")
end

get("/questions/:id/edit") do
    id = params[:id].to_i
    @question = select_one_tabel("question", "id", id).first()
    @answers = select_one_tabel("answer", "question_id", id)
    #p "Result är #{result}"
    p @question
    p @answers
    slim(:"/questions/edit")
end

get("/questions/:id") do
    fråga_id = params[:id].to_i
    p fråga_id
    # alla information från en fråga från db --> Gjort!
    # hämta all information för alla frågor som har question_id = fråga_id, från db --> Gjort!
    @one_questions = select_one_tabel("question", "id", fråga_id).first()
    @all_answers_for_one_question = select_all_answers_for_one_question("answer", "question_id", fråga_id)

    p @one_questions
    p @all_answers_for_one_question
    slim(:"questions/show")
end

