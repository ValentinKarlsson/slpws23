require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

=begin
get("/before_meny") do 

end
=end
get("/meny") do
    slim(:meny)
end


get("/calculator") do
    #Jag ska på något sätt spara en tabells olika värden i en array här!
    slim(:calculator)
end