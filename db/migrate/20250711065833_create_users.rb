class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null:false
      t.string :email, null:false, index: {unique: true}
      t.string :password_digest, null:false
      t.boolean :is_admin, default:false, null:false

      t.timestamps
    end
  end
end
