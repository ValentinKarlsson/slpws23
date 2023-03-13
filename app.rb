require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative "./model.rb"
enable :sessions

#post-routes ska inte vara slim-filer, utan ska vara en slags funktion till en slim-fil.

=begin
get("/before_meny") do 

end
=end

get("/meny") do
    slim(:meny)
end

get("/questions") do
    id = params[:id].to_i
    p id
    @result = select_all_from_a_tabel("question")
    p @result
    slim(:"questions/index")
end

get("/calculator") do
    #Jag ska på något sätt spara en tabells olika värden i en array här!
    slim(:calculator)
end

get('/questions/new') do
    slim(:"questions/new")
end

post("/questions") do
    title = params[:question]
    answer_1 = params[:alt_1]
    answer_2 = params[:alt_2]
    answer_3 = params[:alt_3]
    make_questions_and_answeres(title, answer_1, answer_2, answer_3)
    redirect('/questions')
end

post("/questions/:id/update") do
    id = params[:id].to_i
    title = params[:title]
    artist_id = params[:ArtistId].to_i
    
    redirect("/questions")
end

get("/questions/:id") do
    fråga_id = params[:id].to_i
    p fråga_id
    # alla information från en fråga från db
    # hämta all information för alla frågor som har question_id = fråga_id, från db
    @one_questions = select_one_tabel("question", "id", fråga_id).first()
    @all_answers_for_one_question = select_all_answers_for_one_question("answer", "question_id", fråga_id)

    p @one_questions
    p @all_answers_for_one_question
    slim(:"questions/show")
end