class AddStatusToOrganizationUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :organization_users, :status, :string
  end
end
