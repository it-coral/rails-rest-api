# frozen_string_literal: true

require 'swagger_helper'

describe Api::V1::GroupsController do
  let!(:group) { create :group, organization: current_user.organizations.first }
  let!(:group_user) { create :group_user, group: group, user: current_user }
  let(:rswag_properties) do
    {
      current_user: current_user,
      current_organization: current_user.organizations.first,
      object: group
    }
  end

  options = { klass: Group }

  crud_index options.merge(
    as: :searchkick,
    additional_parameters: [{
      name: :visibility,
      in: :query,
      type: :string,
      required: false,
      enum: Group.visibilities.values,
      description: 'Filter groups by visibility'
    }, {
      name: :status,
      in: :query,
      type: :string,
      required: false,
      enum: Group.statuses.values,
      description: 'Filter groups by status'
    }, {
      name: :my,
      in: :query,
      type: :boolean,
      required: false,
      description: "return user's groups"
    }, {
      name: :term,
      in: :query,
      type: :string,
      required: false,
      description: "term for searching by #{Group::SEARCH_FIELDS}"
    }]
  )

  crud_show options
  crud_create options
  crud_update options
  crud_delete options
end
