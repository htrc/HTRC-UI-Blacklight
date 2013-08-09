# -*- encoding : utf-8 -*-
class CreateClientApplications < ActiveRecord::Migration
  def change
    create_table :client_applications do |t|
      t.string : 
      t.string : 
      t.string :name
      t.string : 
      t.string : 
      t.string :app_id
      t.string : 
      t.string : 
      t.string :app_secret

      t.timestamps
    end
  end
end
