require 'sequel'
require 'sinatra'
require 'sinatra/reloader' if development?

Sequel::Model.plugin :insert_conflict

DB = Sequel.sqlite

DB.create_table :names do
    primary_key :id
    String :name, unique: true
    int :counter, default: 1
end

$names = DB[:names]

get '/hello' do
    name = params[:name]

    if name.nil? || name.strip.empty?
        "Hello World! Try passing a parameter like ?name=YourName and see the magic happen"
    else
        $names
            .insert_conflict(
                target: :name,
                update: {counter: Sequel[:counter] + 1}
            )
            .insert(name: name)

        out = $names.where(name: name).first

        "Hello #{name}! You have visited this page #{out[:counter]} times."
    end
end
