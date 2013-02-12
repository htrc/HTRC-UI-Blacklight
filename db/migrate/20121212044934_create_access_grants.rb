class CreateAccessGrants < ActiveRecord::Migration
  def change
    create_table :access_grants do |t|
      t.string : 
      t.string : 
      t.string :code
      t.string : 
      t.string : 
      t.string :access_token
      t.string : 
      t.string : 
      t.string :refresh_token
      t.string : 
      t.string : 
      t.datetime :access_token_expires_at
      t.string : 
      t.string : 
      t.integer :user_id
      t.string : 
      t.string : 
      t.integer :application_id

      t.timestamps
    end
  end
end
